class EmailSanitizer
  # Allowed characters are based on RFC3696 (http://tools.ietf.org/html/rfc3696)
  # Wikipedia also has a good concise section (http://en.wikipedia.org/wiki/Email_address#Syntax)
  NAME_REGEXP = /(?<name>[[:word:]]+((\s|-|'|!|#|\$|%|&|\+|\/|\^|\?)*([[:word:]]+))*)/
  def self.sanitize_name name
    name.to_s.match(NAME_REGEXP).try(:[], :name).to_s
  end

  def self.sanitize_email name, email
    "#{sanitize_name(name)} <#{email}>"
  end
end
