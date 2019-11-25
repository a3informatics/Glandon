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
  # @raise [Errors::ApplicationError] if object not created.
  # @return [IsoConceptSystem] The new object created if no exception raised
  def self.root
    result = where_only_or_create({pref_label: C_ROOT_LABEL}, {uri: create_uri(base_uri), pref_label: C_ROOT_LABEL, description: C_ROOT_DESC})
    Errors.application_error(self.name, __method__.to_s, "Errors creating the tag root node. #{result.errors.full_messages.to_sentence}") if result.errors.any?
    result
  end

  # Path. Find a node from the root via a path
  #
  # @raise [Errors::ApplicationError] if no results or more than one found
  # @return [IsoConceptSystem::Node] The object found
  def self.path(path)
    parts = []
    parts << "SELECT DISTINCT ?s ?p ?o WHERE {"
    parts << "  ?r rdf:type #{rdf_type.to_ref} . ?r isoC:prefLabel \"#{C_ROOT_LABEL}\" .\n ?r isoC:isTopConcept ?c0 ."
    path[0..-2].each_with_index {|x, index| parts << "  ?c#{index} rdf:type #{IsoConceptSystem::Node.rdf_type.to_ref} .\n ?c#{index} isoC:prefLabel \"#{x}\" .\n ?c#{index} isoC:narrower ?c#{index+1} ."}
    parts << "  ?c#{path.length} rdf:type #{IsoConceptSystem::Node.rdf_type.to_ref} .\n ?c#{path.length} isoC:prefLabel \"#{path.last}\" ."
    parts << "  BIND (?c#{path.length} as ?s) .\n ?s ?p ?o"
    parts << "}"
    query_string = parts.join("\n")
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    Errors.application_error(self.name, __method__.to_s, "Errors finding tag path #{path}.") if query_results.empty?
    subjects = query_results.by_subject
    Errors.application_error(self.name, __method__.to_s, "Multiple tag paths #{path} found.") if subjects.count > 1
    subjects.each do |subject, triples|
      return IsoConceptSystem::Node.from_results(Uri.new(uri: subject), triples)
    end
  end

  # Find All. 
  def find_all
    query_string = %Q{
SELECT DISTINCT ?s ?p ?o WHERE {
  { 
    {
      #{self.uri.to_ref} ?p ?o .
      BIND (#{self.uri.to_ref} as ?s)
    } UNION
    {
      #{self.uri.to_ref} isoC:isTopConcept/isoC:narrower* ?s .
      ?s ?p ?o
    }
  }
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    self.class.from_results_recurse(self.uri, query_results.by_subject)
  end

  # Child Property. The child property
  #
  # @return [Symbol] the :is_top_concept property
  def children_property
    :is_top_concept
  end

  # Tags separator. 
  # @return [String] a character that separates tags
  def self.tag_separator 
    ";"
  end

end