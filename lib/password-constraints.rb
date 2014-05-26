module PasswordConstraints

  # returns array with error messages or nil
  def validate(new_pw, current = nil)
  
    return [] if ENV['LDAP_PASSWORD_SKIP_VALIDATION']

    checks = [
      ['new password must differ from current', 
        lambda {|current, new_pw| current.nil? || current != new_pw}], 

      ['must have 8 or more character', 
        lambda {|_, new_pw| 7 < new_pw.length}],

      ['must contain at least one digit', 
        lambda {|_, new_pw| 0 < new_pw.scan(/\d/).size}], 

      ['must contain at least one uppercase character', 
        lambda {|_, new_pw| 0 < new_pw.scan(/[A-Z]/).size}], 

      ['must contain at least one special ASCII character',
        lambda {|_, new_pw| 0 < new_pw.scan(/[\W]/).size}],
    ]

    # reduce list of checks into list of messages for failing tests
    checks.map {|msg, p| (!p.call(current, new_pw)) && msg || nil}.compact
  end

  extend(self)
end
