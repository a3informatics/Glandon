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

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BusinessForm#hasGroup>",
      "<http://www.assero.co.uk/BusinessForm#hasSubGroup>*",
      "<http://www.assero.co.uk/BusinessForm#hasCommon>?",
      "<http://www.assero.co.uk/BusinessForm#hasItem>",
      "<http://www.assero.co.uk/BusinessForm#hasCommonItem>*",
      "<http://www.assero.co.uk/BusinessForm#hasCodedValue>*" 
    ]
  end

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def managed_ancestors_predicate
    :has_coded_value
  end

end