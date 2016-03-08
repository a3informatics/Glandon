require "uri"

class BiomedicalConcept < BiomedicalConceptCore
  
  attr_accessor :bct
  validates_presence_of :bct

  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CLASS_NAME = "BiomedicalConcept"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "BiomedicalConceptInstance"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
 
  def self.find(id, ns, children=true)
    object = super(id, ns)
    setAttributes(object)
    return object 
  end

  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = super
  end

  def to_edit
    result = super
    new_version = version
    op_type = "BC_UPDATE"
    if new_version?
      new_version = next_version
      op_type = "BC_NEW"
    end
    result[:operation] = op_type
    result[:source][:new_version] = new_version
    result[:template] = { :id => self.bct.id, :namespace => self.bct.namespace, :identifier => self.bct.identifier, :label => self.bct.label  }
    return result
  end

  def self.findByReference(id, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"findByReference","*****ENTRY*****")
    query = UriManagement.buildNs(ns, ["bo", "cbc"]) +
      "SELECT ?bc WHERE\n" + 
      "{ \n" + 
      " :" + id + " bo:hasBiomedicalConcept ?bc . \n" +
      " ?bc rdf:type cbc:BiomedicalConceptInstance . \n" +
      "}\n"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    results = xmlDoc.xpath("//result")
    #ConsoleLogger::log(C_CLASS_NAME,"findByReference","Results=" + results.to_s)
    if results.length == 1 
      node = results[0]
      #ConsoleLogger::log(C_CLASS_NAME,"findByReference","Node=" + node.to_s)
      uri = ModelUtility.getValue('bc', true, node)
      bcId = ModelUtility.extractCid(uri)
      bcNs = ModelUtility.extractNs(uri)
      #ConsoleLogger::log(C_CLASS_NAME,"findByReference","BC id=" + bcId + ", ns=" + bcNs)
      object = self.find(bcId, bcNs)
    else
      object = nil
    end  
    return object
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.list
    ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.create(params)
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    object = self.new 
    object.errors.clear
    data = params[:data]
    source = data[:source]
    operation = data[:operation]
    ConsoleLogger::log(C_CLASS_NAME,"create","identifier=" + source[:identifier] + ", new version=" + source[:new_version])
    ConsoleLogger::log(C_CLASS_NAME,"create","operation=" + operation)
    if create_permitted?(source[:identifier], source[:new_version].to_i, object) 
      bc = BiomedicalConceptTemplate.find(source[:id], source[:namespace])
      source[:versionLabel] = "0.1"
      sparql = SparqlUpdate.new
      uri = create_sparql(C_CID_PREFIX, source, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql)
      id = uri.getCid()
      ns = uri.getNs()
      bc.to_sparql(id, C_RDF_TYPE, C_SCHEMA_NS, data, sparql, C_SCHEMA_PREFIX)
      ConsoleLogger::log(C_CLASS_NAME,"create","Sparql=" + sparql.to_s)
      response = CRUD.update(sparql.to_s)
      if response.success?
        object = BiomedicalConceptTemplate.find(id, ns)
        object.errors.clear
        ConsoleLogger::log(C_CLASS_NAME,"create","Object created")
      else
        object.errors.add(:base, "The Biomedical Concept was not created in the database.")
        ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
      end
    end
    return object
  end

   def self.update(params)
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    object = self.new 
    object.errors.clear
    id = params[:id]
    namespace = params[:namespace]
    data = params[:data]
    source = data[:source]
    operation = data[:operation]
    ConsoleLogger::log(C_CLASS_NAME,"create","identifier=" + source[:identifier] + ", new version=" + source[:new_version])
    ConsoleLogger::log(C_CLASS_NAME,"create","operation=" + operation)
    #if create_permitted?(source[:identifier], source[:new_version].to_i, object) 
      bc = BiomedicalConcept.find(id, namespace)
      source[:versionLabel] = "0.1"
      sparql = SparqlUpdate.new
      uri = create_sparql(C_CID_PREFIX, source, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql)
      id = uri.getCid()
      ns = uri.getNs()
      ConsoleLogger::log(C_CLASS_NAME,"create","URI=" + uri.to_json.to_s)
      bc.to_sparql(id, C_RDF_TYPE, C_SCHEMA_NS, data, sparql, C_SCHEMA_PREFIX)
      ConsoleLogger::log(C_CLASS_NAME,"create","Sparql=" + sparql.to_s)
      bc.destroy # Destroys the old entry before the creation of the new item
      response = CRUD.update(sparql.to_s)
      if response.success?
        object = BiomedicalConcept.find(id, ns)
        object.errors.clear
        ConsoleLogger::log(C_CLASS_NAME,"create","Object created")
      else
        object.errors.add(:base, "The Biomedical Concept was not created in the database.")
        ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
      end
    #end
    return object
  end

  def self.impact(params)
  
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new

    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc"])  +
      "SELECT DISTINCT ?bc WHERE \n" +
      "{ \n " +
      "  ?bc rdf:type cbc:BiomedicalConceptInstance . \n " +
      "  ?bc (cbc:hasItem|cbc:hasDatatype|cbc:hasProperty|cbc:hasComplexDatatype|cbc:hasValue|cbc:nextValue)%2B ?o . \n " +
      "  ?o cbc:value " + ModelUtility.buildUri(namespace, id) + " . \n " +
      "}\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      bc = ModelUtility.getValue('bc', true, node)
      if bc != ""
        id = ModelUtility.extractCid(bc)
        namespace = ModelUtility.extractNs(bc)
        results[id] = find(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"impact","Object found, id=" + id)        
      end
    end

    return results
  end

private
  
  def self.setAttributes(object)
    if object.links.exists?(C_SCHEMA_PREFIX, "basedOn")
      bct_uri = object.links.get(C_SCHEMA_PREFIX, "basedOn")[0]
      object.bct = BiomedicalConceptTemplate.find(ModelUtility.extractCid(bct_uri), ModelUtility.extractNs(bct_uri))
    else
      object.bct = nil 
    end   
  end

end
