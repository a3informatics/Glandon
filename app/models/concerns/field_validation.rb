module FieldValidation

  C_CLASS_NAME = "FieldValidation"

  # Valid Identifier
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_identifier?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      result = value.match /\A[A-Za-z0-9 ]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains an invalid characters")
      return false
    end
  end

  # Valid Domain Prefix
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_domain_prefix?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      result = value.match /\A[A-Z]{2}\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains an invalid characters")
      return false
    end
  end

  # Valid Version
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_version?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      result = "#{value}".match /\A[0-9]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains an invalid characters, must be an integer")
      return false
    end
  end

  # Valid Short Name
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_short_name?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      result = value.match /\A[A-Za-z0-9]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains an invalid characters")
      return false
    end
  end

  # Valid Free Text
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_long_name?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters or is empty")
    return false
  end

  # Valid Submission Value
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_submission_value?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 ]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Terminology Property
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_terminology_property?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .!?,'"_\-\/\\()\[\]~#*=:;&|]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Label
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_label?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Question
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_question?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .?,\-:;]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Mapping
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_mapping?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .=]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Format
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_format?(symbol, value, object)
    return true if value.empty?
    result = value.match /^\A^\d+(\.\d+)?\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Generic Datatype
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_datatype?(symbol, value, object)
    return true if BaseDatatype.valid?(value)
    object.errors.add(symbol, "contains an invalid datatype")
    return false
  end

  # Valid Date
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_date?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      format="%Y-%m-%d"
      Date.strptime(value, format) 
      return true
    end
  rescue => e 
    object.errors.add(symbol, "contains an invalid characters")
    return false
  end

  # Valid Date Time
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_date_time?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      DateTime.strptime(value, '%Y-%m-%dT%H:%M:%S%z')
      return true
    end
  rescue ArgumentError => e 
    object.errors.add(symbol, "contains an invalid format date time")
    return false
  end

  # Valid Markdown
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_markdown?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .!?,'"_\-\/\\()\[\]~#*=:;&|\r\n]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains an invalid markdown")
    return false
  end

  # Valid Boolean
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_boolean?(symbol, value, object)
    if !value.nil?
      if value == true or value == false
        return true
      end
    end
    object.errors.add(symbol, "contains an invalid boolean value")
    return false
  end

  # Valid Integer
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_integer?(symbol, value, object)
    if !value.nil?
      if value.is_a? Integer
        return true
      end
    end
    object.errors.add(symbol, "contains an invalid integer value")
    return false
  end

  # Valid Positive Integer
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_positive_integer?(symbol, value, object)
    if !value.nil?
      if value.is_a? Integer
        return true if value > 0
      end
    end
    object.errors.add(symbol, "contains an invalid positive integer value")
    return false
  end

  # Valid Files
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_files?(symbol, value, object)
    if value.blank? 
      object.errors.add(symbol, "is empty")
      return false
    else
      return true
    end
  end

end
