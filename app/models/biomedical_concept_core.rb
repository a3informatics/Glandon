require "uri"

class BiomedicalConceptCore < IsoManaged
  
  attr_accessor :items
  
  C_SCHEMA_PREFIX = "cbc"
  
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.items = BiomedicalConceptCore::Item.findForParent(object, ns)
    end
    return object 
  end

  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Hash.new
    items.each do |iKey, item|
      more = item.flatten
      more.each do |rKey, result|
        results[rKey] = result
      end
    end
    return results
  end

	def to_edit
    results = Hash.new
    items.each do |iKey, item|
      more = item.to_edit
      more.each do |rKey, result|
        results[rKey] = result
      end
    end
    result =
      {
        :operation => "",
        :source => { :id => id, :namespace => namespace, :identifier => identifier, :label => label, :version => version, :new_version => version}, 
        :template => {},
        :properties => results
      }
    return result
  end
  
  def to_sparql(id, rdfType, schemaNs, params, sparql, prefix)
    bc = params[:source]
    template = params[:template]
    properties = params[:properties]
    sparql.triple_uri("", id, prefix, "basedOn", template[:namespace], template[:id])
    sparql.triple_primitive_type("", id, UriManagement::C_RDFS, "label", bc[:label], "string")
    
    ordinal = 1
    self.items.each do |key, item|
      sparql.triple("", id, prefix, "hasItem", "", id + Uri::C_UID_SECTION_SEPARATOR + 'I' + ordinal.to_s)
      ordinal += 1
    end
    
    ordinal = 1
    self.items.each do |key, item|
      item.to_sparql(id, ordinal, properties, sparql, prefix)
      ordinal += 1
    end
  end

  def self.all(type, ns)
    super(type, ns)
  end

  def self.unique(type, ns)
    ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + ns)
    results = super(type, ns)
    return results
  end

  def self.list(type, ns)
    ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + ns)
    results = super(type, ns)
    return results
  end

  def self.history(type, ns, identifier)
    results = super(type, identifier, ns)
    return results
  end

  def destroy
    # Create the query
    update = UriManagement.buildNs(self.namespace, [C_SCHEMA_PREFIX, "isoI", "isoR"]) +
      "DELETE \n" +
      "{\n" +
      "  ?s ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  {\n" +
      "    :" + self.id + " (:|!:)* ?s . \n" +  
      "    ?s ?p ?o . \n" +
      "    FILTER(STRSTARTS(STR(?s), \"" + self.namespace + "\"))" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoI:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoR:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }" + 
      "}\n"

    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Process response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Deleted")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Error!")
    end
  end

end
