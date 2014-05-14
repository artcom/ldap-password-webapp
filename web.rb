ENV['RACK_ENV'] ||= 'development'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'ldap-password'

# returns array with error messages or nil
def validate_password(current, new_pw)
  checks = [
    ['new password must differ from current', 
      lambda {|current, new_pw| current == new_pw}], 

    ['must have 8 or more character', 
      lambda {|_, new_pw| new_pw.length < 8}],

    ['must contain at least one digit', 
      lambda {|_, new_pw| new_pw.scan(/\d/).size < 1}], 

    ['must contain at least one uppercase character', 
      lambda {|_, new_pw| new_pw.scan(/[A-Z]/).size < 1}], 

    ['must contain at least one special ASCII character',
      lambda {|_, new_pw| new_pw.scan(/[\W]/).size < 1}],
  ]

  # collect messages for all failing predicates
  checks.map {|msg, p| p.call(current, new_pw) && msg || nil}.compact
end

# returns array of error strings or nil
def change_password(username, password, new_pw)
  errors = validate_password(password, new_pw)
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

  redirect to (session[:errors].empty? ? '/success' : '/')
end

get '/success' do
  session.delete(:username)
  erb :thank_you
end
