class SdtmClass < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmClass",
            uri_suffix: "CL"
  
  object_property_class :includes_column, model_class: "SdtmClass::Variable"

  def find_variable(variable_name, domain_prefix)
    variable = SdtmVariableName.new(variable_name, domain_prefix)
    search_clause = "{?s bd:name '#{variable.generic_prefix}'}"
    search_clause += " UNION {?s bd:name '#{variable.name}'}" unless variable.generic_prefix == variable.name
    query_string = %Q{
      SELECT DISTINCT ?s WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?s .
        #{search_clause}
      }
    }
    self.class.find_single(query_string, [:bd])
  end

  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{
      SELECT DISTINCT ?var ?ordinal ?type ?label ?typedas ?name ?desc ?class ?sub_class WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?c .
        ?c bd:ordinal ?ordinal .
        ?c rdf:type ?type.
        ?c isoC:label ?label. 
        ?c bd:name ?name .
        ?c bd:description ?desc .
        ?c bd:typedAs/isoC:prefLabel ?typedas .
        {           
          ?c bd:classifiedAs/isoC:prefLabel ?sub_class .             
          ?c bd:classifiedAs/^isoC:narrower/isoC:prefLabel ?class .
          NOT EXISTS {?c bd:classifiedAs/^isoC:narrower/isoC:prefLabel 'Classification'} 
        }         
        UNION         
        {           
          ?c bd:classifiedAs/isoC:prefLabel ?class . 
          BIND ("" as ?sub_class)
          EXISTS {?c bd:classifiedAs/^isoC:narrower/isoC:prefLabel 'Classification'} 
        }
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd, :th])
    query_results.by_object_set([:var, :ordinal, :type, :label, :typedas, :name, :desc, :classifiedas]).each do |x|
      results << {uri: x[:var].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  description: x[:desc], typed_as: x[:typedas], classified_as: x[:class], sub_classified_as: x[:sub_class]}
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmModel.owner
  end

end
