class Triples

  C_CLASS_NAME = "Triples"

  # Get Property Value from a set of triples
  #
  # @param triples [hash] Hash containing multiple triples keyed by id
  # @param prefix [string] The uri namespace prefix
  # @param type [string] The uri fragment (type)
  # @return [string] The property value
  def self.get_property_value(triples, prefix, type)
    namespace = UriManagement.getNs(prefix)
    uri = UriV2.new({:id => type, :namespace => namespace})
    results = triples.select {|prop| prop[:predicate] == uri.to_s} 
    if results.length == 1
      return results[0][:object]
    else
      result = ""
      return result
    end
  end

  # Link Exists in a set of triples
  #
  # @param triples [hash] Hash containing multiple triples keyed by id
  # @param prefix [string] The uri namespace prefix
  # @param type [string] The uri fragment (type)
  # @return [boolean] True if found, false otherwise
  def self.link_exists?(triples, prefix, type)
    namespace = UriManagement.getNs(prefix)
    uri = UriV2.new({:id => type, :namespace => namespace})
    l = triples.select {|triple| triple[:predicate] == uri.to_s } 
    if l.length == 0
      return false
    else
      return true
    end
  end

  # Get Links from a set of triples
  #
  # @param triples [hash] Hash containing multiple triples keyed by id
  # @param prefix [string] The uri namespace prefix
  # @param type [string] The uri fragment (type)
  # @return [array] Array of uri objects
  def self.get_links(triples, prefix, type)
    results = []
    namespace = UriManagement.getNs(prefix)
    uri = UriV2.new({:id => type, :namespace => namespace})
    l = triples.select {|triple| triple[:predicate] == uri.to_s } 
    if l.length > 0
      results = l.map { |triple| triple[:object] }
    end
    return results
  end

end

    