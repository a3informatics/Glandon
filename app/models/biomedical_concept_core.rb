require "uri"

class BiomedicalConceptCore < IsoManaged
  
  attr_accessor :items
  
  C_SCHEMA_PREFIX = "cbc"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      object.items = BiomedicalConceptCore::Item.find_for_parent(object.triples, object.get_links(C_SCHEMA_PREFIX, "hasItem"))
    end
    #object.triples = ""
    return object 
  end

  def find_item(id)
    flatten = self.flatten
    items = flatten.select {|item| item.id == id}
    if items.length > 0
      return items[0]
    else
      return nil
    end
  end

  def flatten
    #ConsoleLogger::log(C_CLASS_NAME,"flatten","*****ENTRY*****")
    results = Array.new
    items.each do |item|
      more = item.flatten
      more.each do |result|
        results << result
      end
    end
    return results
  end

	def to_api_json
    result = super
    results = Array.new
    items.each do |item|
      more = item.to_api_json
      more.each do |result|
        results << result
      end
    end
    result[:children] = results
    return result
  end
  
  def to_sparql(sparql, ra, cid_prefix, instance_namespace, params)
    bc = params[:managed_item]
    template = bc[:template]
    properties = bc[:children]
    uri = super(sparql, ra, cid_prefix, instance_namespace, C_SCHEMA_PREFIX)
    sparql.triple_uri("", id, C_SCHEMA_PREFIX, "basedOn", template[:namespace], template[:id])
    #sparql.triple_primitive_type("", id, UriManagement::C_RDFS, "label", bc[:label], "string")
    ordinal = 1
    self.items.each do |item|
      sparql.triple("", id, C_SCHEMA_PREFIX, "hasItem", "", id + Uri::C_UID_SECTION_SEPARATOR + 'I' + ordinal.to_s)
      ordinal += 1
    end 
    ordinal = 1
    self.items.each do |item|
      item.to_sparql(id, ordinal, properties, sparql, C_SCHEMA_PREFIX)
      ordinal += 1
    end
    return uri
  end

  def self.all(type, ns)
    super(type, ns)
  end

  def self.unique(type, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + ns)
    results = super(type, ns)
    return results
  end

  def self.list(type, ns)
    ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + ns)
    results = super(type, ns)
    return results
  end

  def self.history(type, ns, params)
    results = super(type, ns, params)
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
      "  }\n" + 
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

private

  def self.params_valid?(params, object)
    result1 = FieldValidation::valid_identifier?(:identifier, params[:identifier], object)
    result2 = FieldValidation::valid_label?(:label, params[:label], object)
    return result1 && result2 
  end

end
