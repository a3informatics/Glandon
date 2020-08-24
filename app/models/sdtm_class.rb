class SdtmClass < Tabulation

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmClass",
            uri_suffix: "CL"
  
  # Get Children.
  #
  # @return [Array] array of objects
  def get_children
    results = []
    query_string = %Q{SELECT DISTINCT ?var ?ordinal ?type ?label ?typedas ?name ?desc ?classifiedas WHERE
{
  #{self.uri.to_ref} bd:includesColumn ?c .
  ?c bd:ordinal ?ordinal .
  ?c bd:basedOnModelVariable ?var .     
  ?var rdf:type ?type.
  ?var isoC:label ?label. 
  ?var bd:name ?name .
  ?var bd:description ?desc .
  ?var bd:typedAs ?tas .
  ?tas isoC:label ?typedas .
  ?var bd:classifiedAs ?cas .
  ?cas isoC:label ?classifiedas .  
} ORDER BY ?ordinal
}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:var, :ordinal, :type, :label, :typedas, :name, :desc, :classifiedas]).each do |x|
      results << {uri: x[:var].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, label: x[:label], name: x[:name],
                  description: x[:desc], typed_as: x[:typedas], classified_as: x[:classifiedas]}
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
