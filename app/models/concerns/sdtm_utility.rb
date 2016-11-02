module SdtmUtility

  C_CLASS_NAME = "SdtmUtility"
  C_PREFIX = "--"

  # Test if prefixed
  #
  # @param name [string] The variable name
  # @return Returns true/false
  def self.prefixed?(name)
    return name[0,2] == C_PREFIX ? true : false
  end

  # Replace prefix
  #
  # @param name [string] The variable name
  # @return Returns the updated name with "--" "replaced with xx" as a prefix
  def self.replace_prefix(name)
    return name.gsub(C_PREFIX, "xx")
  end

  # Overwrite prefix
  #
  # @param name [string] The variable name
  # @param prefix [string] The new prefix
  # @return Returns the updated name with the specified prefix
  def self.overwrite_prefix(name, prefix)
    name[0,2] = prefix
    return name
  end

  # Add prefix
  #
  # @param name [string] The variable name
  # @return Returns the updated name with "--" as the prefix
  def self.add_prefix(name)
    return "#{C_PREFIX}#{name}"
  end

  # Set prefix
  #
  # @param prefixed [string] Prefixed flag
  # @param name [string] The variable name
  # @return Returns the updated name with "--" as the prefix if the variable is prefixed
  def self.set_prefix(prefixed, name)
    if prefixed
      name[0,2] = C_PREFIX
    end
    return name
  end
end

    