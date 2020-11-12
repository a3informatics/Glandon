class Element < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Element",
            base_uri: "http://#{ENV["url_authority"]}/ELE",
            uri_unique: true

  object_property :in_arm, cardinality: :one, model_class: "Arm"
  object_property :in_epoch, cardinality: :one, model_class: "Epoch"
  object_property :contains_timepoint, cardinality: :many, model_class: "Timepoint"

  def add_timepoint(timepoint)
    self.add_link(:contains_timepoint, timepoint.uri)
  end

  def remove_timepoint(timepoint)
    self.delete_link(:contains_timepoint, timepoint.uri)
  end

end
