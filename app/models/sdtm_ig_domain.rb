class SdtmIgDomain < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmDomain",
            uri_suffix: "IGD"

  data_property :prefix
  data_property :structure

  object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"
  #object_property :by_association, cardinality: :one, model_class: "Association"
  object_property :based_on_class, cardinality: :one, model_class: "SdtmClass"

  object_property_class :includes_column, model_class: "SdtmIgDomain::Variable"

  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?format ?description ?compliance ?typedas ?class ?sub_class WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?c .
        ?c bd:ordinal ?ordinal .
        ?c rdf:type ?type .
        ?c isoC:label ?label . 
        ?c bd:name ?name .
        ?c bd:description ?description .
        ?c bd:ctAndFormat ?format .
        ?c bd:basedOnClassVariable/bd:typedAs/isoC:prefLabel ?typedas .
        ?c bd:compliance/isoC:prefLabel ?compliance .
        {           
          ?c bd:basedOnClassVariable/bd:classifiedAs/isoC:prefLabel ?sub_class .             
          ?c bd:basedOnClassVariable/bd:classifiedAs/^isoC:narrower/isoC:prefLabel ?class .
          NOT EXISTS {?c bd:basedOnClassVariable/bd:classifiedAs/^isoC:narrower/isoC:prefLabel 'Classification'} 
        }         
        UNION         
        {           
          ?c bd:basedOnClassVariable/bd:classifiedAs/isoC:prefLabel ?class . 
          BIND ("" as ?sub_class)
          EXISTS {?c bd:basedOnClassVariable/bd:classifiedAs/^isoC:narrower/isoC:prefLabel 'Classification'} 
        }      
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :var, :type, :label, :name, :format, :notes, :compliance]).each do |x|
      results << {uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  format: x[:format], description: x[:description], typed_as: x[:typedas], compliance: x[:compliance], classified_as: x[:class], sub_classified_as: x[:sub_class]}
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmIg.owner
  end

  def unique_in_domain?(name)
    var_names = get_variables_name
    return false if var_names.include? name
    return true
  end

  private

    # Get all variables name as an array
    #
    # @return [Array] the new sponsor domain object
    def get_variables_name
      query_string = %Q{         
        SELECT ?var_name WHERE {#{self.uri.to_ref} bd:includesColumn ?var . ?var bd:name ?var_name}
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      query_results.by_object(:var_name)
    end

end
