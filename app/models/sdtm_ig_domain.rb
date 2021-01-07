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
  # @return [Array] array of objects SDTM Variables
  def get_children
    results = []
    query_string = %Q{
      SELECT DISTINCT ?ordinal ?c ?type ?label ?name ?ct_and_format ?format ?description ?used ?compliance ?compliance_label ?typed_as ?typed_as_label ?classification ?classification_label ?standard WHERE       
      {         
        #{self.uri.to_ref} bd:includesColumn ?c .         
        ?c bd:ordinal ?ordinal .         
        ?c rdf:type ?type .    
        ?c isoC:label ?label .   
        ?c bd:name ?name .
        ?c bd:description ?description .         
        ?c bd:ctAndFormat ?ct_and_format .
        ?c bd:format ?format .
        OPTIONAL {?c bd:compliance ?compliance .
        ?compliance isoC:prefLabel ?compliance_label .}
        OPTIONAL {?c bd:basedOnClassVariable/bd:typedAs|bd:basedOnIgVariable/bd:basedOnClassVariable/bd:typedAs|bd:typedAs ?typed_as .
        ?typed_as isoC:prefLabel ?typed_as_label .}                 
        OPTIONAL {?c bd:basedOnClassVariable/bd:classifiedAs|bd:basedOnIgVariable/bd:basedOnClassVariable/bd:classifiedAs|bd:classifiedAs ?classification .
        ?classification isoC:prefLabel ?classification_label .}
        BIND (EXISTS {?c bd:basedOnIgVariable|bd:basedOnClassVariable ?o} as ?standard)
        OPTIONAL {?c bd:used ?used}           
      } ORDER BY ?ordinal
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :bd])
    query_results.by_object_set([:ordinal, :c, :type, :label, :name, :ct_and_format, :format, :description, :used, :compliance, :compliance_label, :typed_as, :typed_as_label, :classification, :classification_label, :standard]).each do |x|
      results << {id: x[:c].to_id ,uri: x[:c].to_s, ordinal: x[:ordinal].to_i, rdf_type: x[:type].to_s, standard: x[:standard].to_bool, label: x[:label], name: x[:name],
      ct_and_format: x[:ct_and_format], format: x[:format], description: x[:description], used: x[:used].to_bool, compliance: {id: x[:compliance].to_id, label: x[:compliance_label]}, typed_as: {id: x[:typed_as].to_id, label:x[:typed_as_label]}, classified_as: {id:x[:classification].to_id, label: x[:classification_label]} }
    end
    results
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    SdtmIg.owner
  end

  # Unique Name In Domain? Check to ensure the variable name is unique in the domain
  #
  # @params [String] name the variable name
  # @return [Boolean] true if valid, false otherwise
  def unique_name_in_domain?(name)
    var_names = get_variable_names
    return true if var_names.count(name) == 0
    variable.errors.add(:name, "duplicate detected '#{name}'")
    false
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
