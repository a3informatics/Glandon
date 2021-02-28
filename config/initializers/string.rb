class String
  
  # Trims specified character from end of string
  def trim sep=/\s/
    sep_source = sep.is_a?(Regexp) ? sep.source : Regexp.escape(sep)
    pattern = Regexp.new("\\A(#{sep_source})*(.*?)(#{sep_source})*\\z")
    self[pattern, 2]
  end

  # Remove the quotes from either end of the inpsect generated string.
  def trim_inspect_quotes
    self[1...-1]
  end

  # Space separted string into variable style 
  #
  # @example "So This" turns into "so_this"
  def to_variable_style
    self.gsub(/( )/, '_').downcase
  end

  # Variable style to uppercase, space separated
  #
  # @example "so_this" turns into "SO THIS"
  def from_variable_style
    self.gsub(/(_)/, ' ').upcase
  end

  # To Alphanumeric
  #
  # @param text [String] the text to be cleaned
  # @return [String] the cleaned text
  def to_alphanumeric
    self.dup.gsub(/[^A-Z0-9a-z]/i, '').upcase.strip
  end
  
end