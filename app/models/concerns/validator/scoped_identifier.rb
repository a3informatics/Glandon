# Scoped Identifier Validator. Checks if the record is unique.
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class Validator::ScopedIdentifier < ActiveModel::Validator
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    return true if !record.class.exists?(record.identifier, record.has_scope)
    record.errors.add :base, 'The scoped identifier is already in use'
    return false
  end
  
end