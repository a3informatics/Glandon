class Timepoint < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Timepoint",
            base_uri: "http://#{ENV["url_authority"]}/TP",
            uri_unique: :label
  
  object_property :at_offset, cardinality: :one, model_class: "Timepoint::Offset"
  object_property :next_timepoint, cardinality: :one, model_class: "Timepoint"
  object_property :in_visit, cardinality: :one, model_class: "Visit"
  #object_property :has_planned, cardinality: :many, model_class: "StudyBiomedicalConcept"

end