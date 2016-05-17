module FieldValidation

  C_CLASS_NAME = "FieldValidation"

  def self.valid_identifier?(symbol, value, object)
    result = value.match /\A[A-Za-z0-9 ]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  def self.valid_short_name?(symbol, value, object)
    result = value.match /\A[A-Za-z0-9]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  def self.valid_free_text?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  def self.valid_label?(symbol, value, object)
    return validFreeText?(:label, value, object)
  end

end
