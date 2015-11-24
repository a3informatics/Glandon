require "uri"

class Domain
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :variables, :bcs, :namespace
  validates_presence_of :id, :managedItem, :variables, :bcs, :namespace
  
  # Constants
  C_NS_PREFIX = "mdrDomains"
  C_CLASS_NAME = "Domain"
  C_CID_PREFIX = "D"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def versionLabel
    return self.managedItem.versionLabel
  end

  def identifier
    return self.managedItem.identifier
  end

  def label
    return self.managedItem.label
  end

  def owner
    return self.managedItem.owner
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def self.baseNs
    return @@baseNs
  end

  # Find a given domain
  def self.find(id, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + ns)
    useNs = ns || @@baseNs
    
    object = self.new 
    object.id = id
    object.namespace = useNs
    object.managedItem = ManagedItem.find(id, useNs)
    object.variables = Domain::Variable.findForDomain(id, useNs)
    object.bcs = Hash.new
    ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id.to_s)
    
    results = Hash.new
    query = UriManagement.buildNs(useNs, ["bd", "mms"]) +
      "SELECT ?d WHERE\n" + 
      "{ \n" + 
      " :" + id + " bd:basedOn ?a . \n" +
      " ?b mms:context ?a . \n" +
      " ?c bd:basedOn ?b . \n" +
      " ?c bd:hasBiomedicalConcept ?d . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='d']/uri")
      if uriSet.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        object.bcs[id] = CdiscBc.find(id, namespace)
      end
    end
    return object

  end

  # Find domains for an specified SDTM IG
  #def self.findForIg(igId, igNamespace)
  #  
  #  ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
  #  ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + igNamespace)
  #  results = Hash.new
  #  query = UriManagement.buildNs(igNamespace, ["bo", "bd", "bs"]) +
  #    "SELECT ?a WHERE\n" + 
  #    "{ \n" + 
  #    " ?a rdf:type bd:Domain . \n" +
  #    "} \n"
  #                
  #  # Send the request, wait the resonse
  #  response = CRUD.query(query)
  #  
  #  # Process the response
  #  xmlDoc = Nokogiri::XML(response.body)
  #  xmlDoc.remove_namespaces!
  #  xmlDoc.xpath("//result").each do |node|
  #    uriSet = node.xpath("binding[@name='a']/uri")
  #    if uriSet.length == 1 
  #      id = ModelUtility.extractCid(uriSet[0].text)
  #      namespace = ModelUtility.extractNs(uriSet[0].text)
  #      object = self.new 
  #      object.id = id
  #      object.namespace = namespace
  #      ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + namespace)
  #      object.managedItem = ManagedItem.find(id, namespace)
  #      object.variables = Hash.new
  #      ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id.to_s)
  #      results[id] = object
  #    end
  #  end
  #  return results  
  #  
  #end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bd", "bd"]) 
    query = query +
      "SELECT ?a WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bd:Domain . \n" +
      "} \n"
      
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1 
        namespace = ModelUtility.extractNs(uriSet[0].text)
        id = ModelUtility.extractCid(uriSet[0].text)
        object = self.new 
        object.id = id
        object.namespace = namespace
        ConsoleLogger::log(C_CLASS_NAME,"all","Id=" + id.to_s)
        object.managedItem = ManagedItem.find(id, ModelUtility.extractNs(uriSet[0].text))
        object.variables = Hash.new
        results[object.id] = object
      end
    end
    return results  
    
  end

  def self.create(params)
    object = nil
    return object
  end

  def add(params)
  
    ConsoleLogger::log(C_CLASS_NAME,"add","*****Entry*****")
    
    bcs = params[:bcs]
    ConsoleLogger::log(C_CLASS_NAME,"add","BCs=" + bcs.to_s)
    
    insertSparql = ""    
    bcs.each do |key|
      ConsoleLogger::log(C_CLASS_NAME,"add","Add BC=" + key.to_s )
      parts = key.split("|")
      bcId = parts[0]
      bcNamespace = parts[1]
      bc = CdiscBc.find(bcId, bcNamespace)
      bc.properties.each do |keyP, property|
        if property[:Enabled]
          bridg = property[:bridgPath]
          sdtm = BridgSdtm::get(bridg)
          ConsoleLogger::log(C_CLASS_NAME,"add","bridg=" + bridg.to_s + " , sdtm=" + sdtm.to_s )
          if sdtm != ""
            variable = findVariableByLabel(sdtm)
            if variable != nil
              ConsoleLogger::log(C_CLASS_NAME,"add","variable=" + variable.name )
              insertSparql = insertSparql + "  :" + variable.id + " bd:hasBiomedicalConcept " + ModelUtility.buildUri(bc.namespace, bc.id) + " . \n"
              insertSparql = insertSparql + "  :" + variable.id + " bd:hasProperty " + ModelUtility.buildUri(bc.namespace, keyP) + " . \n"
            end
          end
        end
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"add","sparql=" + insertSparql )
    
    # Create the query
    update = UriManagement.buildNs(self.namespace, ["bd"]) +
      "INSERT DATA \n" +
      "{ \n" +
      insertSparql +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"add","Update success.")
    else
      ConsoleLogger::log(C_CLASS_NAME,"add","Update failed!.")
    end

  end

  def remove(params)
  
    ConsoleLogger::log(C_CLASS_NAME,"remove","*****Entry*****")
    
    bcs = params[:bcs]
    ConsoleLogger::log(C_CLASS_NAME,"remove","BCs=" + bcs.to_s)
    
    deleteSparql = ""    
    bcs.each do |key|
      ConsoleLogger::log(C_CLASS_NAME,"remove","Add BC=" + key.to_s )
      parts = key.split("|")
      bcId = parts[0]
      bcNamespace = parts[1]
      
      # Create the query
      update = UriManagement.buildNs(self.namespace, ["bd", "mms"]) +
        "DELETE \n" +
        "{ \n" +
        "  ?c bd:hasBiomedicalConcept " + ModelUtility.buildUri(bcNamespace, bcId) + " . \n" +
        "  ?c bd:hasProperty ?d . \n" +
        "} \n" + 
        "WHERE" +
        "{ \n" +
        "  :" + self.id + " bd:basedOn ?a . \n" +
        "  ?b mms:context ?a . \n" +
        "  ?c bd:basedOn ?b . \n" +
        "  ?c bd:hasBiomedicalConcept " + ModelUtility.buildUri(bcNamespace, bcId) + " . \n" +
        "  ?c bd:hasProperty ?d . \n" +
        "  filter contains(str(?d),\"" + bcId + "\")" +
        "}"

      # Send the request, wait the resonse
      response = CRUD.update(update)
      if response.success?
        ConsoleLogger::log(C_CLASS_NAME,"remove","Update success.")
      else
        ConsoleLogger::log(C_CLASS_NAME,"remove","Update failed!.")
      end

    end

  end

  def destroy
  end

private

  def findVariableByLabel(name)
    endName = name
    endName = endName.last(endName.length-2)
    ConsoleLogger::log(C_CLASS_NAME,"findVariableByLabel","End=" + endName )
    self.variables.each do |key, variable|
      ConsoleLogger::log(C_CLASS_NAME,"findVariableByLabel","Name=" + variable.name )
      if (variable.name.length == name.length) && (variable.name.last(endName.length) == endName)
        return variable
      end
    end
    return nil
  end
end
