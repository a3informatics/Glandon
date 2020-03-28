class Study < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Study",
            uri_suffix: "ST"

  data_property :description
  object_property :implements, cardinality: :one, model_class: "Protocol"

  def protocol
    implements_objects
  end

end
