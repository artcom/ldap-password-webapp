ENV['RACK_ENV'] ||= 'development'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'ldap-password'
require 'password-constraints'

# returns array of error strings or nil
def change_password(username, password, new_pw)
  #errors = validate_password(password, new_pw)
  errors = PasswordConstraints::validate(new_pw, password)
  return errors unless errors.empty?

  LdapPassword::change_password(username, password, new_pw)
end

set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "views") }

configure do
  enable :sessions
end

helpers do
  def username
    session[:username]
  end
end

get '/' do
  @errors = session[:errors]
  session.delete(:errors)
  erb :change_password_form
end

post '/change_password' do 
  session[:username] = params[:username]
  session[:errors] = if params[:new_pw] == params[:repeated_pw]
                       change_password(
                         username, params[:current_pw], params[:new_pw]
                       )
                     else 
                       ['new passwords do no match']
                     end

  redirect to (session[:errors].empty? ?
       "#{LdapPassword::config['base_url']}/success" :
       "#{LdapPassword::config['base_url']}/")
end

get '/success' do
  session.delete(:username)
  erb :thank_you
end

