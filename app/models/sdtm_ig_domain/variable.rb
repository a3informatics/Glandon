class SdtmIgDomain::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :notes, :controlled_term_or_format, :compliance, :variable_ref

  # Constants
  C_SCHEMA_PREFIX = SdtmIgDomain::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = SdtmIgDomain::C_INSTANCE_PREFIX
  C_CLASS_NAME = "SdtmIgDomain::Variable"
  C_CID_PREFIX = SdtmIg::C_CID_PREFIX
  C_RDF_TYPE = "IgVariable"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # SDTM role classification
  C_CORE_REQD = "Required"
  C_CORE_PERM = "Permissible"
  C_CORE_EXP = "Expected"
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.name = ""
    self.notes = ""
    self.controlled_term_or_format = ""
    self.variable_ref = nil
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Compliance Label
  #
  # @return [String] the label, set blank if none exists
  def compliance_label
    return compliance.nil? ? "" : compliance.label
  end

  # Format. Formatis anythign that is not a CT ref, see below.
  #
  # @return [String] the format from the CT or Format field
  def format
    temp = self.controlled_term_or_format
    return temp.sub /\s*\(.+\)$/, ''
  end

  # CT. This takes the form '(NAME)' if present, otherwise a format
  #
  # @return [String] the CT from the CT or Format field
  def ct
    temp = self.controlled_term_or_format
    temp = temp.scan(/\(([^\)]+)\)/).last.first
    temp = temp.gsub(/[()]/, "")
    return temp
  rescue => e 
    return ""
  end

  # Determines if CT present in the CT/Format field
  #
  # @return [Boolean] true if a CT reference is present
  def ct?
    return !self.ct.empty?
  end

  # Find an item
  #
  # @params id [String] the id of the item to be found.
  # @params namespace [String] the namespace of the item to be found.
  # @raise [NotFoundError] if the object is not found.
  # @return [SdtmIgDomain::Variable] the object found.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

=begin
  def self.import_sparql(namespace, parent_id, sparql, json, compliance_map, class_map)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    super(namespace, id, sparql, C_SCHEMA_PREFIX, C_RDF_TYPE, json[:label])
    subject = {:namespace => namespace, :id => id}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "ordinal"}, {:literal => "#{json[:ordinal]}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "controlled_term_or_format"}, {:literal => "#{json[:variable_ct_or_format]}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{json[:variable_notes]}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "name"}, {:literal => "#{json[:variable_name]}", :primitive_type => "string"})
    # Build the reference
    if !class_map.nil?
      var_name = generic_variable_name(json)
      if !class_map[var_name].nil?
        variable = class_map[var_name]
        uri = UriV2.new({:namespace => variable.namespace, :id => variable.id})
        ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'VR'
        ref_subject = {:namespace => namespace, :id => ref_id}
        sparql.triple(subject, {:prefix => UriManagement::C_BD, :id => "basedOnVariable"}, ref_subject)
        sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id =>"CReference"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasColumn"}, {:uri => uri})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
        sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "1", :primitive_type => "positiveInteger"})
      else
        ConsoleLogger::log(C_CLASS_NAME,"import_sparql","No map for variable: #{var_name}")
      end
    else
      ConsoleLogger::log(C_CLASS_NAME,"import_sparql","No map. Name=#{json[:variable_name]}")
    end
    if compliance_map.has_key?(json[:variable_core])
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "compliance"}, {:uri => compliance_map[json[:variable_core]]})  
    end
    return id
  end
=end

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
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "controlled_term_or_format"}, {:literal => "#{self.controlled_term_or_format}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{self.notes}", :primitive_type => "string"})
		sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "compliance"}, {:uri => self.compliance.uri})
		ref_uri = self.variable_ref.to_sparql_v2(self.uri, OperationalReferenceV2::C_PARENT_LINK_VC, 'VR', 1, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => OperationalReferenceV2::C_PARENT_LINK_VC}, {:uri => ref_uri})
    return self.uri
  end

  # To JSON
  #
  # @return [Hash] the object hash.
  def to_json
    json = super
    json[:name] = self.name
    #json[:ordinal] = self.ordinal
    json[:notes] = self.notes
    json[:controlled_term_or_format] = self.controlled_term_or_format
    json[:compliance] = self.compliance.to_json
    if !self.variable_ref.nil? 
      json[:variable_ref] = self.variable_ref.to_json
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
    object.notes = json[:notes]
    object.controlled_term_or_format = json[:controlled_term_or_format]
    object.compliance = SdtmModelCompliance.from_json(json[:compliance])
    object.variable_ref = OperationalReferenceV2.from_json(json[:variable_ref])
    return object
  end

  # Update Compliance. Amend the reference. Done so references are made common
  #
  # @raise [Exceptions::ApplicationLogicError] if compliance label not present in compliances
  # @param [Hash] compliances a hash of compliances index by the datatype (label)
  # @return [void] no return
  def update_compliance(compliances)
  	if compliances.has_key?(self.compliance.label)
  		self.compliance = compliances[self.compliance.label] 
  	else
  		raise Exceptions::ApplicationLogicError.new(message: "Compliance #{self.compliance.label} not found. Variable #{self.name} in #{C_CLASS_NAME} object.")
  	end
  end
  
private

  def self.children_from_triples(object, triples, id)
    variable_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnVariable"))
    if variable_refs.length > 0
      object.variable_ref = variable_refs[0]
    end
    compliance = EnumeratedLabel.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "compliance"))
    if compliance.length > 0
      object.compliance = compliance[0]
    end
    
  end

  def self.generic_variable_name(json)
    if json[:variable_name] == json[:variable_name_minus]
      return json[:variable_name]
    else
      return SdtmUtility.add_prefix(json[:variable_name_minus])
    end
  end    

end
