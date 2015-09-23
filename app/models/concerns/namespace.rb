module Namespace

  @@optional = 
    { "isoB" => "http://www.assero.co.uk/ISO11179Basic" ,
      "isoI" => "http://www.assero.co.uk/ISO11179Identification" ,
      "isoR" => "http://www.assero.co.uk/ISO11179Registration" , 
      "iso25964" => "http://www.assero.co.uk/ISO25964" , 
      "org" => "http://www.assero.co.uk/MDROrganizations" ,
      "th" => "http://www.assero.co.uk/MDRThesaurus" }

  @@required = 
    { "rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns" ,
      "rdfs" => "http://www.w3.org/2000/01/rdf-schema" ,
      "xsd" => "http://www.w3.org/2001/XMLSchema" ,
      "skos" => "http://www.w3.org/2004/02/skos/core" }
  
  def Namespace.getPrefix(ns)

    return @@optional.key(ns)

  end
    
  def Namespace.getNs(prefix)
    
    return @@optional[prefix]
  
  end
        
  def Namespace.buildPrefix(defaultNsPrefix, optional)
  
    p "[Namespace           ][buildPrefix        ] defaultNsPrefix=" + defaultNsPrefix
    p "[Namespace           ][buildPrefix        ] optional=" + optional.to_s
    
    if defaultNsPrefix == ""
      result = ""
    else
      result = formEntry("", @@optional[defaultNsPrefix])
    end
    result = result + buildPrefixes(optional)
    return result
    
  end
  
  def Namespace.buildNs(defaultNs, optional)
  
    p "[Namespace           ][buildPrefix        ] defaultNs=" + defaultNs
    p "[Namespace           ][buildPrefix        ] optional=" + optional.to_s
    
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
