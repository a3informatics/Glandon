class Triples

  C_CLASS_NAME = "Triples"

  def self.get_property_value(triples, prefix, type)
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    results = triples.select {|prop| prop[:predicate] == uri.all} 
    if results.length == 1
      return results[0][:object]
    else
      result = ""
      return result
    end
  end

  def self.link_exists?(triples, prefix, type)
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    l = triples.select {|triple| triple[:predicate] == uri.all } 
    if l.length == 0
      return false
    else
      return true
    end
  end

  def self.get_links(triples, prefix, type)
    results = []
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    l = triples.select {|triple| triple[:predicate] == uri.all } 
    if l.length > 0
      results = l.map { |triple| triple[:object] }
    end
    return results
  end

end

    