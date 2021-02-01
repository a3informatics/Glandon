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

  # Clone. Clone the Collection 
  #
  # @return [ManagedCollection] a clone of the object
  def clone
    self.has_managed_links
    object = super
    object.has_managed = []
    self.has_managed.each do |ref|
      object.has_managed << ref.clone
    end
    object
  end

  # Add item. 
  #
  # @param [Array] ids the ids to add as items
  # @return [ManagedCollection] managed collection with added items
  def add_item(ids)
    ordinal = next_ordinal(:has_managed)
    transaction = transaction_begin
    ids.map{|x| Uri.new(id: x)}.each do |uri|
      ref = OperationalReferenceV3.create({ordinal: ordinal, reference: uri, transaction: transaction}, self)
      self.add_link(:has_managed, ref.uri)
      ordinal += 1
    end
    transaction_execute
    self
  end

  # Remove item. 
  #
  # @param [Array] ids the ids to remove as items
  # @return [ManagedCollection] managed collection without removed items
  def remove_item(ids)
    update_query = %Q{ 
      DELETE {
        ?x ?p ?o .
        #{self.uri.to_ref} bo:hasManaged ?x .
      }
      WHERE
      {
        VALUES ?s { #{ids.map{|x| Uri.new(id: x).to_ref}.join(" ")} } .
        ?s ^bo:reference ?x .
        #{self.uri.to_ref} bo:hasManaged ?x .
      }
    }
    Sparql::Update.new.sparql_update(update_query, "", [:bo])
    self.reset_ordinals
    self
  end

  # Managed items. List the objects that belong to the Collection.
  # @param 
  # @return
  def managed_items
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

  # Reset Ordinals. Reset the ordinals within the enclosing parent
  #
  # @return [Boolean] true if reordered, false otherwise.
  def reset_ordinals
    local_uris = uris_by_ordinal
    return false if local_uris.empty?
    string_uris = {delete: "", insert: "", where: ""}
    local_uris.each_with_index do |s, index|
      string_uris[:delete] += "#{s.to_ref} bo:ordinal ?x#{index} . "
      string_uris[:insert] += "#{s.to_ref} bo:ordinal #{index+1} . "
      string_uris[:where] += "#{s.to_ref} bo:ordinal ?x#{index} . "
    end
    query_string = %Q{
      DELETE 
        { #{string_uris[:delete]} }
      INSERT
        { #{string_uris[:insert]} }
      WHERE 
        { #{string_uris[:where]} }
    }
puts "Q: #{query_string}"
    results = Sparql::Update.new.sparql_update(query_string, "", [:bf, :bo])
    true
  end

  private

    # Return URIs of the children objects ordered by ordinal
    def uris_by_ordinal
      query_string = %Q{
        SELECT ?s WHERE {
          #{self.uri.to_ref} bo:hasManaged ?s . 
          ?s bo:ordinal ?ordinal .
        } ORDER BY ?ordinal
      }
      query_results = Sparql::Query.new.query(query_string, "", [:bo])
      query_results.by_object(:s)
    end

end