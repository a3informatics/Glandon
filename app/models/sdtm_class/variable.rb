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
    self.diff?(previous, {ignore: [:is_a]}) ? self : previous
  end

  # Datatypes. Get the datatypes for the class
  #
  # @return [Array] set of IsoConceptSystem::Node items
  def self.datatypes
    result = []
    query_string = %Q{
      SELECT DISTINCT ?node ?node_label WHERE {
        ?s isoC:prefLabel "Datatype"^^xsd:string .
        ?s rdf:type isoC:ConceptSystemNode .
        ?s isoC:narrower ?node .
        ?node isoC:prefLabel ?node_label .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    triples = query_results.by_object_set([:node, :node_label])
    triples.each do |datatype|
      result << {id: datatype[:node].to_id, label: datatype[:node_label]}
    end
    result
  end

  # Classification. Get the classification for the class
  #
  # @return [Array] set of IsoConceptSystem::Node items
  def self.classification
    result = []
    query_string = %Q{
      SELECT DISTINCT ?parent ?parent_label ?child ?child_label WHERE {         
        ?s isoC:prefLabel "Classification"^^xsd:string .         
        ?s rdf:type isoC:ConceptSystemNode .         
        ?s isoC:narrower ?parent .
        ?parent isoC:prefLabel ?parent_label .
        OPTIONAL {
          ?parent isoC:narrower ?child .
          ?child isoC:prefLabel ?child_label .
        }
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    triples = query_results.by_object_set([:parent, :parent_label, :child, :child_label])
    triples.each do |classification|
      label = classification[:parent_label] == "Qualifier" ? "#{classification[:child_label]} #{classification[:parent_label]}" : classification[:parent_label]
      id = classification[:parent_label] == "Qualifier" ? classification[:child].to_id : classification[:parent].to_id
      result << {id: id, label: label}
    end
    result
  end

end