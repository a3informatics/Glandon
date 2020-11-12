# Field Validator Uniqueness. Checks if the record is unique.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::UniqueUri < Validator::Base
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return false if !FieldValidation.valid_uri?(:uri, record.uri.to_s, record)
    return true if record.class.uri_unique(record.uri)
    failed(record, "#{record.uri} already exists in the database")
  end
  
end