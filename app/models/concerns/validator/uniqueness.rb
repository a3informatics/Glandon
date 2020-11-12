# Field Validator Uniqueness. Checks if the record is unique.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::Uniqueness < Validator::Base
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return true if record.class.where({options[:attribute] => record.send(options[:attribute])}).empty?
    failed(record, "an existing record (#{options[:attribute]}: #{record.send(options[:attribute])}) exisits in the database")
  end
  
end