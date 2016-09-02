class Thesaurus <  IsoManaged

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :children
 
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_ISO_25964
  C_INSTANCE_PREFIX = UriManagement::C_MDR_TH
  C_CLASS_NAME = "Thesaurus"
  C_CID_PREFIX = "TH"
  C_RDF_TYPE = "Thesaurus"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
    
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
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
    if children
      object.children = ThesaurusConcept.find_for_parent(object.triples, object.get_links(UriManagement::C_ISO_25964, "hasConcept"))
      object.children.each do |child|
        child.parentIdentifier = child.identifier
      end
    end
    #object.triples = ""
    return object    
  end
  
  def self.find_all(id, ns)
    new_children = Array.new
    object = self.find(id, ns)
    object.children.each do |child|
      new_children << ThesaurusConcept.find(child.id, child.namespace)
    end
    object.children = new_children
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

  def self.current(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.create_simple(params)
    object = self.new 
    object.errors.clear
    if params_valid_simple?(params, object)
      object.scopedIdentifier.identifier = params[:identifier]
      object.label = params[:label]
      if exists?(object.identifier, IsoRegistrationAuthority.owner()) 
        object.errors.add(:base, "The identifier is already in use.")
      else  
        object = Thesaurus.create({:data => object.to_edit(true)})
      end
    end
    return object
  end
  
  def self.create(params)
    # Get the parameters
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    # Create blank object for the errors
    object = self.new
    object.errors.clear
    # Set owner ship
    ra = IsoRegistrationAuthority.owner
    if params_valid?(managed_item, object) then
      # Build a full object. Special case, fill in the identifier, base on domain prefix.
      object = Thesaurus.from_json(data)
      # Can we create?
      if object.create_permitted?(ra)
        # Build sparql
        sparql = object.to_sparql_v2(ra)
        # Send to database
        ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Thesaurus was not created in the database.")
        end
      end
    end
    return object
  end

  def add_child(params)
    ConsoleLogger::log(C_CLASS_NAME,"add_child","params=#{params}")
    sparql = SparqlUpdateV2.new
    # Create the object
    object = self.create_sparql(params, sparql)
    if object.errors.empty?
      # Add the reference
      sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasConcept"}, {:uri => object.uri})
      # Send the request, wait the resonse
      ConsoleLogger::log(C_CLASS_NAME,"add_child","sparql=#{sparql.to_s}")
      response = CRUD.update(sparql.to_s)
      # Response
      if !response.success?
        object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, was not created in the database.")
        raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
      else
        cl = Thesaurus.find(self.id, self.namespace)
        self.children = cl.children
      end
    end
    return object
  end

  def create_sparql(params, sparql)
    object = ThesaurusConcept.from_json(params)
    # Make sure namespace set correctly
    object.namespace = self.namespace
    object.errors.clear
    if !ThesaurusConcept.exists?(object.identifier, self.namespace)
      # Create the sparql. Add the ref to the child.
      object.to_sparql_v2(self.id, sparql)
    else
      object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, already exists in the database.")
    end
    return object
  end

  # TODO: This needs looking at. used by CdiscTerm
  def self.import(params, ownerNamespace)
    object = super(C_CID_PREFIX, params, ownerNamespace, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS)
    return object
  end

  def destroy
    super(self.namespace)
  end

  def to_json
    json = super
    json[:children] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  def self.from_json(json)
    object = super(json)
    managed_item = json[:managed_item]
    if !managed_item[:children].blank?
      managed_item[:children].each do |child|
        object.children << ThesaurusConcept.from_json(child)
      end
    end
    return object
  end

  def to_sparql_v2(ra)
    sparql = SparqlUpdateV2.new
    uri = super(sparql, ra, C_CID_PREFIX, C_INSTANCE_NS, C_SCHEMA_PREFIX)
    # Now deal with the children
    self.children.each do |child|
      ref_id = child.to_sparql_v2(uri, sparql)
      sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "hasConcept"}, {:uri => ref_id})
    end
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql","SPARQL=#{sparql}")
    return sparql
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

  #def update(params)
  #  ConsoleLogger::log(C_CLASS_NAME,"update","*****Entry*****")
  #  ConsoleLogger::log(C_CLASS_NAME,"update","Params=" + params.to_s)
  #  self.errors.clear
  #  # Access the data
  #  data = params[:data]
  #  if data != nil
  #    ConsoleLogger::log(C_CLASS_NAME,"update","Delete, data=" + data.to_s)
  #    deleteItem = data[:deleteItem]
  #    updateItem = data[:updateItem]
  #    addItem = data[:addItem]
  #    # Delete items
  #    if (deleteItem != nil)
  #      ConsoleLogger::log(C_CLASS_NAME,"update","Delete, item=" + deleteItem.to_s)
  #      concept = ThesaurusConcept.find(deleteItem[:id], self.namespace)
  #      if !concept.destroy(self.namespace, self.id)
  #        self.errors.add(:base, "The concept deletion failed.")          
  #      end
  #    end
  #    # Add items
  #    if (addItem != nil)
  #      ConsoleLogger::log(C_CLASS_NAME,"update","Insert, item=" + addItem.to_s)
  #      if (addItem[:parent] == self.id) 
  #        if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
  #          ThesaurusConcept.create_top_level(addItem, self.namespace, self.id)
  #        else
  #          self.errors.add(:base, "The concept identifier already exisits.")
  #        end
  #      else
  #        if !ThesaurusConcept.exists?(addItem[:identifier], self.namespace)
  #          parentConcept = ThesaurusConcept.find(addItem[:parent], self.namespace)
  #          newConcept = ThesaurusConcept.create(addItem, self.namespace)
  #          parentConcept.add_child(newConcept, self.namespace)
  #        else
  #          self.errors.add(:base, "The concept identifier already exisits.")
  #        end
  #      end
  #    end
  #    # Update items
  #    if (updateItem != nil)
  #      ConsoleLogger::log(C_CLASS_NAME,"update","Update, item=" + updateItem.to_s)
  #      concept = ThesaurusConcept.find(updateItem[:id], self.namespace)
  #      if !concept.update(updateItem, self.namespace)
  #        self.errors.add(:base, "The concept update failed.")        
  #      end
  #    end
  #  end
  #end
  
private

  def self.params_valid?(params, object)
    result1 = ModelUtility::validIdentifier?(params[:scoped_identifier][:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    return result1 && result2 # && result3 && result4
  end

  def self.params_valid_simple?(params, object)
    result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    result2 = ModelUtility::validLabel?(params[:label], object)
    return result1 && result2 # && result3 && result4
  end

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