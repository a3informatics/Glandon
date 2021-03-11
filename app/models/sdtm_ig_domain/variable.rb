class SdtmIgDomain::Variable < Tabulation::Column

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmDomainVariable",
            uri_property: :name

  data_property :name
  data_property :description
  data_property :format
  data_property :ct_and_format
  object_property :compliance, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :ct_reference, cardinality: :many, model_class: "OperationalReferenceV3::TmcReference"
  object_property :based_on_class_variable, cardinality: :one, model_class: "SdtmClass::Variable", delete_exclude: true
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference", delete_exclude: true
  
  validates_with Validator::Field, attribute: :format, method: :valid_label?

  def key_property_value
    self.name
  end

  def replace_if_no_change(previous)
    return self if previous.nil?
    self.compliance = self.compliance.uri unless self.compliance.nil?
    self.based_on_class_variable = self.based_on_class_variable.uri unless self.based_on_class_variable.nil?
    previous.compliance = previous.compliance.uri unless previous.compliance.nil?
    previous.based_on_class_variable = previous.based_on_class_variable.uri unless previous.based_on_class_variable.nil?
    self.diff?(previous, {ignore: [:ct_reference, :is_a]}) ? self : previous
  end

  # Compliance. Get the compliance for the class
  #
  # @return [Array] set of IsoConceptSystem::Node items
  def self.compliance
    result = []
    query_string = %Q{
      SELECT DISTINCT ?node ?node_label WHERE {
        ?s rdf:type isoC:ConceptSystemNode .
        ?s isoC:prefLabel "SDTM-STD"^^xsd:string .
        ?s isoC:narrower ?variable .
        ?variable isoC:narrower ?compliance .
        ?compliance isoC:prefLabel "Compliance"^^xsd:string .
        ?compliance isoC:narrower ?node .
        ?node isoC:prefLabel ?node_label
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    triples = query_results.by_object_set([:node, :node_label])
    triples.each do |compliance|
      result << {id: compliance[:node].to_id, label: compliance[:node_label]}
    end
    result
  end

end