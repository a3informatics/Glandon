class Thesaurus::ManagedConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#ManagedConcept",
            uri_property: :identifier
            
  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :extended_with, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :is_subset, cardinality: :one, model_class: "Thesaurus::Subset"
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :one, model_class: "Thesaurus::Synonym"
  
  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Uniqueness, attribute: :identifier, on: :create

  include Thesaurus::BaseConcept

end