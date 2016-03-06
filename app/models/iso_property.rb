class IsoProperty

  # Constants
  C_CLASS_NAME = "IsoProperty"
  C_CID_PREFIX = "ISOP"
  
  def initialize
    @properties = Array.new
  end

  def all
    return @properties
  end
  
  def get(prefix, type)
    results = []
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    p = @properties.select {|prop| prop[:rdfType] == uri.all} 
    #if p.length > 0
    #  results = p.map { |prop| { value: prop[:value], label: prop[:label] } }
      #@properties = @properties.reject {|prop| prop[:rdfType] == uri.all}
    #end
    #return results
    return p
  end

  def getOnly(prefix, type)
    results = get(prefix, type)
    if results.length == 1
      return results[0]
    else
      result = {}
      return result
    end
  end

  def exists?(prefix, type)
    ns = UriManagement.getNs1(prefix)
    uri = Uri.new
    uri.setNsFragment(ns, type)
    p = @properties.select {|prop| prop[:rdfType] == uri.all} 
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","p=" + p.to_s)
    if p.length == 0
      return false
    else
      return true
    end
  end

  def set(predicate, objectLiteral, label)
    @properties << {:rdfType => predicate, :value => objectLiteral, :label => label}
    #ConsoleLogger::log(C_CLASS_NAME,"set","@property=" + @property.to_s)
  end

end