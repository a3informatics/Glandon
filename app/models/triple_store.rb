class TripleStore

  def self.find(id)
    uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    results = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE
      {
        #{uri.to_ref} ?p ?o .
        BIND (#{uri.to_ref} as ?s)
      } ORDER BY ?p
    }
    query_results = Sparql::Query.new.query(query_string, "", [])
    triples = query_results.by_object_set([:s, :p, :o])
    return [] if triples.empty?
    triples.each{|x| results << {subject: x[:s].to_s, predicate: x[:p].to_s, object: x[:o].to_s}}
    results
  end

end
