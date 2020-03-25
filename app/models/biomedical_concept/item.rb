class BiomedicalConcept::Item < IsoConceptV2

configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#Item",
          uri_property: :ordinal,
          uri_suffix: 'BCI'
  
  data_property :mandatory, default: true
  data_property :collect, default: true
  data_property :enabled, default: true
  data_property :ordinal, default: 1
  object_property :has_complex_datatype, cardinality: :many, model_class: "BiomedicalConcept::ComplexDatatype", children: true

  # validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  # validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  # validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  
 #  # Get Properties
 #  #
 #  # @return [array] Array of leaf (property) JSON structures
 #  def get_properties
 #    return self.datatype.get_properties
 #  end

	# # Set Properties
 #  #
 #  # param json [hash] The properties
 #  def set_properties(json)
 #    self.datatype.set_properties(json)
 #  end

end