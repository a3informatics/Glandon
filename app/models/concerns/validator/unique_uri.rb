# Field Validator Uniqueness. Checks if the record is unique.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::UniqueUri < ActiveModel::Validator
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return true if record.class.uri_unique(record.uri)
    record.errors.add :base, "#{record.uri} already exists in the database"
    return false
  end
  
end