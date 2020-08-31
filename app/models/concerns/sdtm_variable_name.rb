class SdtmVariableName

  C_GENERIC_PREFIX = "--"
  C_ALPHA_PREFIX = "xx"

  def initialize(name, domain_prefix="")
    set_data(name, domain_prefix)
  end

  # Name
  #
  # @return returns the name
  def name
    "#{@domain_prefix}#{@stem}"
  end

  # Prefixed?
  #
  # @return returns true if prefixed, otherwise false
  def prefixed?
    @prefixed
  end

  # Alpha Prefix
  #
  # @return returns the name with the generic prefix if prefixed, otherwise the name
  def alpha_prefix
    @prefixed ? "#{C_ALPHA_PREFIX}#{@stem}" : @stem
  end

  # Generic Prefix
  #
  # @return returns the name with the generic prefix if prefixed, otherwise the name
  def generic_prefix
    @prefixed ? "#{C_GENERIC_PREFIX}#{@stem}" : @stem
  end

  # With Prefix
  #
  # @param [String] prefix the new prefix
  # @return returns the name with the specified prefix if prefixed, otherwise the name.
  def with_prefix(prefix)
    @prefixed ? "#{prefix}#{@stem}" : @stem
  end

private

  # Initialise class data
  def set_data(name, domain_prefix)
    if name[0,2] == C_GENERIC_PREFIX
      @stem = name[2..-1]
      @prefixed = true
      @domain_prefix = ""
    elsif name[0, 2] == domain_prefix
      @stem = name[2..-1]
      @prefixed = true
      @domain_prefix = domain_prefix
    else  
      @stem = name
      @prefixed = false
      @domain_prefix = ""
    end
  end

end

    