class IsoConceptSystem < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
            base_uri: "http://#{ENV["url_authority"]}/CSN",
            uri_unique: true
  
  data_property :pref_label
  data_property :description
  object_property :is_top_concept, cardinality: :many, model_class: "IsoConceptSystem::Node"

  validates_with Validator::Field, attribute: :pref_label, method: :valid_label?
  validates_with Validator::Field, attribute: :description, method: :valid_long_name?

  C_ROOT_LABEL = "Tags"
  C_ROOT_DESC = "Root node for all tags"

  include IsoConceptSystem::Core

  # Root. Get the root node or create if not present
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def self.root
    result = where_only_or_create({pref_label: C_ROOT_LABEL}, {uri: create_uri(base_uri), pref_label: C_ROOT_LABEL, description: C_ROOT_DESC})
    Errors.application_error(self.name, __method__.to_s, "Errors creating the tag root node. #{result.errors.full_messages.to_sentence}") if result.errors.any?
    result
  end

  # Child Property. The child property
  #
  # @return [Symbol] the :is_top_concept property
  def children_property
    :is_top_concept
  end

end