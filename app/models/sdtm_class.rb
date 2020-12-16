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
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?description ?typed_as ?classification WHERE
      {
        #{self.uri.to_ref} bd:includesColumn ?c .
        ?c bd:ordinal ?ordinal .
        ?c rdf:type ?type .
        ?c isoC:label ?label . 
        ?c bd:name ?name .
        ?c bd:description ?description .
        ?c bd:typedAs/isoC:prefLabel ?typed_as .
        ?c bd:classifiedAs/isoC:prefLabel ?classification .
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :c, :type, :label, :name, :description, :typed_as, :classification]).each do |x|
      results << {id: x[:c].to_id, uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
      description: x[:description], typed_as: x[:typed_as], classified_as: x[:classification]}
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
