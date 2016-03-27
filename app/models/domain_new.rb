require "uri"

class Domain < IsoManagedNew
  
  attr_accessor :variables, :bcs
  validates_presence_of :variables, :bcs
  
  # Constants
  C_SCHEMA_PREFIX = "bd"
  C_INSTANCE_PREFIX = "mdrDomains"
  C_CLASS_NAME = "Domain"
  C_CID_PREFIX = "D"
  C_RDF_TYPE = "Domain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  def initialize(triples=nil, id=nil)
    self.variables = Array.new
    self.bcs = Array.new
    if triples.nil?
      super
      self.label = "New Form"
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.groups = Domain::Variable.find_for_parent(object.triples, object.get_links("bf", "hasGroup"))
      object.bcs = find_bcs
    end
    object.triples = ""
    return object     
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    #ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def add(params)
    bcs = params[:bcs]
    insertSparql = ""    
    bcs.each do |key|
      parts = key.split("|")
      bcId = parts[0]
      bcNamespace = parts[1]
      bc = BiomedicalConcept.find(bcId, bcNamespace)
      bc.flatten.each do |keyP, property|
        if property.enabled
          bridg = property.bridgPath
          sdtm = BridgSdtm::get(bridg)
          if sdtm != ""
            variable = findVariableByLabel(sdtm)
            if variable != nil
              insertSparql = insertSparql + "  :" + variable.id + " bd:hasBiomedicalConcept " + ModelUtility.buildUri(bc.namespace, bc.id) + " . \n"
              insertSparql = insertSparql + "  :" + variable.id + " bd:hasProperty " + ModelUtility.buildUri(bc.namespace, keyP) + " . \n"
            end
          end
        end
      end
    end
    # Create the query
    update = UriManagement.buildNs(self.namespace, ["bd"]) +
      "INSERT DATA \n" +
      "{ \n" +
      insertSparql +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  def remove(params)
    bcs = params[:bcs]
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
      if !response.success?
        ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
        raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
      end
    end
  end

  def self.impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bd", "bo", "mms"])  +
      "SELECT DISTINCT ?domain WHERE \n" +
      "{ \n " +
      "  ?domain rdf:type bd:Domain . \n " +
      "  ?domain bd:basedOn/^mms:context ?column . \n " +
      "  ?variable bd:basedOn ?column . \n " +
      "  ?variable bd:hasBiomedicalConcept " + ModelUtility.buildUri(namespace, id) + " . \n " +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"impact","Node=" + node.to_s)
      domain = ModelUtility.getValue('domain', true, node)
      if domain != ""
        id = ModelUtility.extractCid(domain)
        namespace = ModelUtility.extractNs(domain)
        results[id] = find(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"impact","Object found, id=" + id)        
      end
    end
    return results
  end

private

  def self.find_bcs
    results = Array.new
    query = UriManagement.buildNs(ns, ["bd", "mms"]) +
      "SELECT ?d WHERE\n" + 
      "{ \n" + 
      " :" + id + " bd:basedOn ?a . \n" +
      " ?b mms:context ?a . \n" +
      " ?c bd:basedOn ?b . \n" +
      " ?c bd:hasBiomedicalConcept ?d . \n" +
      "}"        
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = node.xpath("binding[@name='d']/uri")
      if uri.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        results << BiomedicalConcept.find(id, namespace, false)
      end
    end
    return results
  end

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
