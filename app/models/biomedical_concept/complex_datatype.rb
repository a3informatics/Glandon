# Biomedical Concept, Complex Datatype. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConcept::ComplexDatatype  < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#ComplexDatatype",
            uri_property: :label,
            uri_suffix: 'BCCDT'

  object_property :based_on, cardinality: :one, model_class: "ComplexDatatype", read_exclude: true, delete_exclude: true
  object_property :has_property, cardinality: :many, model_class: "BiomedicalConcept::PropertyX", children: true

end