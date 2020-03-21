class BiomedicalConceptInstance < BiomedicalConcept

    object_property :based_on, cardinality: :one, model_class: "BiomedicalConceptTemplate"

end