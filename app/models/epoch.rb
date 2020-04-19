class Epoch < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Epoch",
            base_uri: "http://#{ENV["url_authority"]}/EP",
            uri_unique: true
  
  data_property :ordinal

  def add_timepoint(timepoint)
    elements.each{|el| el.add_timepoint(timepoint)}
  end

  def remove_timepoint(timepoint)
    elements.each{|el| el.remove_timepoint(timepoint)}
  end

  def elements
    results = []
    query_string = %Q{
      SELECT DISTINCT ?el WHERE
      {
        #{self.uri.to_ref} ^pr:inEpoch ?el .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:pr])
    query_results.by_object(:el).each {|x| results << Element.find(x)}
    results
  end

end
