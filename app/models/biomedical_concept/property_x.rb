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
  object_property :has_coded_value, cardinality: :many, model_class: "OperationalReferenceV3::TucReference"
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference", read_exclude: true, delete_exclude: true

  validates_with Validator::Field, attribute: :question_text, method: :valid_question?
  validates_with Validator::Field, attribute: :prompt_text, method: :valid_question?
  validates_with Validator::Field, attribute: :format, method: :valid_format?

  def self.managed_ancestors_path
    "<http://www.assero.co.uk/BiomedicalConcept#hasItem>" + 
    "/<http://www.assero.co.uk/BiomedicalConcept#hasComplexDatatype>" +
    "/<http://www.assero.co.uk/BiomedicalConcept#hasProperty>"
  end

end