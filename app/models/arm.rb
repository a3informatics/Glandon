class Arm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Arm",
            base_uri: "http://#{ENV["url_authority"]}/ARM",
            uri_unique: true

  data_property :description
  data_property :arm_type
  data_property :ordinal

  def timepoints
    results = []
    query_string = %Q{
      SELECT DISTINCT ?el ?tp ?e ?v ?off WHERE
      {
        #{self.uri.to_ref} ^pr:inArm ?el .
        ?el pr:containsTimepoint ?tp .
        ?el pr:inEpoch ?e .
        ?tp pr:inVisit ?v .
        ?tp pr:atOffset ?off .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    triples = query_results.by_object_set([:el, :tp, :e, :v, :off])
    triples.each do |entry|
      offset = Timepoint::Offset.find(entry[:off]) 
      results << {id: entry[:tp].to_id, epoch_id: entry[:e].to_id, element_id: entry[:el].to_id, visit_id: entry[:v].to_id, unit: offset.unit, biomedical_concepts: [], baseline: false, offset: offset.as_days}
    end
    results
  end       

end
