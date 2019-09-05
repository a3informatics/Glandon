# Operational Reference (v3) Thesaurus Unmanaged Concept Reference
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class OperationalReferenceV3::TucReference < OperationalReferenceV3

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#TucReference",
            uri_suffix: "TUC",
            uri_property: :ordinal

  data_property :local_label, default: ""
  object_property :reference, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", delete_exclude: true, read_exclude: true
  object_property :context, cardinality: :one, model_class: "Thesaurus", delete_exclude: true, read_exclude: true
  
  validates_with Validator::Field, attribute: :local_label, method: :valid_label?  
  
end