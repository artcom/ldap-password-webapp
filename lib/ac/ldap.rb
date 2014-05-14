module Ac
  module Ldap
    require 'digest/sha1' 
    require 'base64' 
    require 'securerandom' 

    def salt_please(byte_count = 4)
      SecureRandom.random_bytes(byte_count) # 16) 
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
