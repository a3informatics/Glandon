class AdamIgDataset::Variable < Tabulation::Column

  configure rdf_type: "http://www.assero.co.uk/Tabulation#ADaMDatasetVariable",
            uri_suffix: "AV",
            uri_property: :name

  data_property :name
  data_property :notes
  data_property :ct
  object_property :ct_reference, cardinality: :many, model_class: "OperationalReferenceV3::TmcReference"
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  
  def key_property_value
    self.name
  end

end