class Classification < IsoContextualRelationship

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Classification",
            base_uri: "http://#{ENV["url_authority"]}/CLA",
            uri_unique: true
  
  object_property :classified_as, cardinality: :one, model_class: "IsoConceptSystem::Node"

  def self.where(applies_to, classified_as)
    objects = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{applies_to.to_ref}  ^isoC:appliesTo ?s .
        ?s isoC:classifiedAs #{classified_as.to_ref} .
        ?s ?p ?o 
      }
    }    
    results = Sparql::Query.new.query(query_string, "", [:isoC])
    return nil if results.empty?
    results.by_subject.each do |subject, triples|
      objects << from_results(Uri.new(uri: subject), triples)
    end
    Errors.application_error(self.class.name, "where", "Multiple classifications found for #{applies_to} and #{classified_as}.") if objects.count > 1
    objects.first
  rescue => e
byebug
  end

end