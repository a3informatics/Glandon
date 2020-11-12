# Operational Reference (v3) Thesaurus Managed Concept
#
# @author Dave Iberson-Hurst
# @since 2.22.1
class OperationalReferenceV3::TmcReference < OperationalReferenceV3

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#TMcReference",
            uri_suffix: "TMC",
            uri_property: :ordinal

  object_property :reference, cardinality: :one, model_class: "Thesaurus::ManagedConcept", delete_exclude: true, read_exclude: true
  object_property :context, cardinality: :one, model_class: "Thesaurus", delete_exclude: true, read_exclude: true
  
end