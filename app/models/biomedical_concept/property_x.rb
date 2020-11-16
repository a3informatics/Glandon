# Biomedical Concept, Property. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConcept::PropertyX < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#PropertyX",
            uri_property: :label,
            uri_suffix: 'BCP'

  data_property :question_text
  data_property :prompt_text
  data_property :format
  data_property :alias
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference", read_exclude: true, delete_exclude: true
  object_property :is_complex_datatype_property, cardinality: :one, model_class: "ComplexDatatype::PropertyX", delete_exclude: true

  validates_with Validator::Field, attribute: :question_text, method: :valid_question?
  validates_with Validator::Field, attribute: :prompt_text, method: :valid_question?
  validates_with Validator::Field, attribute: :format, method: :valid_format?
  validates_with Validator::BcIdentifier

  # Initialize
  #
  # @param attributes [Hash] hash of attributes to set on initialization of the class
  # @return [Object] the created object
  def initialize(attributes = {})
    @identifier_property = false
    super
  end

  # Clone. Clone the property taking care over the reference objects
  #
  # @return [BiomedicalConcept::PropertyX] a clone of the object
  def clone
    self.has_coded_value_objects
    object = super
    object.has_coded_value = []
    self.has_coded_value.each do |ref|
      object.has_coded_value << ref.clone
    end
    object
  end

  # Update. Update the object with the specified properties if valid. Intercepts to handle the terminology
  #
  # @param [Hash] params a hash of properties to be updated
  # @return [Object] returns the object. Not saved if errors are returned.      
  def update(params)
    if params.key?(:has_coded_value) 
      self.has_coded_value_objects
      set = IsoConceptV2::CodedValueSet.new(self.has_coded_value, self)
      set.update(params)
      self.has_coded_value = set.items
      params.delete(:has_coded_value)
    end
    super
  end

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BiomedicalConcept#hasItem>",
      "<http://www.assero.co.uk/BiomedicalConcept#hasComplexDatatype>",
      "<http://www.assero.co.uk/BiomedicalConcept#hasProperty>"
    ]
  end

  # Identifier Property? Is this property the identifier property
  #
  # @return [Boolean] true if identifier property
  def identifier_property?(bc)
    Sparql::Query.new.query("ASK {#{self.uri.to_ref} ^bc:hasProperty/^bc:hasComplexDatatype/^bc:identifiedBy #{bc.uri.to_ref}}", "", [:bc]).ask? 
  end

  # Identifier Property Setter
  #
  # @param [Boolean] value the new value
  def identifier_property=(value)
    @identifier_property = value
  end

  # Identifier Property Getter
  #
  # @return [Boolean] the value
  def identifier_property
    @identifier_property
  end

end