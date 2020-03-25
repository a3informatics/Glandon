class Study < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Study",
            uri_suffix: "ST"

  object_property :implements, cardinality: :one, model_class: "Protocol"

  def protocols
    query_string = %Q{
      SELECT ?s WHERE
      {
        #{self.uri.to_ref} pr:implements ?s .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    query_results.by_object_set([:s]).map{|x| x[:s]}
  end

end
