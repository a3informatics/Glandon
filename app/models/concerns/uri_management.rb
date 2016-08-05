module UriManagement

  # Constants
  C_CLASS_NAME = "UriManagement"
  
  # Application namespace prefixes
  C_ISO_B = "isoB"
  C_ISO_I = "isoI"
  C_ISO_R = "isoR"
  C_ISO_C = "isoC"
  C_ISO_T = "isoT"
  C_CBC = "cbc"
  C_BO = "bo"
  C_BF = "bf"
  C_BD = "bd"
  C_ISO_25964 = "iso25964"
  C_ISO_21090 = "iso21090"
  C_MDR_ITEMS = "mdrItems"
  C_MDR_BCTS = "mdrBcts"
  C_MDR_BCS = "mdrBcs"
  C_MDR_F = "mdrForms"
  C_MDR_M = "mdrSDTMM"
  C_MDR_MD = "mdrSDTMMD"
  C_MDR_IG = "mdrSDTMIg"
  C_MDR_IGD = "mdrSDTMIgD"
  C_MDR_UD = "mdrSDTMUD"
  C_MDR_BRIDG = "mdrBridg"
  C_MDR_ISO21090 = "mdrIso21090"
  C_MDR_C = "mdrConcepts"
  C_MDR_TH =  "mdrTh"
  
  # Standard semantic schema prefixes
  C_RDF = "rdf"
  C_RDFS = "rdfs"
  C_XSD = "xsd"
  C_SKOS = "skos"
  
  @@optional = 
    { C_ISO_B => "http://www.assero.co.uk/ISO11179Basic" ,
      C_ISO_I => "http://www.assero.co.uk/ISO11179Identification" ,
      C_ISO_R => "http://www.assero.co.uk/ISO11179Registration" , 
      C_ISO_C => "http://www.assero.co.uk/ISO11179Concepts" , 
      C_ISO_T => "http://www.assero.co.uk/ISO11179Types" , 
      C_ISO_25964 => "http://www.assero.co.uk/ISO25964" , 
      C_ISO_21090 => "http://www.assero.co.uk/ISO21090" ,
      C_CBC => "http://www.assero.co.uk/CDISCBiomedicalConcept",
      C_BO => "http://www.assero.co.uk/BusinessOperational" ,
      C_BF => "http://www.assero.co.uk/BusinessForm" ,
      C_BD => "http://www.assero.co.uk/BusinessDomain" ,
      C_MDR_ITEMS => "http://www.assero.co.uk/MDRItems" ,
      C_MDR_C => "http://www.assero.co.uk/MDRConcepts" ,
      C_MDR_BRIDG => "http://www.assero.co.uk/MDRBRIDG" ,
      C_MDR_ISO21090 => "http://www.assero.co.uk/MDRISO21090" ,
      C_MDR_BCS => "http://www.assero.co.uk/MDRBCs" ,
      C_MDR_BCTS => "http://www.assero.co.uk/MDRBCTs" ,
      C_MDR_F => "http://www.assero.co.uk/MDRForms" ,
      C_MDR_M => "http://www.assero.co.uk/MDRSdtmM" ,
      C_MDR_MD => "http://www.assero.co.uk/MDRSdtmMd" ,
      C_MDR_IG => "http://www.assero.co.uk/MDRSdtmIg" ,
      C_MDR_IGD => "http://www.assero.co.uk/MDRSdtmIgD" ,
      C_MDR_UD => "http://www.assero.co.uk/MDRSdtmUD" ,
      C_MDR_TH => "http://www.assero.co.uk/MDRThesaurus"
     }

  @@required = 
    { C_RDF => "http://www.w3.org/1999/02/22-rdf-syntax-ns" ,
      C_RDFS => "http://www.w3.org/2000/01/rdf-schema" ,
      C_XSD => "http://www.w3.org/2001/XMLSchema" ,
      C_SKOS => "http://www.w3.org/2004/02/skos/core" }
  
  def UriManagement.get()
    return @@optional
  end

  def UriManagement.getPrefix(ns)
    return @@optional.key(ns)
  end
    
  def UriManagement.getPrefix1(ns)
    #ConsoleLogger::log(C_CLASS_NAME,"getPrefix1","Ns=" + ns)
    prefix = @@optional.key(ns)
    #ConsoleLogger::log(C_CLASS_NAME,"getPrefix1","Opt=" + prefix.to_s)
    if prefix == nil
      prefix = @@required.key(ns)
      #ConsoleLogger::log(C_CLASS_NAME,"getPrefix1","Reqd=" + prefix.to_s)
    end
    return prefix
  end
    
  def UriManagement.getNs(prefix)
    return @@optional[prefix]
  end
        
  def UriManagement.getNs1(prefix)
    ns = @@optional[prefix]
    if ns == nil 
      ns = @@required[prefix]
    end
    return ns
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
      if @@optional.has_key?(key)
        result = result + formEntry(key,@@optional[key])
      end
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
