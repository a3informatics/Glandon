require "nokogiri"
require "uri"

class Thesaurus <  IsoManagedNew

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :children
  validates_presence_of :children
 
  # Constants
  C_CLASS_NAME = "Thesaurus"
  C_CID_PREFIX = "TH"
  C_SCHEMA_PREFIX = "iso25964"
  C_INSTANCE_PREFIX = "mdrTh"
  C_RDF_TYPE = "Thesaurus"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)   
    # Initialise.
    object = nil
    # Create the query and action. Not using the base class query as returns the whole terminology tree. This query is slightly
    # constrained and gets the first level only.
    query = UriManagement.buildNs(ns, [UriManagement::C_ISO_I, UriManagement::C_ISO_R, UriManagement::C_ISO_25964]) +
      "SELECT ?s ?p ?o WHERE \n" +
      "{ \n" +
      "  { \n" +
      "    :" + id + " ?p ?o .\n" +
      "    ?s ?p ?o .\n" +
      "    FILTER(CONTAINS(STR(?s), \"" + ns + "\"))  \n" +
      "  } UNION {\n" +
      "    :" + id + " iso25964:hasConcept ?s .\n" +
      "    ?s ?p ?o .\n" + 
      "    FILTER(!CONTAINS(STR(?p), \"hasChild\"))  \n" +
      "  } UNION {\n" +
      "    :" + id + " isoI:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" +
      "    :" + id + " isoR:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }\n" +
      "} ORDER BY (?s)"
    response = CRUD.query(query)
    # Process the response.
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLiteral = ModelUtility.getValue('o', false, node)
      #ConsoleLogger::log(C_CLASS_NAME,"find","p=" + predicate.to_s + ", o(uri)=" + objectUri.to_s + ", o(lit)=" + objectLiteral)
      if predicate != ""
        triple_object = objectUri
        if triple_object == ""
          triple_object = objectLiteral
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
      end
    end
    # Create the object based on the triples.
    object = new(triples, id)
    #ConsoleLogger::log(C_CLASS_NAME,"find","object=" + object.to_json.to_s)
    if children
      object.children = ThesaurusConcept.find_for_parent(object.triples, object.get_links(UriManagement::C_ISO_25964, "hasConcept"))
    end
    #object.triples = ""
    return object    
  end
  
  def self.find_from_concept(id, ns)
    result = self.new
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a (iso25964:hasConcept|iso25964:hasChild)%2B :" + id + " . \n" +   
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      result = self.find(ModelUtility.extractCid(uri), ModelUtility.extractNs(uri), false)
    end
    return result
  end

  def self.all
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.create(params)
    object = super(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end

  def self.import(params, ownerNamespace)
    object = super(C_CID_PREFIX, params, ownerNamespace, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end

  def self.count(searchTerm, ns)
    count = 0
    if searchTerm == ""
      query = UriManagement.buildNs(ns, ["iso25964"]) +
        "SELECT DISTINCT (COUNT(?b) as ?total) WHERE \n" +
        "  {\n" +
        "    ?a iso25964:identifier ?b . \n" +
        "    FILTER(STRSTARTS(STR(?a), \"" + ns + "\"))" +
        "  }"
      response = CRUD.query(query)
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        countSet = node.xpath("binding[@name='total']/literal")
        count = countSet[0].text.to_i
      end
    else
      query = UriManagement.buildNs(ns, ["iso25964"]) + queryString(searchTerm, ns) 
      response = CRUD.query(query)
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      count = xmlDoc.xpath("//result").length
    end
    return count
  end

  def self.search(offset, limit, col, dir, searchTerm, ns)
    results = Array.new
    variable = getOrderVariable(col)
    order = getOrdering(dir)
    query = UriManagement.buildNs(ns, ["iso25964"]) + 
      queryString(searchTerm, ns) + 
      " ORDER BY " + order + "(" + variable + ") OFFSET " + offset.to_s + " LIMIT " + limit.to_s
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      processNode(node, results)
    end
    return results
  end
  
  def self.next(offset, limit, ns)
    results = Array.new
    variable = getOrderVariable(0)
    order = getOrdering("asc")
    query = UriManagement.buildNs(ns, ["iso25964"]) + 
      queryString("", ns) + 
      " ORDER BY " + order + "(" + variable + ") OFFSET " + offset.to_s + " LIMIT " + limit.to_s
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      processNode(node, results)
    end
    #ConsoleLogger::log(C_CLASS_NAME,"next","Results=" + results.to_json.to_s)
    return results
  end

  def update(params)
    ConsoleLogger::log(C_CLASS_NAME,"update","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"update","Params=" + params.to_s)
    self.errors.clear
    # Access the data
    data = params[:data]
    if data != nil
      ConsoleLogger::log(C_CLASS_NAME,"update","Delete, data=" + data.to_s)
      deleteItem = data[:deleteItem]
      updateItem = data[:updateItem]
      addItem = data[:addItem]
      # Delete items
      if (deleteItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Delete, item=" + deleteItem.to_s)
        concept = ThesaurusConcept.find(deleteItem[:id], self.namespace)
        if !concept.destroy(self.namespace, self.id)
          self.errors.add(:base, "The concept deletion failed.")          
        end
      end
      # Add items
      if (addItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Insert, item=" + addItem.to_s)
        if (addItem[:parent] == self.id) 
          if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
            ThesaurusConcept.create_top_level(addItem, self.namespace, self.id)
          else
            self.errors.add(:base, "The concept identifier already exisits.")
          end
        else
          if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
            parentConcept = ThesaurusConcept.find(addItem[:parent], self.namespace)
            newConcept = ThesaurusConcept.create(addItem, self.namespace)
            parentConcept.add_child(newConcept, self.namespace)
          else
            self.errors.add(:base, "The concept identifier already exisits.")
          end
        end
      end
      # Update items
      if (updateItem != nil)
        ConsoleLogger::log(C_CLASS_NAME,"update","Update, item=" + updateItem.to_s)
        concept = ThesaurusConcept.find(updateItem[:id], self.namespace)
        if !concept.update(updateItem, self.namespace)
          self.errors.add(:base, "The concept update failed.")        
        end
      end
    end
  end
  
  def d3

    result = Hash.new
    result[:name] = self.identifier
    result[:namespace] = self.namespace
    result[:id] = self.id
    result[:label] = "";
    result[:identifier] = "";
    result[:notation] = "";
    result[:definition] = "";
    result[:synonym] = "";
    result[:preferredTerm] = "";
    result[:children] = Array.new
        
    count = 0
    index = 0
    baseChildId = ""
    if self.children.length <= 10
      self.children.each do |child|
        result[:children][index] = ThesaurusNode.new(child)
        index += 1
      end
    else      
      self.children.each do |child|
        if count == 0
          baseChildId = child.identifier;
          result[:children][index] = Hash.new
          result[:children][index][:name] = child.label
          result[:children][index][:id] = child.id
          result[:children][index][:expand] = true
          result[:children][index][:expansion] = Array.new        
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count += 1
        elsif count == 9
          result[:children][index][:name] = baseChildId + ' - ' + child.identifier
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count = 0
          index += 1        
        else
          result[:children][index][:name] = baseChildId + ' - ' + child.identifier;
          result[:children][index][:expansion][count] = ThesaurusNode.new(child)
          count += 1
        end
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"d3","D3=" + result.to_s)
    return result

  end

private

  def self.processNode(node, results)
    object = nil
    uriSet = node.xpath("binding[@name='a']/uri")
    idSet = node.xpath("binding[@name='b']/literal")
    nSet = node.xpath("binding[@name='c']/literal")
    ptSet = node.xpath("binding[@name='d']/literal")
    sSet = node.xpath("binding[@name='e']/literal")
    dSet = node.xpath("binding[@name='g']/literal")
    tlSet = node.xpath("binding[@name='h']/uri")
    parentSet = node.xpath("binding[@name='k']/literal")
    if uriSet.length == 1 
      object = CdiscCl.new 
      object.id = ModelUtility.extractCid(uriSet[0].text)
      object.namespace = ModelUtility.extractNs(uriSet[0].text)
      object.identifier = idSet[0].text
      object.notation = nSet[0].text
      object.preferredTerm = ptSet[0].text
      object.synonym = sSet[0].text
      object.definition = dSet[0].text
      object.topLevel = false
      object.parentIdentifier = ""
      if tlSet.length == 1 
        object.topLevel = true
        object.parentIdentifier = object.identifier
      end
      if parentSet.length == 1 
        object.parentIdentifier = parentSet[0].text
      end
      results.push(object)
    end
  end

  def self.queryString(searchTerm, ns)
    query = "SELECT DISTINCT ?a ?b ?c ?d ?e ?g ?h ?k WHERE \n" +
      "  {\n" +
      "    ?a iso25964:identifier ?b . \n" +
      "    ?a iso25964:notation ?c . \n" +
      "    ?a iso25964:preferredTerm ?d . \n" +
      "    ?a iso25964:synonym ?e . \n" +
      "    ?a iso25964:definition ?g . \n" +
      "    OPTIONAL\n" +
      "    {\n" +
      "      ?h iso25964:hasConcept ?a . \n" +
      "    }\n" +
      "    OPTIONAL\n" +
      "    { \n" +
      "      ?j iso25964:hasChild ?a .  \n" +
      "      ?j iso25964:identifier ?k .  \n" +
      "    } \n"
      if searchTerm != ""
        query += "    ?a ( iso25964:identifier | iso25964:notation | iso25964:preferredTerm | iso25964:synonym | iso25964:definition ) ?i . FILTER regex(?i, \"" + 
          searchTerm + "\") . \n"
      end
      query += "    FILTER(STRSTARTS(STR(?a), \"" + ns + "\"))" +
      "  }"
      return query
  end

  def self.getOrderVariable(col)
    columnMap = 
      {
        # See query above to map the columns to variables
        "0" => "?b", # identifier
        "1" => "?c", # notation
        "2" => "?f", # definition
        "3" => "?e", # synonym
        "4" => "?d"  # preferred term
      }  
    variable = columnMap["0"]
    if columnMap.has_key?(col)
      variable = columnMap[col]
    end
    return variable
  end  
  
  def self.getOrdering(dir)
    orderMap = 
      {
        "desc" => "DESC",
        "asc" => "ASC"
      }
    order = orderMap["asc"]
    if orderMap.has_key?(dir)
      order = orderMap[dir]
    end
    return order
  end


end