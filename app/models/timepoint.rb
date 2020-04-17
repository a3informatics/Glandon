class Timepoint < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Timepoint",
            base_uri: "http://#{ENV["url_authority"]}/TP",
            uri_unique: true
  
  object_property :at_offset, cardinality: :one, model_class: "Timepoint::Offset"
  object_property :next_timepoint, cardinality: :one, model_class: "Timepoint"
  object_property :in_visit, cardinality: :one, model_class: "Visit"
  object_property :has_planned, cardinality: :many, model_class: "IsoManagedV2"

  def set_unit(unit)
    offset = self.at_offset_objects
    offset.unit = offset.format_unit(unit)
    offset.save
  end

end