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

end