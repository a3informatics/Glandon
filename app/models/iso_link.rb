class IsoLink

  # Constants
  C_CLASS_NAME = "IsoLink"
  C_CID_PREFIX = "ISOL"

  def initialize
    @links = Array.new
  end

  def get(prefix, type)
    results = []
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    #ConsoleLogger::log(C_CLASS_NAME,"get","ns=" + ns)
    #ConsoleLogger::log(C_CLASS_NAME,"get","uri=" + uri.all)
    l = @links.select {|link| link[:rdfType] == uri.all } 
    if l.length > 0
      #ConsoleLogger::log(C_CLASS_NAME,"get","Found")
      results = l.map { |link| link[:value] }
      @links = @links.reject { |link| link[:rdfType] == uri.all }
    end
    #ConsoleLogger::log(C_CLASS_NAME,"get","results=" + results.to_s)
    return results
  end

  def exists?(prefix, type)
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    l = @links.select {|link| link[:rdfType] == uri.all } 
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","l=" + l.to_s)
    if l.length == 0
      return false
    else
      return true
    end
  end

  def set(predicate, objectLiteral)
    link = Hash.new
    link[:rdfType] = predicate
    link[:value] = objectLiteral
    @links << link
    #ConsoleLogger::log(C_CLASS_NAME,"set","@links=" + @links.to_s)
  end

end