class CdiscCli < ThesaurusConcept
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_CLASS_NAME = "CdiscCli"
  C_RDF_TYPE = "ThesaurusConcept"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
end
