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
      "xsd" => "http://www.w3.org/2001/XMLSchema" }
  
  def Namespace.find(prefix)
    
    return @@optional[prefix]
  
  end
        
  def Namespace.add(prefix,ns)
    
    @@optional.store(prefix,ns)
    
  end
  
  def Namespace.build(defaultNS, optional)
  
    if defaultNS == ""
      result = ""
    else
      result = formEntry("", @@optional[defaultNS])
    end
    optional.each do |key|
      result = result + formEntry(key,@@optional[key])
    end
    @@required.each do |key,value|
      result = result + formEntry(key,value)
    end
    return result
    
  end
  
  private
  
  def self.formEntry(prefix,ns)

    result = "PREFIX " + prefix + ": <" + ns + "#>" + "\n"
  
  end

end
