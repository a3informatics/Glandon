class String
  
  def trim sep=/\s/
    sep_source = sep.is_a?(Regexp) ? sep.source : Regexp.escape(sep)
    pattern = Regexp.new("\\A(#{sep_source})*(.*?)(#{sep_source})*\\z")
    self[pattern, 2]
  end

end