# Biomedical Concept, Item. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConcept::Item < IsoConceptV2

configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#Item",
          uri_property: :ordinal,
          uri_suffix: 'BCI'
  
  data_property :mandatory, default: true
  data_property :collect, default: true
  data_property :enabled, default: true
  data_property :ordinal, default: 1
  object_property :has_complex_datatype, cardinality: :many, model_class: "BiomedicalConcept::ComplexDatatype", children: true

  validates_with Validator::Field, attribute: :enabled, method: :valid_boolean?

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    ["<http://www.assero.co.uk/BiomedicalConcept#hasItem>"]
  end

  # # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  # #
  # # @return [Symbol] the predicate property as a symbol
  # def managed_ancestors_predicate
  #   :has_item
  # end

end