class BiomedicalConceptInstance < BiomedicalConcept

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#BiomedicalConceptInstance",
            uri_suffix: "BCI"

  object_property :based_on, cardinality: :one, model_class: "BiomedicalConceptTemplate"

end