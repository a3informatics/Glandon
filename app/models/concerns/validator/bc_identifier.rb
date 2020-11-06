# BC Identifier Validator. Checks if identifier is required and doesn't have multiple coded values
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::BcIdentifier < Validator::Base
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return true if record.valid_parent?
    failed(record, 'attempting to add multiple coded values')
  end
  
end