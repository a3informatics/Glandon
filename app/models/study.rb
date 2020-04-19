class Study < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Study",
            uri_suffix: "ST"

  data_property :description
  object_property :implements, cardinality: :one, model_class: "Protocol"

  def protocol
    implements_objects
  end

  def visits
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?v ?vl ?vsn ?tp WHERE
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
    triples = query_results.by_object_set([:v, :vl, :vsn, :tp])
    return [] if triples.empty?
    triples.each do |entry|
      results[entry[:v].to_s] = {id: entry[:v].to_id, label: entry[:vl], short_name: entry[:vsn], timepoints: []} unless results.key?(entry[:v].to_s)
      results[entry[:v].to_s][:timepoints] << entry[:tp].to_id
    end
    results.map{|k,v| v}
  end

  def soa
    visit_set = visits
    visit_set.each {|h| h[:applies] = false}
    results = {}
    query_string = %Q{
      SELECT DISTINCT ?v ?vl ?x ?xl ?xt WHERE
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
        ?tp pr:hasPlanned/pr:isDerivedFrom ?x .
        ?x isoC:label ?xl .   
        ?x rdf:type ?xt .
      } ORDER BY ?os
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bo, :isoC, :pr])
    triples = query_results.by_object_set([:v, :vl, :x, :xl, :xt])
    return [] if triples.empty?
    triples.each do |entry|
      uri_s = entry[:x].to_s
      results[uri_s] = {label: entry[:xl], id: entry[:x].to_id, rdf_type: entry[:xt].to_s, uri: entry[:x].to_s, visits: visit_set.dup} if !results.key?(uri_s)
      next if entry[:v].blank?
      visit = results[uri_s][:visits].find{|x| x[:id] == entry[:v].to_id} 
      visit[:applies] = true
    end
    results.map{|k,v| v}
  end

end
