class BiomedicalConcept::ComplexDatatype  < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#ComplexDatatype",
            uri_property: :label,
            uri_suffix: 'BCCDT'

  object_property :based_on, cardinality: :one, model_class: "ComplexDatatype"
  object_property :has_property, cardinality: :many, model_class: "BiomedicalConcept::PropertyX", children: true

 #  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
 #  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
 #  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?

 #  # Get Properties
 #  #
 #  # @return [array] Array of leaf (property) JSON structures
 #  def get_properties
 #    results = Array.new
 #    self.children.each do |child|
 #      results += child.get_properties
 #    end
 #    return results
 #  end

	# # Set Properties
 #  #
 #  # param json [hash] The properties
 #  def set_properties(json)
 #    self.children.each do |child|
 #      child.set_properties(json)
 #    end 
 #  end

end