class Thesaurus::Concept < IsoConceptV2

  # Add a child concept
  #
  # @params params [Hash] the params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [ThesaurusCocncept] the object created. Errors set if create failed.
  def add_child(params)
    object = ThesaurusConcept.from_json(params)
    object.identifier = "#{self.identifier}.#{object.identifier}"
    if !object.exists?
      if object.valid?
        sparql = SparqlUpdateV2.new
        object.to_sparql_v2(self.uri, sparql)
        sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasChild"}, {:uri => object.uri})
        response = CRUD.update(sparql.to_s)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME, "add_child", "The Thesaurus Concept, identifier #{object.identifier}, was not created")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      end
    else
      object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, already exists")
    end
    return object
  end

  def set_parent
  	results = ""
  	query = UriManagement.buildNs(UriManagement.getNs(UriManagement::C_BO), [UriManagement::C_ISO_25964])
  	query += %Q{
  		SELECT DISTINCT ?i WHERE    
			{     
				?s iso25964:hasChild #{self.uri.to_ref} .
  			?s iso25964:identifier ?i .
			}
		}
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      self.parentIdentifier  = ModelUtility.getValue('i', false, node)
    end
  end

  # To CSV No Header. A CSV record with no header
  #
  # @return [Array] the CSV record
  def to_csv_no_header
    to_csv_by_key(:identifier, :label, :notation, :synonym, :definition, :preferredTerm)
  end

end