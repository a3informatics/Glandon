class SdtmModel::Variable < Tabular::Column
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :name, :prefixed, :description, :datatype, :classification, :sub_classification
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
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

  def initialize(triples=nil, id=nil)
    self.name = ""
    self.prefixed = false
    self.description = ""
    self.datatype = ""
    self.classification = ""
    self.sub_classification = ""
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def classification_label
    return classification.nil? ? "" : classification.label
  end

  def sub_classification_label
    return sub_classification.nil? ? "" : sub_classification.label 
  end
  
  def datatype_label
    return datatype.nil? ? "" : datatype.label 
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  def self.import_sparql(parent_id, sparql, json, datatypes, classifications)
    id = parent_id + Uri::C_UID_SECTION_SEPARATOR + SdtmUtility.replace_prefix(json[:variable_name])  
    super(id, sparql, C_SCHEMA_PREFIX, C_RDF_TYPE, json[:label])
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "ordinal", json[:ordinal].to_s, "positiveInteger")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "name", json[:variable_name], "string")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "prefixed", json[:variable_prefixed].to_s, "boolean")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "description", json[:variable_notes], "string")
    sparql.triple_primitive_type("", id, C_SCHEMA_PREFIX, "rule", "", "string")
    if datatypes.has_key?(json[:variable_type])
      sparql.triple("", id, C_SCHEMA_PREFIX, "typedAs", "", datatypes[json[:variable_type]][:id])  
    end
    key = "#{json[:variable_classification]}.#{json[:variable_sub_classification]}"
    if classifications.has_key?(key)
      sparql.triple("", id, C_SCHEMA_PREFIX, "classifiedAs", "", classifications[key][:id])   
    end
    return id
  end

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
