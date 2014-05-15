module LdapPassword
  require 'digest/sha1' 
  require 'base64' 
  require 'securerandom' 
  require 'yaml'

  Defaults = {
    'ldap_port' => 389, 
    'ldap_auth_method' => :simple,
  }

  # lazy loading of config from yaml file
  # TODO: replace YAML loading with ENV importing
  # 
  def config(path = "config.yml")
    @config ||= (begin
      Defaults.update(YAML.load_file('config.yml'))
    rescue Errno::ENOENT
      STDERR.puts " !! config file not found at: '#{path}'"
      Defaults
    end)
  end

  def salt_please(byte_count = 4)
    SecureRandom.random_bytes(byte_count) # 16) 
  end
  def ssha_password(txt, salt = salt_please)
    #puts "salt: #{Base64.encode64(salt)}"
    '{SSHA}' + Base64.encode64(Digest::SHA1.digest(txt + salt) + salt).chomp! 
  end

  def nt_password(txt, txt_encoding = 'UTF-8')
    txt_ucs2 = txt.encode("UTF-16LE", txt_encoding)
    OpenSSL::Digest::MD4.new(txt_ucs2).hexdigest.upcase
  end

  # return nil or error message string
  def change_password(username, oldpw, newpw)

    user_dn = "uid=#{username},#{config['ldap_user_base_dn']}"
    ldap = Net::LDAP.new(
      host: config['ldap_host'], port: config['ldap_port'],
      auth: {
        username: user_dn, password: oldpw, method: config['ldap_auth_method']
      },
      encryption: :simple_tls
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
end
