ENV['RACK_ENV'] ||= 'development'
require 'rubygems'
require 'bundler/setup'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

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
  ]

  # collect messages for all failing predicates
  checks.map {|msg, p| p.call(current, new_pw) && msg || nil}.compact
end

module Ac
  module Ldap
    require 'digest/sha1' 
    require 'base64' 
    require 'securerandom' 

    def salt_please
      SecureRandom.random_bytes(4) # 16) 
    end
    def ssha_password(txt, salt = salt_please)
      puts "salt: #{Base64.encode64(salt)}"
      '{SSHA}' + Base64.encode64(Digest::SHA1.digest(txt + salt) + salt).chomp! 
    end

    def nt_password(txt, txt_encoding = 'UTF-8')
      txt_ucs2 = txt.encode("UTF-16LE", txt_encoding)
      OpenSSL::Digest::MD4.new(txt_ucs2).hexdigest.upcase
    end

    # return nil or error message string
    def change_password(username, oldpw, newpw)

      # TODO: extract hard wired base domain
      user_dn = "uid=#{username},ou=users,dc=artcom,dc=de"
      ldap = Net::LDAP.new(
      # TODO: extract hard wired server domain
        host: "ldap.intern.artcom.de", port: 389, 
        auth: { method: :simple, username: user_dn, password: oldpw }
      )
      ldap.bind or (return [ldap.get_operation_result.message])

      ldap.modify(
        dn: user_dn, operations: [
          [:replace, :sambaNTPassword, nt_password(newpw)], 
          [:replace, :sambaPwdLastSet, Time.now.to_i.to_s],
          [:replace, :userPassword , ssha_password(newpw)],
          [:replace, :shadowLastChange , (Time.now.to_i / 86400).to_s],
        ]
      ) ? [] : [ldap.get_operation_result.message]
    end

    extend(self)
  end # ~Ac::Ldap
end # ~Ac
# returns array of error strings or nil
def change_password(username, password, new_pw)
  errors = validate_password(password, new_pw)
  return errors unless errors.empty?

  Ac::Ldap::change_password(username, password, new_pw)
end

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
