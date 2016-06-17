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
    self.variables = Hash.new
    self.bcs = Hash.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.variables = Domain::Variable.findForDomain(id, ns)
      results = Hash.new
      query = UriManagement.buildNs(ns, ["bd", "mms"]) +
        "SELECT ?d WHERE\n" + 
        "{ \n" + 
        " :" + id + " bd:basedOn ?a . \n" +
        #" ?b mms:context ?a . \n" +
        #" ?c bd:basedOn ?b . \n" +
        " :" + id + " bd:hasBiomedicalConcept ?d . \n" +
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
          object.bcs[id] = BiomedicalConcept.find(id, namespace, false)
        end
      end
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
    ConsoleLogger::log(C_CLASS_NAME,"add","*****Entry*****")
    bcs = params[:bcs]
    ConsoleLogger::log(C_CLASS_NAME,"add","BCs=" + bcs.to_s)
    insertSparql = ""    
    bcs.each do |key|
      #ConsoleLogger::log(C_CLASS_NAME,"add","Add BC=" + key.to_s )
      parts = key.split("|")
      bcId = parts[0]
      bcNamespace = parts[1]
      bc = BiomedicalConcept.find(bcId, bcNamespace)
      bc.flatten.each do |property|
        if property.enabled
          bridg = property.bridgPath
          sdtm = BridgSdtm::get(bridg)
          ConsoleLogger::log(C_CLASS_NAME,"add","bridg=" + bridg.to_s + " , sdtm=" + sdtm.to_s )
          if sdtm != ""
            variable = findVariableByLabel(sdtm)
            if variable != nil
              ConsoleLogger::log(C_CLASS_NAME,"add","variable=" + variable.name )
              insertSparql = insertSparql + "  :" + variable.id + " bd:hasProperty " + ModelUtility.buildUri(property.namespace, property.id) + " . \n"
            end
          end
        end
      end
      # Add in the domain reference
      insertSparql = insertSparql + "  :" + self.id + " bd:hasBiomedicalConcept " + ModelUtility.buildUri(bc.namespace, bc.id) + " . \n"
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
        "  :" + self.id + " bd:hasBiomedicalConcept " + ModelUtility.buildUri(bcNamespace, bcId) + " . \n" +
        "  ?c bd:hasProperty ?d . \n" +
        "} \n" + 
        "WHERE" +
        "{ \n" +
        "  :" + self.id + " bd:basedOn ?a . \n" +
        "  :" + self.id + " bd:hasBiomedicalConcept " + ModelUtility.buildUri(bcNamespace, bcId) + " . \n" +
        "  ?b mms:context ?a . \n" +
        "  ?c bd:basedOn ?b . \n" +
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

  def self.bc_impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bd", "bo", "mms"])  +
      "SELECT DISTINCT ?domain WHERE \n" +
      "{ \n " +
      "  ?domain rdf:type bd:Domain . \n " +
      "  ?domain bd:hasBiomedicalConcept " + ModelUtility.buildUri(namespace, id) + " . \n " +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      domain = ModelUtility.getValue('domain', true, node)
      if domain != ""
        id = ModelUtility.extractCid(domain)
        namespace = ModelUtility.extractNs(domain)
        results[id] = find(id, namespace, false)
      end
    end
    return results
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
