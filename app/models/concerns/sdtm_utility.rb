module SdtmUtility

  C_CLASS_NAME = "SdtmUtility"
  C_PREFIX = "--"

  # Test if prefixed
  def self.prefixed?(name)
    return name[0,2] == C_PREFIX ? true : false
  end

  # Replace prefix
  def self.replace_prefix(name)
    return name.gsub(C_PREFIX, "xx")
  end

  # Overwrite prefix
  def self.overwrite_prefix(name, prefix)
    name[0,2] = prefix
    return name
  end

  # Add prefix
  def self.add_prefix(name)
    return "#{C_PREFIX}#{name}"
  end

  # Set prefix
  def self.set_prefix(prefixed, name)
    ConsoleLogger::log(C_CLASS_NAME,"set_prefix","Prefixed=#{prefixed}, Name=#{name}")
    if prefixed
      name[0,2] = C_PREFIX
    end
    ConsoleLogger::log(C_CLASS_NAME,"set_prefix","Return=#{name}")
    return name
  end
end

    