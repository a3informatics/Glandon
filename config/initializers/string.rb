class String
  
  # Trims specified character from end of string
  def trim sep=/\s/
    sep_source = sep.is_a?(Regexp) ? sep.source : Regexp.escape(sep)
    pattern = Regexp.new("\\A(#{sep_source})*(.*?)(#{sep_source})*\\z")
    self[pattern, 2]
  end

  # Remove the quotes from either end of the inpsect geenrated string.
  def trim_inspect_quotes
    self[1...-1]
  end

end