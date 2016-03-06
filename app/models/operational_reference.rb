class OperationalReference < IsoConcept

  attr_accessor :concept, :property, :value, :enabled
  validates_presence_of :concept, :property, :value, :enabled

  # Constants
  C_SCHEMA_PREFIX = "bo"
  C_CLASS_NAME = "OperationalReference"
  C_RDF_TYPE = "BcReference"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
  def self.find(id, ns)
    object = super(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"find","enabled=" + object.to_json)
    object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enabled")[:value])
    #ConsoleLogger::log(C_CLASS_NAME,"find","enabled=" + object.enabled.to_s)
    object.concept = getReference(object, "hasBiomedicalConcept")
    object.property = getReference(object, "hasProperty")
    object.value = getReference(object, "hasValue")
    return object
  end

private

  def self.getReference(object, rdfType)
    reference = nil
    if object.links.exists?(C_SCHEMA_PREFIX, rdfType)
      links = object.links.get(C_SCHEMA_PREFIX, rdfType)
      if links[0] != ""
        if rdfType == "hasBiomedicalConcept"
          reference = BiomedicalConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        elsif rdfType == "hasProperty"
          reference = BiomedicalConceptCore::Property.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        else
          reference = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        end
      end
    end
    return reference
  end

end