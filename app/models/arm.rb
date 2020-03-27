class Arm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Arm",
            uri_suffix: "AR"

  data_property :description
  data_property :arm_type
  #object_property :has_sequence_of, cardinality: :one, model_class: "Intervention"
  #object_property :derived_from, cardinality: :one, model_class: "DesignMatrixComplex"

end
