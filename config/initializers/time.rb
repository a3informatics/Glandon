class String
  
  C_DEFAULT_DATETIME = "2016-01-01T00:00:00+00:00"
  
  def to_time_with_default
    return Time.parse(self)
  rescue => e
    return Time.parse(C_DEFAULT_DATETIME)
  end

end