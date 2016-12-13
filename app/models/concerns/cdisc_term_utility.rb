module CdiscTermUtility

  # Constants
  C_CLASS_NAME = "CdiscTermHelpers"
  
  # Build a CLI key
  #
  # @param parent_identifier [String] The parent identifier
  # @param child_identifier [String] The child identifier
  # @return [Symbol] The key
  def self.cli_key(parent_identifier, child_identifier)
    return "#{parent_identifier}.#{child_identifier}".to_sym
  end

end
