class BiomedicalConceptCore::Property < BiomedicalConceptCore::Node

  attr_accessor :collect, :enabled, :question_text, :prompt_text, :simple_datatype, :datatype, :format, :bridg_path, :tc_refs, :complex_datatype
  
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
    self.collect = false
    self.enabled = false
    self.question_text = ""
    self.prompt_text = ""
    self.datatype = ""
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
    end
  end

  def is_complex?
    return self.complex_datatype != nil
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
      ConsoleLogger::log(C_CLASS_NAME,"set_properties","json=#{json}")
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
		if json.has_key?([:complex_datatype])
      object.complex_datatype = BiomedicalConceptCore::Datatype.from(json(json[:complex_datatype]))
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
          object.children << OperationalReferenceV2.from_json(child)
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
    self.id = "#{parent_uri.id}#{UriV2::C_UID_SECTION_SEPARATOR}P#{ordinal}"
    self.namespace = parent_uri.namespace
    uri = super(sparql)
    subject = {:uri => uri}
    if self.is_complex? 
      uri = complex_datatype.to_sparql_v2(sparql)
      sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "hasComplexDatatype"}, { :namespace => uri })
    else
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "question_text"}, {:literal => "#{self.question_text}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prompt_text"}, {:literal => "#{self.prompt_text}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "format"}, {:literal => "#{self.format}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "enabled"}, {:literal => "#{self.enabled}", :primitive_type => "boolean"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "collect"}, {:literal => "#{self.collect}", :primitive_type => "boolean"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "bridg_path"}, {:literal => "#{self.bridg_path}", :primitive_type => "string"})
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "simple_datatype"}, {:literal => "#{self.simple_datatype}", :primitive_type => "string"})
    end  
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    result = super
    if self.is_complex?
      if !self.complex_datatype.valid?
        self.errors.add(:complex_datatype, "is invalid")
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

=begin
  def self.getDatatype (parentDatatype, count, bridg_path)
    result = ""
    if count > 0 then
      result = "CL"
    else
      if parentDatatype == "CD"
        result = "CL"
      elsif parentDatatype == "PQR"
        # TODO: This is horid. Oddity with ISO21090. 
        # TODO: Need better mechanism
        if bridg_path.ends_with?(".code")
          result = "CL"
        else
          result = "F"
        end
      elsif parentDatatype == "BL"
        result = "BL"
      elsif parentDatatype == "SC"
        result = "CL"
      elsif parentDatatype == "IVL_TS_DATETIME"
        result = "D+T"
      elsif parentDatatype == "TS_DATETIME"
        result = "D+T"
      else
        result = "S"
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Parent=" + parentDatatype + ", Result=" + result + ", Count=" + count.to_s)
    return result 
  end
=end

end