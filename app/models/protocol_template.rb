class ProtocolTemplate < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolTemplate",
            uri_suffix: "PRT"

  object_property :specifies_arm, cardinality: :many, model_class: "Arm"
  object_property :specifies_epoch, cardinality: :many, model_class: "Epoch"

  def self.list
    results = []
    query_string = %Q{
      SELECT DISTINCT ?s ?sl WHERE
      {
        ?s rdf:type #{self.rdf_type.to_ref} .
        ?s isoC:label ?sl .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [])
    triples = query_results.by_object_set([:s, :sl])
    return [] if triples.empty?
    triples.each {|entry| results << {id: entry[:s].to_id, label: entry[:sl]}}
    results
  end    

  def elements
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?ele WHERE
      {
        #{self.uri.to_ref} pr:specifiesEpoch ?e .
        ?e ^pr:inEpoch ?ele .         
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    query_results.by_object(:ele)
  end 

end
