# Validator Managed Concept: Checks if managed concept is valid as a collection
#
# @author Dave Iberson-Hurst
# @since 2.24.0
class Validator::ManagedConcept < ActiveModel::Validator
  
  # Validate
  #
  # @param record [Object] the rails object containing the field/attribute to be validated
  # @returns [Boolean] true if valid, false others. Errors set in record.
  def validate(record)
    record.valid_collection?
  end
  
end