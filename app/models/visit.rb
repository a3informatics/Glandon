class Visit < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Visit",
            base_uri: "http://#{ENV["url_authority"]}/VI",
            uri_unique: :short_name

  data_property :short_name

  def add_timepoints(params)
    params[:timepoints].each do |timepoint_id|
      timepoint = Timepoint.find(timepoint_id)
      timepoint.in_visit = self.uri
      timepoint.save
    end
  end

  def remove_timepoints(params)
    params[:timepoints].each do |timepoint_id|
      timepoint = Timepoint.find(timepoint_id)
      timepoint.in_visit = nil
      timepoint.save
    end
  end

end
