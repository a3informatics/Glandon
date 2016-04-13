class OperationalReference < IsoConceptNew

  attr_accessor :concept, :property, :value, :enabled
  validates_presence_of :concept, :property, :value, :enabled

  # Constants
  C_SCHEMA_PREFIX = "bo"
  C_CLASS_NAME = "OperationalReference"
  C_RDF_TYPE = "BcReference"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.concept = nil
    self.property = nil
    self.value = nil
    if triples.nil?
      super
      self.enabled = true
    else
      super(triples, id)
    end        
  end

  def self.find(id, ns)
    object = super(id, ns)
    #object.enabled = ModelUtility.toBoolean(object.properties.getOnly(C_SCHEMA_PREFIX, "enabled")[:value])
    object.concept = getReference(object, "hasBiomedicalConcept")
    object.property = getReference(object, "hasProperty")
    object.value = getReference(object, "hasValue")
    return object
  end

  def self.find_from_triples(triples, id, bc=nil)
    object = new(triples, id)
    object.concept = getReference(object, "hasBiomedicalConcept")
    object.property = getReference(object, "hasProperty", bc)
    object.value = getReference(object, "hasValue")
    object.triples = ""
    return object
  end

private

  def self.getReference(object, rdf_type, bc=nil)
    reference = nil
    if object.link_exists?(C_SCHEMA_PREFIX, rdf_type)
      links = object.get_links(C_SCHEMA_PREFIX, rdf_type)
      if links[0] != ""
        if rdf_type == "hasBiomedicalConcept"
          reference = BiomedicalConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
        elsif rdf_type == "hasProperty"
          if bc != nil
            reference = bc.find_item(ModelUtility.extractCid(links[0]))
          else
            reference = BiomedicalConceptCore::Property.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]))
          end
        else
          reference = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]), false)
        end
      end
    end
    return reference
  end

end