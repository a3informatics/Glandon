class BiomedicalConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept"

  object_property :has_item, cardinality: :many, model_class: "BiomedicalConcept::Item", children: true
  object_property :identified_by, cardinality: :one, model_class: "BiomedicalConcept::Item"

  # Get Properties
  #
  # @param [Boolean] references include references within the results if true. Defaults to false.
  # @return [Array] Array of hashes, one per property.
  def get_properties(references=false)
    results = []
    instance = self.class.find_full(self.id)
    instance.has_item.each do |item|
      item.has_complex_datatype.each do |cdt|
        cdt.has_property.each do |property|
          property = property.to_h
          if references
            property[:has_coded_value].each do |coded_value|
              tc = OperationalReferenceV3::TucReference.find_children(coded_value[:id])
              coded_value[:reference] = tc.reference.to_h
              parent = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: coded_value[:context]))
              coded_value[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
            end
          end
          results << {id: item.id, uri: item.uri.to_s, label: item.label, mandatory: item.mandatory, collect: item.collect, enabled: item.enabled, ordinal: item.ordinal, has_complex_datatype: {label: cdt.label, has_property: property}} 
        end
      end
    end
    return results
  end

  # Clone. Clone the BC 
  #
  # @return [BiomedicalConcept] a clone of the object
  def clone
    self.has_item_links
    self.identified_by_links
    super
  end

end
