# Managed Collection
#
# @author Dave Iberson-Hurst
# @since Hackathon
class ManagedCollection <  IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BusinessOperational#Collection",
            uri_suffix: "MC"

  object_property :has_managed, cardinality: :many, model_class: "OperationalReferenceV3", children: true

  def add_no_save(item, ordinal)
    ref = OperationalReferenceV3.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.has_managed << ref
  end

  def clone
    self.has_managed_links
    object = super
    object.has_managed = []
    self.has_managed.each do |ref|
      object.has_managed << ref.clone
    end
    object
  end

  def add_item(id_set)
    ordinal = next_ordinal(:has_managed)
    transaction = transaction_begin
    id_set.map{|x| Uri.new(id: x)}.each do |uri|
      ref = OperationalReferenceV3.create({ordinal: ordinal, reference: uri, transaction: transaction}, self)
      self.add_link(:has_managed, ref.uri)
      ordinal += 1
    end
    transaction_execute
    self
  end

  # def remove_item(id_set)
  # end

  # Managed. List the objects that belong to the Collection.
  # @param 
  # @return
  def managed
    results = []
    query_string = %Q{
      SELECT DISTINCT ?s ?i ?l ?sv ?vl ?owner ?rdf_type WHERE {
        #{self.uri.to_ref} bo:hasManaged ?op_ref .
        ?op_ref bo:reference ?s .
        ?s isoT:hasIdentifier/isoI:identifier ?i .
        ?s isoC:label ?l .
        ?s isoT:hasIdentifier/isoI:semanticVersion ?sv .
        ?s isoT:hasIdentifier/isoI:versionLabel ?vl .
        ?s isoT:hasIdentifier/isoI:hasScope/isoI:shortName ?owner .
        ?s rdf:type ?rdf_type
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bo, :isoT, :isoC, :isoI])
    triples = query_results.by_object_set([:s, :i, :l, :sv, :vl, :owner, :rdf_type])
    triples.each do |x|
      results << {uri: x[:s].to_s, id: x[:s].to_id, identifier: x[:i], label: x[:l], semantic_version: x[:sv], version_label: x[:vl], owner: x[:owner], rdf_type: x[:rdf_type].to_s}
    end
    results
  end

end