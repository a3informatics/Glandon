class SdtmClass::Variable < Tabulation::Column

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmClassVariable",
            uri_property: :name

  data_property :name
  data_property :prefixed
  data_property :description
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :classified_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference", delete_exclude: true

  def key_property_value
    self.name
  end

  def replace_if_no_change(previous)
    return self if previous.nil?
    self.diff?(previous, {ignore: [:is_a, :tagged]}) ? self : previous
  end

end