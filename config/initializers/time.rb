class String
  
  C_DEFAULT_DATETIME = "2016-01-01T00:00:00+00:00"
  
  def to_time_with_default
    return Time.parse(self) if (self =~ /\A\d{4}-\d{2}-\d{2}\z/).nil?
    return Time.parse("#{self}T00:00:00+00:00")
  rescue => e
    return Time.parse(C_DEFAULT_DATETIME)
  end

end