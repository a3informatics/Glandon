module UriManagement

  @@optional = 
    { "isoB" => "http://www.assero.co.uk/ISO11179Basic" ,
      "isoI" => "http://www.assero.co.uk/ISO11179Identification" ,
      "isoR" => "http://www.assero.co.uk/ISO11179Registration" , 
      "isoC" => "http://www.assero.co.uk/ISO11179Concepts" , 
      "isoT" => "http://www.assero.co.uk/ISO11179Types" , 
      "iso25964" => "http://www.assero.co.uk/ISO25964" , 
      "cbc" => "http://www.assero.co.uk/CDISCBiomedicalConcept",
      "bo" => "http://www.assero.co.uk/BusinessOperational" ,
      "bf" => "http://www.assero.co.uk/BusinessForm" ,
      "bd" => "http://www.assero.co.uk/BusinessDomain" ,
      "bs" => "http://www.assero.co.uk/BusinessStandard" ,
      "mms" => "http://rdf.cdisc.org/mms" ,
      "cdisc" => "http://rdf.cdisc.org/std/schema" ,
      "mdrItems" => "http://www.assero.co.uk/MDRItems" ,
      "mdrBridg" => "http://www.assero.co.uk/MDRBRIDG" ,
      "mdrBcs" => "http://www.assero.co.uk/MDRCDISCBC" ,
      "mdrForms" => "http://www.assero.co.uk/MDRForms" ,
      "mdrSch" => "http://www.assero.co.uk/MDRSchemes" ,
      "mdrDomains" => "http://www.assero.co.uk/MDRDomains" ,
      "mdrStds" => "http://www.assero.co.uk/MDRStandards" ,
      "mdrTh" => "http://www.assero.co.uk/MDRThesaurus"
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
