require "uri"

class Domain::Variable < IsoConcept
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :bcs, :name, :description, :ordinal, :core, :defaultComment, :defaultCommentSet, :supplementalQualifier, 
    :used, :role, :origin, :notes, :length, :label, :datatype, :schemaDatatype, :bcRefs
  validates_presence_of :bcs, :name, :description, :ordinal, :core, :defaultComment, :defaultCommentSet, :supplementalQualifier, 
    :used, :role, :origin, :notes, :length, :label, :datatype, :schemaDatatype, :bcRefs
  
  # Constants
  C_SCHEMA_PREFIX = "bd"
  C_INSTANCE_PREFIX = "mdrDomains"
  C_CLASS_NAME = "Domain::Variable"
  C_CID_PREFIX = "DV"
  C_RDF_TYPE = "Domain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_ID_SEPARATOR = "_"

  C_ROLE = { 
    "Classifier.GroupingQualifier" => "Grouping Qualifier",
    "Classifier.RecordQualifier" => "Record Qualifier",
    "Classifier.ResultQualifier" => "Result Qualifier",
    "Classifier.RuleVariable" => "Rule Variable",
    "Classifier.SynonymQualifier" => "Synonym Qualifier",
    "Classifier.TimingVariable" => "Timing Variable",
    "Classifier.TopicVariable" => "Topic Variable",
    "Classifier.VariableQualifier" => "Variable Qualifier" }
  
  C_COMPLIANCE = {
    "Classifier.ExpectedVariable" => "Expected",
    "Classifier.PermisibleVariable" => "Permisible",
    "Classifier.RequiredVariable" => "Required" }

  C_DATATYPE = {
    "Classifier.Character" => "Character",
    "Classifier.Numeric" => "Numeric" }
  
  # Find a given variable
  def self.find(id, ns)
    object = nil
    query = UriManagement.buildNs(ns, ["bd", "mms", "cdisc"]) +
      "SELECT ?a ?name ?description ?label ?datatype ?ordinal ?format ?defComment ?defCommentSet ?type ?role ?compliance WHERE\n" + 
      "{ \n" + 
      " :" + id + " bd:basedOn ?a . \n" +
      " ?a mms:dataElementName ?name . \n" +
      " ?a mms:dataElementDescription ?description . \n" +
      " ?a mms:dataElementType ?datatype . \n" +
      " ?a mms:dataElementLabel ?label . \n" +
      " ?a mms:ordinal ?ordinal . \n" +
      " ?a cdisc:dataElementRole ?role . \n" +
      " ?a cdisc:dataElementType ?type . \n" +
      " ?a cdisc:dataElementCompliance ?compliance . \n" +
      " :" + id + " bd:format ?format . \n" +
      " :" + id + " bd:defaultComment ?defComment . \n" +
      " :" + id + " bd:defaultCommentSet ?defCommentSet . \n" + 
    "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      nameSet = node.xpath("binding[@name='name']/literal")
      descSet = node.xpath("binding[@name='description']/literal")
      sDtSet = node.xpath("binding[@name='datatype']/literal")
      labelSet = node.xpath("binding[@name='label']/literal")
      ordinalSet = node.xpath("binding[@name='ordinal']/literal")
      roleSet = node.xpath("binding[@name='role']/uri")
      dtSet = node.xpath("binding[@name='type']/uri")
      compSet = node.xpath("binding[@name='compliance']/uri")
      if nameSet.length == 1 && descSet.length == 1 
        object = self.new 
        object.id = id
        object.namespace = ns
        #ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id)
        object.name = nameSet[0].text
        object.description = descSet[0].text
        object.schemaDatatype = sDtSet[0].text
        object.label = labelSet[0].text
        object.ordinal = ordinalSet[0].text.to_i
        object.core = C_COMPLIANCE[ModelUtility.extractCid(compSet[0].text)]
        object.role = C_ROLE[ModelUtility.extractCid(roleSet[0].text)]
        object.datatype = C_DATATYPE[ModelUtility.extractCid(dtSet[0].text)]
        object.defaultComment = ""
        object.defaultCommentSet = false
        object.supplementalQualifier = false
        object.used = true
        object.notes = ""
        object.length = ""
        object.origin = ""
        object.bcRefs = findBcRefs(id, ns)
      end
    end
    return object  
    
  end

  # Find all variables for a given domain
  def self.findForDomain(domainId, domainNamespace)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForDomain","***** ENTRY *****")
    results = Hash.new
    query = UriManagement.buildNs(domainNamespace, ["bd", "mms", "cdisc"]) +
      "SELECT ?a ?b ?c ?name ?description ?label ?datatype ?ordinal ?format ?defComment ?defCommentSet ?type ?role ?compliance WHERE\n" + 
      "{ \n" + 
      " :" + domainId + " bd:basedOn ?a . \n" +
      " ?b mms:context ?a . \n" +
      " ?c bd:basedOn ?b . \n" +
      " ?b mms:dataElementName ?name . \n" +
      " ?b mms:dataElementDescription ?description . \n" +
      " ?b mms:dataElementType ?datatype . \n" +
      " ?b mms:dataElementLabel ?label . \n" +
      " ?b mms:ordinal ?ordinal . \n" +
      " ?b cdisc:dataElementRole ?role . \n" +
      " ?b cdisc:dataElementType ?type . \n" +
      " ?b cdisc:dataElementCompliance ?compliance . \n" +
      " ?c bd:format ?format . \n" +
      " ?c bd:defaultComment ?defComment . \n" +
      " ?c bd:defaultCommentSet ?defCommentSet . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      uriSet = node.xpath("binding[@name='c']/uri")
      nameSet = node.xpath("binding[@name='name']/literal")
      descSet = node.xpath("binding[@name='description']/literal")
      sDtSet = node.xpath("binding[@name='datatype']/literal")
      labelSet = node.xpath("binding[@name='label']/literal")
      ordinalSet = node.xpath("binding[@name='ordinal']/literal")
      roleSet = node.xpath("binding[@name='role']/uri")
      dtSet = node.xpath("binding[@name='type']/uri")
      compSet = node.xpath("binding[@name='compliance']/uri")
      if uriSet.length == 1 && nameSet.length == 1 && descSet.length == 1
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        #ConsoleLogger::log(C_CLASS_NAME,"findForDomain","Id=" + id)
        object = self.new 
        object.id = id
        object.namespace = namespace
        object.name = nameSet[0].text
        object.description = descSet[0].text
        object.schemaDatatype = sDtSet[0].text
        object.label = labelSet[0].text
        object.ordinal = ordinalSet[0].text.to_i
        object.core = C_COMPLIANCE[ModelUtility.extractCid(compSet[0].text)]
        object.role = C_ROLE[ModelUtility.extractCid(roleSet[0].text)]
        object.datatype = C_DATATYPE[ModelUtility.extractCid(dtSet[0].text)]
        object.defaultComment = ""
        object.defaultCommentSet = false
        object.supplementalQualifier = false
        object.used = true
        object.notes = ""
        object.length = ""
        object.origin = ""
        object.bcs = Hash.new
        results[id] = object
      end
    end
    return results
    
  end

private

  # Find a given variable
  def self.findBcRefs(id, ns)
    
    results = Hash.new

    ConsoleLogger::log(C_CLASS_NAME,"findBcRefs","***** ENTRY *****")
    object = nil
    query = UriManagement.buildNs(ns, ["bd", "cbc"]) +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " :" + id + " bd:hasProperty ?a . \n" +
      " ?a (cbc:isPropertyOf|cbc:isDatatypeOf|cbc:isItemOf)%2B ?b . \n" +
      " ?b rdf:type cbc:BiomedicalConceptInstance . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"findBCRefs","Node=" + node)
      bcSet = node.xpath("binding[@name='b']/uri")
      pSet = node.xpath("binding[@name='a']/uri")
      if bcSet.length == 1 && pSet.length == 1 
        id = ModelUtility.extractCid(bcSet[0].text)
        namespace = ModelUtility.extractNs(bcSet[0].text)
        property = ModelUtility.extractCid(pSet[0].text)
        object = Hash.new
        object[:id] = id
        object[:namespace] = namespace
        object[:property] = property
        results[id] = object
      end
    end
    return results
    
  end  
end
