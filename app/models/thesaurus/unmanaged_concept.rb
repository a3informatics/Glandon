class Thesaurus::UnmanagedConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
            uri_property: :identifier,
            key_property: :identifier

  data_property :identifier
  data_property :notation
  data_property :definition
  data_property :extensible
  object_property :extended_with, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :narrower, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept", children: true
  object_property :is_subset, cardinality: :one, model_class: "Thesaurus::Subset"
  object_property :preferred_term, cardinality: :one, model_class: "Thesaurus::PreferredTerm"
  object_property :synonym, cardinality: :many, model_class: "Thesaurus::Synonym"
  
  validates_with Validator::Field, attribute: :identifier, method: :valid_tc_identifier?
  validates_with Validator::Field, attribute: :notation, method: :valid_submission_value?
  validates_with Validator::Field, attribute: :definition, method: :valid_terminology_property?
  validates_with Validator::Uniqueness, attribute: :identifier, on: :create

  include Thesaurus::BaseConcept

  def replace_if_no_change(previous)
    return self if previous.nil?
    return previous if !self.diff?(previous)
    replace_children_if_no_change(previous)
    return self
  end

private

  #
  def replace_children_if_no_change(previous)
    self.narrower.each_with_index do |child, index|
      previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
      next if previous_child.empty?
      self.narrower[index] = child.replace_with_no_change(previous_child)
    end
  end

  # Find parent query. Used by BaseConcept
  def parent_query
    "SELECT DISTINCT ?i WHERE \n" +
    "{ \n" +     
    "  ?s th:narrower #{self.uri.to_ref} .  \n" +
    "  ?s th:identifier ?i . \n" +
    "}"
  end

end