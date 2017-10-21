class SdtmModel::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :prefixed, :description, :datatype, :classification, :sub_classification
  
  # Constants
  C_SCHEMA_PREFIX = SdtmModel::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmModel::C_INSTANCE_PREFIX
  C_CLASS_NAME = "SdtmModel::Variable"
  C_CID_PREFIX = SdtmModel::C_CID_PREFIX
  C_RDF_TYPE = "ModelVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # SDTM role classification
  C_ROLE_IDENTIFIER = "Identifier"
  C_ROLE_TOPIC = "Topic"
  C_ROLE_TIMING = "Timing"
  C_ROLE_RULE = "Rule"
  C_ROLE_QUALIFIER = "Qualifier"
  C_ROLE_NONE = "None"
  
  # SDTM qualifier role sub classification
  C_ROLE_Q_NA = "Not Applicable"
  C_ROLE_Q_GROUPING = "Grouping Qualifier"
  C_ROLE_Q_RESULT = "Result Qualifier"
  C_ROLE_Q_SYNONYM = "Synonym Qualifier"
  C_ROLE_Q_RECORD = "Record Qualifier"
  C_ROLE_Q_VARIABLE = "Variable Qualifier"

  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.prefixed = false
    self.description = ""
    self.datatype = SdtmModelDatatype.new
    self.classification = EnumeratedLabel.new
    self.sub_classification = EnumeratedLabel.new
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Classification Label
  #
  # @return [String] the label, set blank if none exists
  def classification_label
    return classification.nil? ? "" : classification.label
  end

  # Sub Classification Label
  #
  # @return [String] the label, set blank if none exists
  def sub_classification_label
    return sub_classification.nil? ? "" : sub_classification.label 
  end
  
  # Datatype Label
  #
  # @return [String] the label, set blank if none exists
  def datatype_label
    return datatype.nil? ? "" : datatype.label 
  end

  # Find an item
  #
  # @params id [String] the id of the item to be found.
  # @params namespace [String] the namespace of the item to be found.
  # @raise [NotFoundError] if the object is not found.
  # @return [SdtmModel::Variable] the object found.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end
  
  # To SPARQL
  #
  # @param [UriV2] parent_uri the parent URI
	# @param [SparqlUpdateV2] sparql the SPARQL object
	# @return [UriV2] The URI
  def to_sparql_v2(parent_uri, sparql)
    self.id = "#{parent_uri.id}#{Uri::C_UID_SECTION_SEPARATOR}#{SdtmUtility.replace_prefix(self.name)}"
    self.namespace = parent_uri.namespace
    super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => self.uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "name"}, {:literal => "#{self.name}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prefixed"}, {:literal => "#{self.prefixed}", :primitive_type => "boolean"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "description"}, {:literal => "#{self.description}", :primitive_type => "string"})
		sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "typedAs"}, {:uri => self.datatype.uri})
		if self.sub_classification.nil? 
			sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "classifiedAs"}, {:uri => self.classification.uri})
		else
			sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "classifiedAs"}, {:uri => self.sub_classification.uri})
		end
		return self.uri
  end

  # To JSON
  #
  # @return [Hash] the object hash.
  def to_json
    json = super
    json[:name] = self.name
    json[:prefixed] = self.prefixed 
    json[:description] = self.description
    json[:datatype] = self.datatype.to_json
    json[:classification] = self.classification.to_json
    if !self.sub_classification.nil? 
      json[:sub_classification] = self.sub_classification.to_json
    end
    return json
  end

  # From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModel::Variable] the object created
  def self.from_json(json)
    object = super(json)
    object.name = json[:name]
    object.prefixed = json[:prefixed]
    object.description = json[:description]
    object.datatype = SdtmModelDatatype.from_json(json[:datatype])
    object.classification = SdtmModelClassification.from_json(json[:classification])
    object.sub_classification = nil
    object.sub_classification = SdtmModelClassification.from_json(json[:sub_classification]) if !json[:sub_classification].blank? 
    return object
  end

  # Update Datatype. Amend the reference. Done so references are made common
  #
  # @raise [Exceptions::ApplicationLogicError] if datatype label not present in datatypes
  # @param [Hash] datatypes a hash of datatypes index by the datatype (label)
  # @return [void] no return
  def update_datatype(datatypes)
  	if datatypes.has_key?(self.datatype.label)
  		self.datatype = datatypes[self.datatype.label] 
  	else
  		raise Exceptions::ApplicationLogicError.new(message: "Datatype #{self.datatype.label} not found. Variable #{self.name} in #{C_CLASS_NAME} object.")
  	end
  end

  # Update Clasification. Amend the reference. Don so references are common
  #
  # @raise [Exceptions::ApplicationLogicError] if classifications label not present in classifications
  # @param [Hash] classifications a hash of classifications index by the datatype (label)
  # @return [void] no return
  def update_classification(classifications)
  	if classifications.has_key?(self.classification.label)
  		self.classification = classifications[self.classification.label] 
  		if !self.sub_classification.nil? 
  			if self.sub_classification.label == SdtmModel::Variable::C_ROLE_Q_NA
  				self.sub_classification = nil
  			elsif classifications.has_key?(self.sub_classification.label) 
  				self.sub_classification = classifications[self.sub_classification.label]
		  	else
		  		text = "Sub-classification #{self.sub_classification.label} not found. Variable #{self.name} in #{C_CLASS_NAME} object."
  				raise Exceptions::ApplicationLogicError.new(message: text)
  			end
  		end
  	else
  		raise Exceptions::ApplicationLogicError.new(message: "Classification #{self.classification.label} not found. Variable #{self.name} in #{C_CLASS_NAME} object.")
  	end
  end
  
private

  def self.children_from_triples(object, triples, id, bc=nil)
    datatypes = SdtmModelDatatype.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "typedAs"))
    if datatypes.length > 0
      object.datatype = datatypes[0]
    end
    # Work out the classifcation and sub-classification
    classifications = EnumeratedLabel.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "classifiedAs"))
    if classifications.length > 0
      parents = EnumeratedLabel.find_for_parent(triples, classifications[0].get_links(C_SCHEMA_PREFIX, "parentClassification"))
      if parents.length > 0
        object.classification = parents[0]
        object.sub_classification = classifications[0]
      else
        object.classification = classifications[0]
        object.sub_classification = nil
      end
    end
  end      

end
