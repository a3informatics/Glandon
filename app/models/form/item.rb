class Form::Item < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BusinessForm#Item",
            uri_suffix: "I",
            uri_property: :ordinal

  data_property :ordinal, default: 1
  data_property :note
  data_property :completion
  data_property :optional, default: false

  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?
  validates_with Validator::Field, attribute: :note, method: :valid_markdown?
  validates_with Validator::Field, attribute: :completion, method: :valid_markdown?
  validates :optional, inclusion: { in: [ true, false ] }

private

  def coded_values_to_hash(coded_values)
    results = []
    coded_values.each do |cv|
      ref = cv.to_h
      ref[:reference] = Thesaurus::UnmanagedConcept.find(cv.reference).to_h
      parent = Thesaurus::ManagedConcept.find_with_properties(cv.context)
      ref[:context] = {id: parent.id, uri: parent.uri.to_s, identifier: parent.has_identifier.identifier, notation: parent.notation, semantic_version: parent.has_identifier.semantic_version}
      results << ref
    end
    results
  end

end