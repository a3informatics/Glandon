module FieldValidation

  C_CLASS_NAME = "FieldValidation"

  # Valid Identifier
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
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

  # Valid Domain Prefix
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_domain_prefix?(symbol, value, object)
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

  # Valid Version
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_version?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      result = "#{value}".match /\A[0-9]+\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters, must be an integer")
      return false
    end
  end

  # Valid Short Name
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
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

  # Valid Free Text
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_free_text?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]+\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  # Valid Label
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_label?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9.!?,_ \-()]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Question
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_question?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .?,\-:;]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Mapping
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_mapping?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .=]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Format
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_format?(symbol, value, object)
    return true if value.empty?
    result = value.match /^\A^\d+(\.\d+)?\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Generic Datatype
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_datatype?(symbol, value, object)
    return BaseDatatype.valid?(value)
  end

  # Valid Date
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
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
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Date Time
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_date_time?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty.")
      return false
    else
      #DateTime.parse(value)
      DateTime.strptime(value, '%Y-%m-%dT%H:%M:%S%z')
      return true
    end
  rescue ArgumentError => e 
    object.errors.add(symbol, "contains invalid format date time")
    return false
  end

  # Valid Markdown
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_markdown?(symbol, value, object)
    result = value.match /^\A[A-Za-z0-9 .!?,'"_\-\/\\()\[\]~#*=:;&|\r\n]*\z/ 
    return true if result != nil
    object.errors.add(symbol, "contains invalid markdown")
    return false
  end

  # Valid Files
  #
  # @param symbol [string] The item being checked
  # @param value [string] The value being checked
  # @param object [object] The object to which the value/item belongs
  # @return [boolean] True if value valid, false otherwise
  def self.valid_files?(symbol, value, object)
    if value.blank? 
      object.errors.add(symbol, "is empty.")
      return false
    else
      return true
    end
  end

end
