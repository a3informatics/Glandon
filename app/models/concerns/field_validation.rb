module FieldValidation

  C_CLASS_NAME = "FieldValidation"

  def self.valid_identifier?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      result = value.match /\A[A-Za-z0-9 ]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters")
      return false
    end
  end

  def self.valid_domain_prefix?(symbol, value, object)
    ConsoleLogger::log(C_CLASS_NAME,"valid_domain_prefix","Symbol=#{symbol}, Value=#{value}")
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      result = value.match /\A[A-Z]{2}\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters")
      return false
    end
  end

  def self.valid_version?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      result = value.match /\A[0-9]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters, must be an integer")
      return false
    end
  end

  def self.valid_short_name?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      result = value.match /\A[A-Za-z0-9]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters")
      return false
    end
  end

  def self.valid_free_text?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  def self.valid_label?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  def self.valid_date?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      format="%Y-%m-%d"
      ConsoleLogger::log(C_CLASS_NAME,"valid_date","Date=" + value.to_s)
      Date.strptime(value, format) 
      return true
    end
  rescue => e 
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  def self.valid_files?(symbol, value, object)
    if value.blank? 
      object.errors.add(symbol, "is empty.")
      return false
    else
      return true
    end
  end

end
