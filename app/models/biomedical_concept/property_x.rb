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

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def self.managed_ancestors_predicate
    :has_property
  end

end