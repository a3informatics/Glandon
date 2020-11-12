# Biomedical Concept, Complex Datatype.
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConcept::ComplexDatatype  < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#ComplexDatatype",
            uri_property: :label,
            uri_suffix: 'BCCDT'

  object_property :is_complex_datatype, cardinality: :one, model_class: "ComplexDatatype", read_exclude: true, delete_exclude: true
  object_property :has_property, cardinality: :many, model_class: "BiomedicalConcept::PropertyX", children: true

  # Managed Ancestors Path. Returns the path from the managed ancestor to this class
  #
  # @return [String] the path as an expanded set of predicates
  def self.managed_ancestors_path
    [
      "<http://www.assero.co.uk/BiomedicalConcept#hasItem>",
      "<http://www.assero.co.uk/BiomedicalConcept#hasComplexDatatype>"
    ]
  end

  # Managed Ancestors Predicate. Returns the predicate from the higher class in the managed ancestor path to this class
  #
  # @return [Symbol] the predicate property as a symbol
  def managed_ancestors_predicate
    :has_complex_datatype
  end

end
