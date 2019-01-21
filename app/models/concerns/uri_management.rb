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
  C_BCR = "bcr"
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
  C_OWL = "owl"
  
  # Prefix to namespace map. Optional Set.
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
      C_BCR => "http://www.assero.co.uk/BusinessCrossReference" ,
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
      C_MDR_TH => "http://www.assero.co.uk/MDRThesaurus",
      C_OWL => "http://www.w3.org/2002/07/owl"
     }

  # Prefix to namespace map. Required Set.
  @@required = 
    { C_RDF => "http://www.w3.org/1999/02/22-rdf-syntax-ns" ,
      C_RDFS => "http://www.w3.org/2000/01/rdf-schema" ,
      C_XSD => "http://www.w3.org/2001/XMLSchema" ,
      C_SKOS => "http://www.w3.org/2004/02/skos/core" }
  
  # Get the optional namespaces
  #
  # @return [hash] The set of optional namespaces
  def UriManagement.get()
    return @@optional
  end

  # Get the required namespaces
  #
  # @return [Hash] the set of required namespaces
  def UriManagement.required
    return @@required
  end

  # Get Prefix for a namespace
  #
  # @param namespace [string] The namespace
  # @return [string] The prefix
  def UriManagement.getPrefix(namespace)
    prefix = @@optional.key(namespace)
    if prefix == nil
      prefix = @@required.key(namespace)
    end
    return prefix
  end
    
  # Get Namespace for a prefix
  #
  # @param prefix [string] The prefix
  # @return [string] The namespace
  def UriManagement.getNs(prefix)
    namespace = @@optional[prefix]
    if namespace == nil 
      namespace = @@required[prefix]
    end
    return namespace
  end
        
  # Build Prefix
  #
  # @param default_prefix [string] The prefix
  # @return [string] The namespace
  def UriManagement.buildPrefix(default_prefix, optional)
    if default_prefix == ""
      result = ""
    else
      result = formEntry("", @@optional[default_prefix])
    end
    result = result + buildPrefixes(optional)
    return result
  end
  
  # Build Namespace list
  #
  # @param default_namespace [string] The prefix
  # @param optional [array] Array of namespace prefixes
  # @return [string] The list of namespaces
  def UriManagement.buildNs(default_namespace, optional)
    if default_namespace == ""
      result = ""
    else
      result = formEntry("", default_namespace)
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
