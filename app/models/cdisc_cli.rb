class CdiscCli < ThesaurusConcept
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_CLASS_NAME = "CdiscCli"
  C_RDF_TYPE = "ThesaurusConcept"

  # Base namespace 
  @@schemaNs = UriManagement.getNs(C_SCHEMA_PREFIX)
  @@instanceNs = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.diff? (cliA, cliB)
    #ConsoleLogger::log(C_CLASS_NAME,"diff?","*****Entry*****")
    result = super(cliA, cliB)
    return result
  end
  
  def self.find(id, ns)
    object = super(id, ns)
    return object
  end
  
end
