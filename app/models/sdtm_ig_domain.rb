class SdtmIgDomain < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmDomain"

  data_property :prefix
  data_property :structure

  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"
  object_property :based_on_class, cardinality: :one, model_class: "SdtmClass"

  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?format ?notes ?compliance WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?c .
        ?c bd:ordinal ?ordinal .
        ?c rdf:type ?type .
        ?c isoC:label ?label . 
        ?c bd:name ?name .
        ?c bd:controlled_term_or_format ?format .
        ?c bd:notes ?notes .
        ?c bd:compliance ?com .
        ?com isoC:label ?compliance .  
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :var, :type, :label, :name, :format, :notes, :compliance]).each do |x|
      results << {uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  format: x[:format], notes: x[:notes], compliance: x[:compliance]}
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmIg.owner
  end

end
