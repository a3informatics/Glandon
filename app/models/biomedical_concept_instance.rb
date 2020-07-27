# Biomedical Concept Instance. 
#
# @author Dave Iberson-Hurst
# @since 3.1.0
class BiomedicalConceptInstance < BiomedicalConcept

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance",
            uri_suffix: "BCI"

  object_property :based_on, cardinality: :one, model_class: BiomedicalConceptTemplate, delete_exclude: true, read_exclude: true

end