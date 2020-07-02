# Class Validator. Check a class is valid
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::Klass < Validator::Base
  
  # Validate
  #
  # @param record [Object] the rails object containing the object to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    property_name = options[:property]
    level = options[:level]
    presence = options[:presence]
    item = record.send(property_name)
    return array_valid?(item, record, property_name, level, presence) if item.is_a? Array
    return single_valid?(item, record, property_name, level, presence)
  end

private

  # Array valid
  def array_valid?(items, record, property_name, level, presence)
    result = true
    return true if items.empty? && !presence
    return false if array_nil_item?(items, record, property_name, presence)
    items.each_with_index do |item, index|
      next if item_valid?(item, record, property_name, level)
      item.errors.each do |field, msg| 
        record.errors[property_name] << "#{index+1}: #{msg}" 
      end
      result = false
    end
    result
  end

  # Single item valid
  def single_valid?(item, record, property_name, level, presence)
    return true if item.nil? && !presence
    return false if single_nil_item?(item, record, property_name, presence)
    return true if item_valid?(item, record, property_name, level)
    item.errors.each {|field, msg| record.errors[property_name] << "#{msg}"}
    false
  end

  # Is it a nil array item
  def array_nil_item?(item, record, property_name, presence)
    return false if !item.empty?
    return false if item.empty? && !presence
    record.errors[property_name] << "empty object"
    return true
  end

  # Is it a nil array item
  def single_nil_item?(item, record, property_name, presence)
    return false if !item.nil?
    record.errors[property_name] << "empty object"
    return true
  end

  # Single item valid
  def item_valid?(item, record, property_name, level)
    return uri_valid?(item, record, property_name) if item.is_a? Uri
    return uri_valid?(item.uri, record, property_name) if level == :uri
    return item.valid?
  end

  # URI valid. Just assume it is at the moment.
  # @todo - Think this through
  def uri_valid?(item, record, property_name)
    FieldValidation.valid_uri?(property_name, item.to_s, record)
  end

end