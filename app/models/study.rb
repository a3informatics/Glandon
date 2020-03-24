class Study < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Study",
            uri_suffix: "ST"

  data_property :name
  object_property :implements, cardinality: :one, model_class: "Protocol"


  def self.create(params)
    super(params)
  end

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


  # List all Studies
  #
  # @return [Array] Each hash contains {id, identifier, label, scope_id, owner_short_name}
  def self.all
    results = []
    query_string = %Q{
      SELECT DISTINCT ?e ?l ?i ?ns ?sn WHERE
      {
        ?e rdf:type #{self.rdf_type.to_ref} .
        ?e isoC:label ?l .
        ?e isoT:hasIdentifier ?si .
        ?si isoI:identifier ?i .
        ?si isoI:hasScope ?ns .
        ?ns isoI:shortName ?sn .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :isoR])
    triples = query_results.by_object_set([:e, :i, :l, :ns, :sn])
    triples.each do |entry|
      results << {id: entry[:e].to_id, identifier: entry[:i], label: entry[:l], scope_id: entry[:ns].to_id, owner: entry[:sn]}
    end
    results
  end

end
