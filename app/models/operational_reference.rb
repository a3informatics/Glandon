class OperationalReference < IsoConceptNew

  attr_accessor :reference_type, :thesaurus_concept, :biomedical_concept, :bc_property, :bc_value, :enabled, :optional
  #validates_presence_of :concept, :property, :value, :enabled

  # Constants
  C_NONE = "None"
  C_TC = "Thesaurus Concept"
  C_BC = "Biomedical Concept"
  C_SCHEMA_PREFIX = "bo"
  C_CLASS_NAME = "OperationalReference"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.biomedical_concept = nil
    self.bc_property = nil
    self.bc_value = nil
    self.thesaurus_concept = nil
    self.enabled = true
    self.optional = false
    self.reference_type = C_NONE
    if triples.nil?
      super
    else
      super(triples, id)
    end        
  end

  def self.find(id, ns)
    object = super(id, ns)
    if object.link_exists?(C_SCHEMA_PREFIX, "hasThesaurusConcept")
      object.reference_type = C_TC
      object.thesaurus_concept = getReference(object, "hasThesaurusConcept")
    else
      object.reference_type = C_BC
      object.biomedical_concept = getReference(object, "hasBiomedicalConcept")
      object.bc_property = getReference(object, "hasProperty")
      object.bc_value = getReference(object, "hasValue")
    end
    return object
  end

  def self.find_from_triples(triples, id, bc=nil)
    object = new(triples, id)
    if object.link_exists?(C_SCHEMA_PREFIX, "hasThesaurusConcept")
      object.reference_type = C_TC
      object.thesaurus_concept = getReference(object, "hasThesaurusConcept")
    else
      object.biomedical_concept = getReference(object, "hasBiomedicalConcept")
      object.bc_property = getReference(object, "hasProperty", bc)
      object.bc_value = getReference(object, "hasValue")
    end
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
        elsif rdf_type == "hasValue"
          reference = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]), false)
        elsif rdf_type == "hasThesaurusConcept"
          reference = ThesaurusConcept.find(ModelUtility.extractCid(links[0]),ModelUtility.extractNs(links[0]), false)
        end
      end
    end
    return reference
  end

end