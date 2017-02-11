module FieldValidation

  C_CLASS_NAME = "FieldValidation"
  C_ALPHA_NUMERICS = "a-zA-Z0-9"
  C_ALPHA_NUMERICS_SPACE = "#{C_ALPHA_NUMERICS} "
  C_FREE_TEXT = "#{C_ALPHA_NUMERICS} .!?,'\"_\\-\\/\\\\()\\[\\]~#*+@=:;&|<>"
  C_TC_PART = "[#{C_ALPHA_NUMERICS}]+"
  C_IDENTIFIER = "[#{C_ALPHA_NUMERICS_SPACE}]+"
  C_MARKDOWN = "[#{C_FREE_TEXT}\r\n]*"
  C_LONG_NAME = "[#{C_FREE_TEXT}]+"
  C_TERM_PROPERTY = "[#{C_FREE_TEXT}]*"
  C_QUESTION = "[#{C_FREE_TEXT}]*"
  C_LABEL = "[#{C_FREE_TEXT}]*"
  C_SUBMISSION = "[#{C_FREE_TEXT}^]+" # Free text plus ^
  C_SDTM_LABEL = "[#{C_FREE_TEXT}]{1,40}"
  C_SDTM_NAME = "[A-Z][A-Z0-9]{0,7}"
  C_MAPPING = "[#{C_FREE_TEXT}]*"
  
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
      return true if value =~ /\A#{C_IDENTIFIER}\z/
      object.errors.add(symbol, "contains invalid characters")
      return false
    end
  end

  # Valid Thesaurus Concept Identifier
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_tc_identifier?(symbol, value, object)
    if value.blank?
      object.errors.add(symbol, "is empty")
      return false
    else
      if value[-1] == '.'
        object.errors.add(symbol, "contains an empty part")
        return false
      else
        parts = value.split('.')
        parts.each do |part|
          if part.blank?
            object.errors.add(symbol, "contains an empty part")
            return false
          else
            if part =~ /\A#{C_TC_PART}\z/
            else
              object.errors.add(symbol, "contains a part with invalid characters")
              return false
            end
          end
        end
      end
      return true
    end
  end

  # Valid SDTM Domain Prefix
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_sdtm_domain_prefix?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      result = value.match /\A[A-Z]{2}\z/ 
      return true if result != nil
      object.errors.add(symbol, "contains invalid characters, is empty or is too long")
      return false
    end
  end

  # Valid SDTM Variable
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_sdtm_variable_name?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      return true if value =~ /\A#{C_SDTM_NAME}\z/
      object.errors.add(symbol, "contains invalid characters, is empty or is too long")
      return false
    end
  end

  # Valid SDTM Label
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_sdtm_variable_label?(symbol, value, object)
    if value.nil?
      object.errors.add(symbol, "is empty")
      return false
    else
      return true if value =~ /\A#{C_SDTM_LABEL}\z/ 
      object.errors.add(symbol, "contains invalid characters, is empty or is too long")
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
      object.errors.add(symbol, "contains invalid characters, must be an integer")
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
      object.errors.add(symbol, "contains invalid characters")
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
    return true if value =~ /\A#{C_LONG_NAME}\z/
    object.errors.add(symbol, "contains invalid characters or is empty")
    return false
  end

  # Valid Submission Value
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_submission_value?(symbol, value, object)
    #result = value.match /^\A[A-Za-z0-9 ]*\z/ 
    #return true if result != nil
    #object.errors.add(symbol, "contains invalid characters")
    #return false
    return true if value =~ /\A#{C_SUBMISSION}\z/
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid SDTM Format Value
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_sdtm_format_value?(symbol, value, object)
    if !value.nil?
      return true if ['ISO 8601', 'ISO 3166', ''].include? value
      object.errors.add(symbol, "contains an invalid value")
      return false
    else
      object.errors.add(symbol, "is not set")
      return false
    end
  end

  # Valid Terminology Property
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_terminology_property?(symbol, value, object)
    return true if value =~ /\A#{C_TERM_PROPERTY}\z/
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Label
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_label?(symbol, value, object)
    return true if value =~ /\A#{C_LABEL}\z/
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Question
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_question?(symbol, value, object)
    return true if value =~ /\A#{C_QUESTION}\z/
    object.errors.add(symbol, "contains invalid characters")
    return false
  end

  # Valid Mapping
  #
  # @param symbol [String] The item being checked
  # @param value [String] The value being checked
  # @param object [Object] The object to which the value/item belongs
  # @return [Boolean] true if value valid, false otherwise
  def self.valid_mapping?(symbol, value, object)
    return true if value =~ /\A#{C_MAPPING}\z/ 
    object.errors.add(symbol, "contains invalid characters")
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
    object.errors.add(symbol, "contains invalid characters")
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
    object.errors.add(symbol, "contains invalid characters")
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
    return true if value =~ /^\A#{C_MARKDOWN}\z/
    object.errors.add(symbol, "contains invalid markdown")
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
