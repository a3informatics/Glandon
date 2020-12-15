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
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?format ?description ?compliance ?compliance_label ?typed_as ?typed_as_label ?classification ?classification_label ?standard WHERE       
      {         
        #{self.uri.to_ref} bd:includesColumn ?c .         
        ?c bd:ordinal ?ordinal .         
        ?c rdf:type ?type .         
        ?c isoC:label ?label .          
        ?c bd:name ?name .         
        ?c bd:description ?description .         
        ?c bd:ctAndFormat ?format .
        ?c bd:compliance ?compliance .
        ?compliance isoC:prefLabel ?compliance_label .
        BIND (EXISTS {?c bd:basedOnIgVariable|bd:basedOnClassVariable ?o} as ?standard)
        OPTIONAL {                   
          ?c bd:basedOnClassVariable/bd:typedAs ?typed_as .
          ?typed_as isoC:prefLabel ?typed_as_label .         
        }
        OPTIONAL {                   
          ?c bd:basedOnClassVariable/bd:classifiedAs ?classification .
          ?classification isoC:prefLabel ?classification_label .         
        }             
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :c, :type, :label, :name, :format, :description, :compliance, :compliance_label, :typed_as, :typed_as_label, :classification, :classification_label, :standard]).each do |x|
      x[:classification] = x[:classification].to_id unless x[:classification].empty?
      x[:classification_label].nil? ? x[:classification_label] = "" : x[:classification_label]
      x[:typed_as] = x[:typed_as].to_id unless x[:typed_as].empty?
      x[:typed_as_label].nil? ? x[:typed_as_label] = "" : x[:typed_as_label]
      results << {id: x[:c].to_id ,uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, standard: x[:standard], label: x[:label], name: x[:name],
                  format: x[:format], description: x[:description], compliance: {id: x[:compliance].to_id, label: x[:compliance_label]}, typed_as: {id: x[:typed_as], label:x[:typed_as_label]}, classified_as: {id:x[:classification], label: x[:classification_label]} }
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmIg.owner
  end

  # unique_in_domain? Check if the variable name is unique in the domain
  #
  # @params [String] name the variable domain name
  # @return [Boolean] true if valid, false otherwise
  def duplicate_name_in_domain?(variable)
    var_names = get_variable_names
    return false unless var_names.include? variable.name
    variable.errors.add(:name, "duplicate detected '#{variable.name}'")
    true
  end

  private

    # Get variable names
    #
    # @return [Array] array with all variable names
    def get_variable_names
      query_string = %Q{         
        SELECT ?var_name WHERE {#{self.uri.to_ref} bd:includesColumn ?var . ?var bd:name ?var_name}
      }     
      query_results = Sparql::Query.new.query(query_string, "", [:bd])
      query_results.by_object(:var_name)
    end

end
