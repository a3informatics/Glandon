require "uri"

class BiomedicalConceptTemplate < BiomedicalConceptCore
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcts"
  C_CLASS_NAME = "BiomedicalConceptTemplate"
  C_CID_PREFIX = "BCT"
  C_RDF_TYPE = "BiomedicalConceptTemplate"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    return object 
  end

  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = super
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    #ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.list
    #ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end 

  def to_api_json
    result = super
    result[:type] = "Biomedical Concept Template"
    result[:template] = { :id => self.id, :namespace => self.namespace, :identifier => self.identifier, :label => self.label }
    return result
  end
  
end
