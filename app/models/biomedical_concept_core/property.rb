class BiomedicalConceptCore::Property < BiomedicalConceptCore::Node

  attr_accessor :collect, :enabled, :question_text, :prompt_text, :format, :bridg_path, :simple_datatype, :complex_datatype, :coded, :tc_refs
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConceptCore::Property"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "Property"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
  
  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.coded = false
    self.collect = false
    self.enabled = false
    self.question_text = ""
    self.prompt_text = ""
    self.format = ""
    self.bridg_path = ""
    self.tc_refs = Array.new
    self.simple_datatype = BaseDatatype::C_STRING
    self.complex_datatype = nil
    if triples.nil?
      super
      self.rdf_type = C_RDF_TYPE_URI.to_s
    else
      super(triples, id)    
      paths = APP_CONFIG['bridg_path_coded']
      paths.each { |path| self.coded = true if self.bridg_path.end_with?(path) }
    end
  end

  def is_complex?
    return !self.complex_datatype.nil?
  end

  def set_coded
    self.coded = true if self.complex_datatype.nil?
  end

  def coded?
    return self.coded
  end

  def to_json_with_references
    json = self.to_json
    json[:children].each do |ref|
      tc = ThesaurusConcept.find(ref[:subject_ref][:id], ref[:subject_ref][:namespace])
      ref[:subject_data] = tc.to_json if !tc.nil?
    end
    return json
  end

	# Update
  #
  # @params params [Hash] The params hash containing the concept data {:question_text, :prompt_text, :enabled, :collect, :format}
  # @return [Boolean] true if the update is successful, false otherwise. 
  def update(params)
    result = true
    self.errors.clear
    self.question_text = "#{params[:question_text]}"
    self.prompt_text = "#{params[:prompt_text]}"
    self.enabled = params[:enabled].to_bool
    self.collect = params[:collect].to_bool
    self.format = "#{params[:format]}"
    if self.valid?
      update = UriManagement.buildNs(self.namespace, ["cbc"]) +
        # Note: Dont allow identifier or any links to be updated.
        "DELETE \n" +
        "{\n" +
        "  :" + self.id + " cbc:question_text ?a .\n" +
        "  :" + self.id + " cbc:prompt_text ?b .\n" +
        "  :" + self.id + " cbc:enabled ?c .\n" +
        "  :" + self.id + " cbc:collect ?d .\n" +
        "  :" + self.id + " cbc:format ?e .\n" +
        "}\n" +
        "INSERT \n" +
        "{ \n" +
        "  :" + self.id + " cbc:question_text \"#{self.question_text}\"^^xsd:string . \n" +
        "  :" + self.id + " cbc:prompt_text \"#{self.prompt_text}\"^^xsd:string . \n" +
        "  :" + self.id + " cbc:enabled \"#{self.enabled}\"^^xsd:boolean . \n" +
        "  :" + self.id + " cbc:collect \"#{self.collect}\"^^xsd:boolean . \n" +
        "  :" + self.id + " cbc:format \"#{self.format}\"^^xsd:string . \n" +
        "} \n" +
        "WHERE \n" +
        "{\n" +
        "  :" + self.id + " cbc:question_text ?a .\n" +
        "  :" + self.id + " cbc:prompt_text ?b .\n" +
        "  :" + self.id + " cbc:enabled ?c .\n" +
        "  :" + self.id + " cbc:collect ?d .\n" +
        "  :" + self.id + " cbc:format ?e .\n" +
        "}\n"
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
      end
    else
      result = false
    end
    return result
  end

  def remove
    update = UriManagement.buildNs(self.namespace, ["cbc"]) +
      "DELETE \n" +
      "{\n" +
      "  :" + self.id + " cbc:hasThesaurusConcept ?s .\n" +
      "  ?s ?p ?o .\n"+
      "}\n" +
      "WHERE \n" +
      "{\n" +
      "  :" + self.id + " cbc:hasThesaurusConcept ?s .\n" +
      "  ?s ?p ?o .\n"+
      "}\n"
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  def add(params)
    sparql = SparqlUpdateV2.new
    subject = {:uri => self.uri}
    params[:tc_refs].each do |ref|
      tc_ref = OperationalReferenceV2.new()
      tc_ref.subject_ref = UriV2.new({id: ref[:subject_ref][:id], namespace: ref[:subject_ref][:namespace]})
      tc_ref.ordinal = ref[:ordinal]
      ref_uri = tc_ref.to_sparql_v2(uri, "hasThesaurusConcept", 'TCR', tc_ref.ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasThesaurusConcept"}, {:uri => ref_uri})
    end
    response = CRUD.update(sparql.to_s)
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "add", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Get Properties
  #
  # @return [array] Array of leaf (property) JSON structures
  def get_properties
		results = Array.new
		if self.is_complex? 
			results += self.complex_datatype.get_properties
    else
      results << self.to_json
    end
		return results
	end

	# Set Properties
  #
  # param json [hash] The properties
  def set_properties(json)
    if self.is_complex? 
      self.complex_datatype.set_properties(json) 
    else
      json.each do |property|
        if property[:id] == self.id 
          self.collect = property[:collect]
          self.enabled = property[:enabled]
          self.question_text = property[:question_text]
          self.prompt_text = property[:prompt_text]
          self.simple_datatype = property[:simple_datatype]
          self.format = property[:format]
          self.tc_refs = []
          if !property[:children].blank?
            property[:children].each do |child|
              self.tc_refs << OperationalReferenceV2.from_json(child)
            end
          end
        end
      end
    end
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
		object = super(json)
		if !json[:complex_datatype].blank?
      object.complex_datatype = BiomedicalConceptCore::Datatype.from_json(json[:complex_datatype])
    else
      object.collect = json[:collect]
      object.enabled = json[:enabled]
      object.question_text = json[:question_text]
      object.prompt_text = json[:prompt_text]
      object.simple_datatype = json[:simple_datatype]
      object.format = json[:format]
			object.bridg_path = json[:bridg_path]
      if !json[:children].blank?
        json[:children].each do |child|
          object.tc_refs << OperationalReferenceV2.from_json(child)
        end
      end
		end
		return object
	end
	
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    if self.is_complex?
      json[:complex_datatype] = self.complex_datatype.to_json
    else
      json[:coded] = self.coded
      json[:collect] = self.collect
      json[:enabled] = self.enabled
      json[:question_text] = self.question_text
      json[:prompt_text] = self.prompt_text
      json[:simple_datatype] = self.simple_datatype
      json[:format] = self.format
      json[:bridg_path] = self.bridg_path
      json[:children] = Array.new
      self.tc_refs.each do |tc_ref|
        json[:children] << tc_ref.to_json
      end 
      json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    end
    return json
  end
  
  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{UriV2::C_UID_SECTION_SEPARATOR}P#{self.ordinal}"
    self.namespace = parent_uri.namespace
    uri = super(sparql)
    subject = {:uri => uri}
    if self.is_complex? 
      ref_uri = complex_datatype.to_sparql_v2(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasComplexDatatype"}, { :uri => ref_uri })
    else
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "question_text"}, {:literal => "#{self.question_text}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prompt_text"}, {:literal => "#{self.prompt_text}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "format"}, {:literal => "#{self.format}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "enabled"}, {:literal => "#{self.enabled}", :primitive_type => "boolean"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "collect"}, {:literal => "#{self.collect}", :primitive_type => "boolean"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "bridg_path"}, {:literal => "#{self.bridg_path}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "simple_datatype"}, {:literal => "#{self.simple_datatype}", :primitive_type => "string"})
      self.tc_refs.each do |tc_ref|
        ref_uri = tc_ref.to_sparql_v2(uri, "hasThesaurusConcept", 'TCR', tc_ref.ordinal, sparql)
        sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasThesaurusConcept"}, {:uri => ref_uri})
      end
    end
    return uri
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    if self.is_complex?
      if !self.complex_datatype.valid?
        self.copy_errors(self.complex_datatype, "Complex datatype, error:")
        result = false
      end
    else
      if !BaseDatatype::valid?(self.simple_datatype) 
        self.errors.add(:simple_datatype, "is invalid")
        result = false
      end
      result = result &&
        FieldValidation::valid_question?(:question_text, self.question_text, self) &&
        FieldValidation::valid_question?(:prompt_text, self.prompt_text, self) &&
        FieldValidation::valid_format?(:format, self.format, self)
    end
    return result
  end
	
private
  
  def self.children_from_triples(object, triples, id)
    if object.link_exists?(C_SCHEMA_PREFIX, "hasComplexDatatype")
      object.tc_refs = Array.new
      links = object.get_links(C_SCHEMA_PREFIX, "hasComplexDatatype")
      datatypes = BiomedicalConceptCore::Datatype.find_for_parent(triples, links)
      if datatypes.length > 0
        object.complex_datatype = datatypes[0]
      end
    else
      object.complex_datatype = nil
      links = object.get_links_v2(C_SCHEMA_PREFIX, "hasThesaurusConcept")
      links.each do |link|
        object.tc_refs << OperationalReferenceV2.find_from_triples(triples, link.id)
      end 
    end
    return object  
  end

end