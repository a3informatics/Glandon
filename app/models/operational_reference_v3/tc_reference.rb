# Operational Reference (v3)
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class OperationalReferenceV3::TcReference < OperationalReferenceV3

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#TcReference",
            uri_suffix: "TCR",
            uri_property: :ordinal

  data_property :local_label, default: ""
  object_property :reference, cardinality: :one, model_class: "Thesaurus::ManagedConcept", path_exclude: true
  
  validates_with Validator::Field, attribute: :local_label, method: :valid_label?  
  
end