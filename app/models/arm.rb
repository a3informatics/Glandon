class Arm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Arm",
            base_uri: "http://#{ENV["url_authority"]}/ARM",
            uri_unique: true

  data_property :description
  data_property :arm_type
  data_property :ordinal

  SECS_PER_DAY = 24*60*60

  def timepoints
    results = []
    query_string = %Q{
      SELECT DISTINCT ?el ?tp ?e ?v ?off WHERE
      {
        #{self.uri.to_ref} ^pr:inArm ?el .
        ?el pr:containsTimepoint ?tp .
        ?el pr:inEpoch ?e .
        ?tp pr:atOffset ?off .
        OPTIONAL { ?tp pr:inVisit ?v . }
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    triples = query_results.by_object_set([:el, :tp, :e, :v, :off])
    triples.each do |entry|
      offset = Timepoint::Offset.find(entry[:off]) 
      results << {id: entry[:tp].to_id, epoch_id: entry[:e].to_id, element_id: entry[:el].to_id, visit_id: entry[:v].blank? ? "" : entry[:v].to_id, unit: offset.unit, biomedical_concepts: [], baseline: false, offset: offset.as_days}
    end
    results
  end       

  def add_timepoint(params)
    offset = Timepoint::Offset.create(window_offset: params[:offset].to_i*SECS_PER_DAY, window_minus: 0, window_plus: 0, unit: "Day")
    tp = Timepoint.create(label: "", at_offset: offset.uri)
    element = Element.find(element_for_epoch(params[:epoch_id]))
    element.contains_timepoint_push(tp.uri)
    element.save
    {
      id: tp.id,
      epoch_id: params[:epoch_id],
      element_id: element.id,
      visit_id: "",
      unit: "Day",
      biomedical_concepts: [],
      baseline: false,
      offset: params[:offset].to_i
    }
  end

  def element_for_epoch(id)
    epoch_uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    query_string = %Q{
      SELECT DISTINCT ?el WHERE
      {
        #{self.uri.to_ref} ^pr:inArm ?el .
        ?el pr:inEpoch #{epoch_uri.to_ref} .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    return nil if query_results.empty?
    query_results.by_object(:el).first
  end       

end
