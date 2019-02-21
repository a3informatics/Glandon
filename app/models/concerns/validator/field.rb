# Field Validator. Check a field is valid
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::Field < ActiveModel::Validator
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return FieldValidation.send(options[:method], options[:attribute], record.send(options[:attribute]), record)
  end
  
end