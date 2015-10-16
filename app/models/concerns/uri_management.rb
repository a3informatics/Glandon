module UriManagement

  @@optional = 
    { "isoB" => "http://www.assero.co.uk/ISO11179Basic" ,
      "isoI" => "http://www.assero.co.uk/ISO11179Identification" ,
      "isoR" => "http://www.assero.co.uk/ISO11179Registration" , 
      "isoC" => "http://www.assero.co.uk/ISO11179Concepts" , 
      "iso25964" => "http://www.assero.co.uk/ISO25964" , 
      "cbc" => "http://www.assero.co.uk/CDISCBiomedicalConcept",
      "bo" => "http://www.assero.co.uk/BusinessOperational" ,
      "bf" => "http://www.assero.co.uk/BusinessForm" ,
      "mdrBridg" => "http://www.assero.co.uk/MDRBRIDG" ,
      "mdrBc" => "http://www.assero.co.uk/MDRCDISCBC" ,
      "mdrForm" => "http://www.assero.co.uk/MDRFORMs" ,
      "mdrSch" => "http://www.assero.co.uk/MDRSchemes" ,
      "item" => "http://www.assero.co.uk/MDRItems" ,
      "th" => "http://www.assero.co.uk/MDRThesaurus",
     }

  @@required = 
    { "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns" ,
      "rdfs" => "http://www.w3.org/2000/01/rdf-schema" ,
      "xsd" => "http://www.w3.org/2001/XMLSchema" ,
      "skos" => "http://www.w3.org/2004/02/skos/core" }
  
  def UriManagement.getPrefix(ns)
    return @@optional.key(ns)
  end
    
  def UriManagement.getNs(prefix)
    return @@optional[prefix]
  end
        
  def UriManagement.buildPrefix(defaultNsPrefix, optional)
    if defaultNsPrefix == ""
      result = ""
    else
      result = formEntry("", @@optional[defaultNsPrefix])
    end
    result = result + buildPrefixes(optional)
    return result
  end
  
  def UriManagement.buildNs(defaultNs, optional)
    if defaultNs == ""
      result = ""
    else
      result = formEntry("", defaultNs)
    end
    result = result + buildPrefixes(optional)
    return result
  end
  
private
  
  def self.buildPrefixes(optional)
    result = ""
    optional.each do |key|
      result = result + formEntry(key,@@optional[key])
    end
    @@required.each do |key,value|
      result = result + formEntry(key,value)
    end
    return result
  end
  
  def self.formEntry(prefix,ns)
    result = "PREFIX " + prefix + ": <" + ns + "#>" + "\n"
  end

end
