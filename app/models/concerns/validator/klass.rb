# Class Validator. Check a class is valid
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::Klass < ActiveModel::Validator
  
  # Validate
  #
  # @param record [Object] the rails object containing the object to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    property_name = options[:property]
    level = options[:level]
    item = record.send(property_name)
    return false if nil_item?(item, record, property_name)
    return array_valid?(item, record, property_name, level) if item.is_a? Array
    return item_valid?(item, record, property_name, level)
  end

private

  # Array valid
  def array_valid?(items, record, property_name, level)
    items.each_with_index do |item, index| 
      item.errors.full_messages.each do |msg| 
        record.errors[:base] << "#{property_name.to_s.humanize}, ordinal #{index+1}: #{msg}" if uri_item_valid?(item, record, property_name, level)
      end
    end
  end

  # Single item valid
  def item_valid?(item, record, property_name, level)
    return true if uri_item_valid?(item, record, property_name, level)
    item.errors.full_messages.each {|msg| record.errors[:base] << "#{property_name.to_s.humanize}: #{msg}"}
    return false
  end

  # Is it a nil
  def nil_item?(item, record, property_name)
    return false if !item.nil?
    record.errors[:base] << "#{property_name.to_s.humanize}: Empty object"
    return true
  end

  # URI check
  def uri_item_valid?(item, record, property_name, level)
    return uri_valid?(property_name, item, record) if item.is_a? Uri
    return uri_valid?(property_name, item.uri, record) if level == :uri
    return item.valid?
  end

  # URI valid. Just assume it is at the moment.
  # @todo - Think this through
  def uri_valid?(item, record, property_name)
    true
  end

end