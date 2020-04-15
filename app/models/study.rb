class Study < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Study",
            uri_suffix: "ST"

  data_property :description
  object_property :implements, cardinality: :one, model_class: "Protocol"

  def protocol
    implements_objects
  end

  def visits
    results = []
    query_string = %Q{
      SELECT DISTINCT ?v ?vl ?vsn WHERE
      {
        #{self.uri.to_ref} pr:implements ?p .
        ?p pr:specifiesEpoch ?e .
        ?e pr:ordinal ?eo .
        ?e isoC:label ?el .
        ?e ^pr:inEpoch ?ele .         
        ?ele pr:containsTimepoint ?tp .
        ?tp pr:atOffset ?o .
        ?o pr:windowOffset ?os .
        ?tp pr:inVisit ?v .
        ?v isoC:label ?vl .
        ?v pr:shortName ?vsn .
      } ORDER BY ?os
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:v, :vl, :vsn])
    return [] if triples.empty?
    triples.each {|entry| results << {id: entry[:v].to_id, uri: entry[:v].to_s, label: entry[:vl], short_name: entry[:vsn]}}
    results
  end

  def soa
    visit_set = visits
    visit_set.each {|h| h[:applies] = false}
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?v ?vl ?x ?xl WHERE
      {
        #{self.uri.to_ref} pr:implements ?p .
        ?p pr:specifiesEpoch ?e .
        ?e pr:ordinal ?eo .
        ?e isoC:label ?el .
        ?e ^pr:inEpoch ?ele .         
        ?ele pr:containsTimepoint ?tp .
        ?tp pr:inVisit ?v .
        ?tp pr:atOffset ?o .
        ?o pr:windowOffset ?os .
        ?v isoC:label ?vl .
        ?tp pr:hasPlanned ?x .
        ?x isoC:label ?xl .   
      } ORDER BY ?os
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:v, :vl, :x, :xl])
    return [] if triples.empty?
    triples.each do |entry|
      uri_s = entry[:x].to_s
      results[uri_s] = {label: entry[:xl], id: entry[:x].to_id, visits: visit_set.dup} if !results.key?(uri_s)
      results[uri_s][:visits] << {label: entry[:vl], id: entry[:v].to_id} unless entry[:x].blank?
    end
    results.map{|k,v| v}
  end

end
