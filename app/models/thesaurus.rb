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
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})
    
  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    IsoRegistrationAuthority.owner
  end

  # Find 
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @param children [boolean] Find all child objects. Defaults to true.
  # @return [object] The form object.
  def self.find(id, ns, children=true)   
    object = nil
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
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLiteral = ModelUtility.getValue('o', false, node)
      if predicate != ""
        triple_object = objectUri
        if triple_object == ""
          triple_object = objectLiteral
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
      end
    end
    object = new(triples, id)
    if children
      object.children = ThesaurusConcept.find_for_parent(object.triples, object.get_links(UriManagement::C_ISO_25964, "hasConcept"))
      object.children.each do |child|
        child.parentIdentifier = child.identifier
      end
    end
    return object    
  end
  
  # Find Complete thesaurus
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @return [object] The thesaurus object.
  def self.find_complete(id, ns)
    new_children = Array.new
    object = Thesaurus.find(id, ns)
    object.children.each do |child|
      new_children << ThesaurusConcept.find(child.id, child.namespace)
    end
    object.children = new_children
    return object     
  end
  
  # Find From Concept. Finds the Thesaurus form a child irrespective of depth in the tree.
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @return [object] The thesaurus object.
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

  # Find by Property values
  #
  # @param params [Hash] hash containing search parameters
  # @return [Array] array of ThesaurusConcept objects
  def find_by_property(params)
    results = []
    uris = super(params, ["hasConcept", "hasChild"], ThesaurusConcept::C_RDF_TYPE, C_SCHEMA_NS)
    uris.each { |x| results << ThesaurusConcept.find(x.id, x.namespace)}
    return results
  end

  def self.all
    return all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.list
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.history(params)
    return super(C_RDF_TYPE, C_SCHEMA_NS, params)
  end

  def self.current(params)
    return super(C_RDF_TYPE, C_SCHEMA_NS, params)
  end

  def self.current_set
  	return super(C_RDF_TYPE, C_SCHEMA_NS)    
  end

  # Create Simple
  #
  # @param params
  def self.create_simple(params)
    object = self.new 
    object.scopedIdentifier.identifier = params[:identifier]
    object.label = params[:label]
    object = Thesaurus.create(object.to_operation)
    return object
  end
  
  # Create 
  #
  # @param params [hash] {data:} The operational hash
  # @return [oject] The form object. Valid if no errors set.
  def self.create(params)
    operation = params[:operation]
    managed_item = params[:managed_item]
    object = Thesaurus.from_json(managed_item)
    object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, IsoRegistrationAuthority.owner)
    if object.valid? then
      if object.create_permitted?
        sparql = object.to_sparql_v2
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Thesaurus was not created in the database.")
        end
      end
    end
    return object
  end

  # Add a child concept
  #
  # @todo This should probably be in ThesaurusConcept?
  # @params params [hash] The params hash containig the concept data {:label, :notation. :preferredTerm, :synonym, :definition, :identifier}
  # @return [object] The object created. Errors set if create failed.
  def add_child(params)
    object = ThesaurusConcept.from_json(params)
    object.identifier = "#{object.identifier}"
    if !object.exists?
      if object.valid?
        sparql = SparqlUpdateV2.new
        object.to_sparql_v2(self.uri, sparql)
        sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_25964, :id => "hasConcept"}, {:uri => object.uri})
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Thesaurus Concept, identifier #{object.identifier}, was not created in the database.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      end
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

  # Destroy
  #
  # @return null
  def destroy
    super
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:children] = Array.new
    self.children.sort_by! {|u| u.identifier}
    self.children.each do |child|
      json[:children] << child.to_json
    end
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << ThesaurusConcept.from_json(child)
      end
    end
    return object
  end

  # To SPARQL
  #
  # @return [object] The SPARQL object created.
  def to_sparql_v2
    sparql = SparqlUpdateV2.new
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    self.children.sort_by! {|u| u.identifier}
    self.children.each do |child|
      ref_uri = child.to_sparql_v2(uri, sparql)
      sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "hasConcept"}, {:uri => ref_uri})
    end
    return sparql
  end

  # Search. The new version. Searches either the specified version or all current versions.
  # 
  # @param params [Hash]  the hash sent by datatables for a search. If namespace is empty then the 
  #                       current versions of terminolgy are searched.
  # @return [Hash]  a hash containing :count wiht the number of records that could be returned and
  #                 :items which is an array of results.
  def self.search(params)
    results = []
    variable = getOrderVariable(params[:order]["0"][:column])
    order = getOrdering(params[:order]["0"][:dir])
    if params[:namespace].blank?
      uri_set = IsoManaged.current_set(C_RDF_TYPE, C_SCHEMA_NS)
    else
      uri_set = []
      uri_set << UriV2.new({id: params[:id], namespace: params[:namespace]})
    end
    query = UriManagement.buildNs(params[:namespace], ["iso25964", "isoR"])
    query += query_string(params[:search], params[:columns], uri_set)
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    count = xmlDoc.xpath("//result").length
    query += " ORDER BY #{order} (#{variable}) OFFSET #{params[:start]} LIMIT #{params[:length]}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      process_node(node, results)
    end
    return { count: count, items: results }
  end
  
  # Impact. Determine what impact this version has.
  # 
  # @return [Array] of thesaurus concepts that have an impact
  def impact()
  	results = []
  	query = UriManagement.buildNs(UriManagement.getNs(UriManagement::C_BO), [UriManagement::C_ISO_25964, UriManagement::C_ISO_I])
  	query += %Q{
  		SELECT DISTINCT ?ctc WHERE    
			{     
			  {
			  	?a rdf:type :TcReference .
				  ?a :hasThesaurusConcept ?ctc .
				  ?ctc iso25964:identifier ?i .
				  ?ctc_p iso25964:hasChild ?ctc .
				  ?ctc_p iso25964:identifier ?i_p .
				  ?ntc iso25964:identifier ?i .
				  FILTER(CONTAINS(STR(?ntc), "#{self.namespace}"))
          ?ntc_p iso25964:hasChild ?ntc .
				  ?ntc_p iso25964:identifier ?i_p .
				  ?ctc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ctc .
				  ?ctc_t isoI:hasIdentifier ?csi .
				  ?csi isoI:version ?cv .
				  ?ntc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ntc .
				  ?ntc_t isoI:hasIdentifier ?nsi .
				  ?nsi isoI:version ?nv .
				  FILTER(?nv > ?cv)
	  			?ntc iso25964:notation ?ntc_n .
				  ?ctc iso25964:notation ?ctc_n .
				  ?ntc iso25964:definition ?ntc_d .
				  ?ctc iso25964:definition ?ctc_d .
				  ?ntc iso25964:preferredTerm ?ntc_pt .
				  ?ctc iso25964:preferredTerm ?ctc_pt .
				  ?ntc iso25964:synonym ?ntc_s .
				  ?ctc iso25964:synonym ?ctc_s .
				  ?ntc rdfs:label ?ntc_l .
				  ?ctc rdfs:label ?ctc_l .
				  FILTER(?ntc_n != ?ctc_n || ?ntc_d != ?ctc_d || ?ntc_pt != ?ctc_pt || ?ntc_s != ?ctc_s || ?ntc_l != ?ctc_l)
				} UNION {
			    ?a rdf:type :TcReference . 			  
			    ?a :hasThesaurusConcept ?ctc . 			  
			    ?ctc iso25964:identifier ?i . 			  
			    ?ctc_p iso25964:hasChild ?ctc . 			  
			    ?ctc_p iso25964:identifier ?i_p . 
			    ?ctc_t (iso25964:hasConcept|iso25964:hasChild)%2B ?ctc .
			    ?ctc_t isoI:hasIdentifier ?csi .
			    ?csi isoI:identifier ?ci .
			    FILTER (?ci = "#{self.identifier}")
			    FILTER NOT EXISTS 
			    {
			      #{self.uri.to_ref} iso25964:hasConcept+ ?ntc_p .
			    	?ntc_p iso25964:identifier ?i_p . 			  
            ?ntc_p iso25964:hasChild ?ntc .
			    	?ntc iso25964:identifier ?i . 			  
			    } 
			  }
			}
		}
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      results << UriV2.new({:uri => ModelUtility.getValue('ctc', true, node)}).to_s
    end
    return results
  end

  # Check Valid
  #
  # @return [boolean] Returns true if valid, false otherwise.
  def valid?
    return super
  end
  
private

  # Process a single node
  def self.process_node(node, results)
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
      object = ThesaurusConcept.new 
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

  # Build the search query string
  def self.query_string(search, columns, uri_set)
    query = "SELECT DISTINCT ?a ?b ?c ?d ?e ?g ?h ?k WHERE \n" +
      "  {\n" +
      "    {\n" 
    uri_set.each do |uri|
      query +=
        "      {\n" +
        "         #{uri.to_ref} iso25964:hasConcept ?a . \n" +
        "         BIND (#{uri.to_ref} as ?h) . \n" +
        "      }\n"
      query +=
        "      UNION\n" if uri != uri_set.last
    end
    query += 
      "      ?a iso25964:identifier ?b . \n" +
      "      ?a iso25964:identifier ?k . \n" +
      "      ?a iso25964:notation ?c . \n" +
      "      ?a iso25964:preferredTerm ?d . \n" +
      "      ?a iso25964:synonym ?e . \n" +
      "      ?a iso25964:definition ?g . \n" +
      "    } UNION {\n" 
    uri_set.each do |uri|
      query +=
        "      {\n" +
        "         #{uri.to_ref} iso25964:hasConcept ?x . \n" +
        "         ?x iso25964:hasChild%2B ?a . \n" +
        #"         ?x iso25964:identifier ?k .  \n" +
        "      }\n"
      query +=
        "      UNION\n" if uri != uri_set.last
    end
    query += 
      "      ?y iso25964:hasChild ?a . \n" +
      "      ?y iso25964:identifier ?k . \n" +
      "      ?a iso25964:identifier ?b . \n" +
      "      ?a iso25964:notation ?c . \n" +
      "      ?a iso25964:preferredTerm ?d . \n" +
      "      ?a iso25964:synonym ?e . \n" +
      "      ?a iso25964:definition ?g . \n" +
      #"      OPTIONAL\n" +
      #"      { \n" +
      #"        ?j iso25964:hasChild ?a .  \n" +
      #"        ?j iso25964:identifier ?k .  \n" +
      #"      } \n" +
      "    } \n"
    # Filter by search terms, columns and overall
    columns.each do |column|
      query += "    FILTER regex(#{getOrderVariable(column[0])}, \"#{column[1][:search][:value]}\", 'i') . \n" if !column[1][:search][:value].blank?
    end
    query += "    ?a (iso25964:identifier|iso25964:notation|iso25964:preferredTerm|iso25964:synonym|iso25964:definition) ?i . FILTER regex(?i, \"" + 
      search[:value] + "\", 'i') . \n" if !search[:value].blank?
    query += "  }"
    return query
  end

  # Get the correct variable to order on
  def self.getOrderVariable(col)
    columnMap = 
      {
        # See query above to map the columns to variables
        "0" => "?k", # parent identifier
        "1" => "?b", # identifier
        "2" => "?c", # notation
        "3" => "?d", # preferred term
        "4" => "?e", # synonym
        "5" => "?g"  # definition
      }  
    variable = columnMap["0"]
    if columnMap.has_key?(col)
      variable = columnMap[col]
    end
    return variable
  end  
  
  # Get the right ordering for SPARQL
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