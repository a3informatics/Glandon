class Timepoint < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Timepoint",
            base_uri: "http://#{ENV["url_authority"]}/TP",
            uri_unique: true
  
  object_property :at_offset, cardinality: :one, model_class: "Timepoint::Offset"
  object_property :next_timepoint, cardinality: :one, model_class: "Timepoint"
  object_property :in_visit, cardinality: :one, model_class: "Visit"
  object_property :has_planned, cardinality: :many, model_class: "IsoManagedV2"

  def set_unit(unit)
    offset = self.at_offset_objects
    offset.unit = offset.format_unit(unit)
    offset.save
  end

  def add_managed(ids)
    results = []
    ids.each do |id|
      item = IsoManagedV2.find_minimum(id)
      ref = nil
      if item.rdf_type == Form.rdf_type
        ref = StudyForm.create(label: item.label, is_derived_from: item.uri)
      elsif item.rdf_type == Assessment.rdf_type
        ref = StudyAssessment.create(label: item.label, is_derived_from: item.uri)
      elsif item.rdf_type == BiomedicalConceptInstance.rdf_type
        ref = StudyBiomedicalConcept.create(label: item.label, is_derived_from: item.uri)
      end
      next if ref.nil?
      self.has_planned_push(ref)
      results << ref
    end
    self.save
    results.map{|x| x.id}
  end

  def remove_managed(ids)
    ids.each do |id|
      item = IsoConceptV2.find(id)
      item.delete_with_links
    end
  end

  def managed
    results = []
    query_string = %Q{
      SELECT DISTINCT ?mi ?i ?sv ?l WHERE
      {
        #{self.uri.to_ref} pr:hasPlanned/pr:isDerivedFrom ?mi .
        ?mi isoC:label ?l .
        ?mi isoT:hasIdentifier/isoI:identifier ?i .
        ?mi isoT:hasIdentifier/isoI:semanticVersion ?sv . 
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr, :isoC, :isoT, :isoI])
    triples = query_results.by_object_set([:mi, :i, :sv, :l])
    triples.each do |entry|
      results << {id: entry[:mi].to_id, label: entry[:l], identifier: entry[:i], semantic_version: entry[:sv]}
    end
    results
  end

  def move(id)
    curr_ep = epoch
    new_ep = Epoch.find(Uri.new(id: id)) 
    return if new_ep.uri == curr_ep.uri
    curr_ep.remove_timepoint(self)
    new_ep.add_timepoint(self)
  end

  def epoch
    query_string = %Q{
      SELECT DISTINCT ?ep WHERE
      {
        #{self.uri.to_ref} ^pr:containsTimepoint/pr:inEpoch ?ep .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    triples = query_results.by_object(:ep)
    Epoch.find(triples.first)
  end

end