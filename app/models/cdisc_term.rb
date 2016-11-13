require "nokogiri"
require "uri"

class CdiscTerm < Thesaurus
  
  # Constants
  C_CLASS_NAME = "CdiscTerm"
  C_IDENTIFIER = "CDISC Terminology"
  
  # class variables
  @@cdisc_namespace

  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    @@cdisc_namespace ||= IsoNamespace.findByShortName("CDISC")
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @param children [boolean] Find all child objects. Defaults to true.
  # @return [object] The form object.
  def self.find(id, ns, children=true)
    object = super(id, ns, false)
    if children
      object.children = CdiscCl.find_for_parent(object.triples, object.get_links(UriManagement::C_ISO_25964, "hasConcept"))
    end
    return object
  end

  # Find Only the root object
  #
  # @param id [string] The id of the form.
  # @param namespace [hash] The raw triples keyed by id.
  # @return [object] The form object.
  def self.find_only(id, ns)
    object = IsoManaged.find(id, ns, false)
  end

  # Find Submission. Find child that has the specified submission value.
  #
  # @param value [string] The submission value
  # @return [uri] The uri of the object found, otherwise nil.
  def find_submission(value)
    uri = nil
    query = UriManagement.buildNs(self.namespace, ["iso25964"]) +
      "SELECT DISTINCT ?s WHERE \n" +
      "{ \n" +
      "  :#{self.id} iso25964:hasConcept ?s . \n" +
      "  ?s iso25964:notation \"#{value}\"^^xsd:string . \n" +
      "  FILTER(CONTAINS(STR(?s), \"#{self.namespace}\")) \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      s = ModelUtility.getValue('s', true, node)
      if !s.empty? 
        uri = UriV2.new({:uri => s})
      end
    end
    return uri
  end

  def self.all
    results = Array.new
    tSet = super
    tSet.each do |thesaurus|
      if thesaurus.scopedIdentifier.namespace.shortName == @@cdisc_namespace.shortName
        results << thesaurus
      end
    end
    return results  
  end

  def self.history
    return super({ :identifier => C_IDENTIFIER, :scope_id => @@cdisc_namespace.id })
  end

  def self.all_except(version)
    results = self.all
    results.delete_if { |h| h.scopedIdentifier.version == version }
    return results  
  end
  
  def self.all_previous(version)
    results = self.all
    results.delete_if { |h| h.scopedIdentifier.version >= version }
    return results
  end
  
  def self.current
    return super({ :identifier => C_IDENTIFIER, :scope_id => @@cdisc_namespace.id })
  end
  
  def self.create(params)
    object = self.new
    object.errors.clear
    identifier = C_IDENTIFIER
    version = params[:version]
    date = params[:date]
    files = params[:files]
    params[:identifier] = identifier
    params[:versionLabel] = date.to_s
    params[:label] = identifier + " " + date.to_s
    # Check to ensure version does not exist
    if !versionExists?(identifier, version, @@cdisc_namespace)
      # Clean any empty entries
      files.reject!(&:blank?)
      # Determine the SI, namespace and CID
      thesaurus = Thesaurus.import(params, namespace)
      params[:si] = thesaurus.scopedIdentifier.id
      params[:rs] = thesaurus.registrationState.id
      params[:ns] = thesaurus.namespace
      params[:cid] = thesaurus.id
      # Create the background job status
      job = Background.create
      job.importCdiscTerm(params)
    else
      object.errors.add(:base, "The version has already been created.")
      job = nil
    end
    return { :object => object, :job => job }
  end
  
  def self.changes
    object = self.new
    object.errors.clear
    job = Background.create
    job.changesCdiscTerm()
    return { :object => object, :job => job }
  end

  def self.compare(old_term, new_term)
    object = self.new
    object.errors.clear
    job = Background.create
    job.compareCdiscTerm(old_term, new_term)
    return { :object => object, :job => job }
  end

  def self.submission_changes
    object = self.new
    object.errors.clear
    job = Background.create
    job.submission_changes_cdisc_term()
    return { :object => object, :job => job }
  end

  def self.impact(params)
    object = self.new
    object.errors.clear
    job = Background.create
    job.submission_changes_impact(params)
    return { :object => object, :job => job }
  end

  def self.submission_diff(old_term, new_term)
    results = Array.new
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT DISTINCT ?a1 ?b1 ?c1 ?d1 ?f1 ?a2 ?c2 WHERE \n" +
      "  {\n" +
      "    {\n" +
      "      ?a1 iso25964:identifier ?b1 . \n" +
      "      ?a1 iso25964:notation ?c1 . \n" +
      "      ?a1 rdfs:label ?f1 . \n" +
      "      ?e1 iso25964:hasChild ?a1 . \n" +
      "      ?e1 iso25964:identifier ?d1 . \n" +
      "      FILTER(STRSTARTS(STR(?a1), \"" + old_term.namespace + "\")) \n" +
      "      ?a2 iso25964:identifier ?b1 . \n" +
      "      ?a2 iso25964:notation ?c2 . \n" +
      "      ?e2 iso25964:hasChild ?a2 . \n" +
      "      ?e2 iso25964:identifier ?d2 . \n" +
      "      FILTER(STRSTARTS(STR(?a2), \"" + new_term.namespace + "\")) \n" +
      "      FILTER(?c1 != ?c2 %26%26 $d1 = $d2) \n" +
      "    }\n" +
      "    UNION\n" +
      "    {\n" +
      "      ?a1 iso25964:identifier ?b1 . \n" +
      "      ?a1 iso25964:notation ?c1 . \n" +
      "      ?a1 rdfs:label ?f1 . \n" +
      "      ?e1 iso25964:hasChild ?a1 . \n" +
      "      ?e1 iso25964:identifier ?d1 . \n" +
      "      FILTER(STRSTARTS(STR(?a1), \"" + old_term.namespace + "\")) \n" +
      "      FILTER NOT EXISTS { \n" +
      "        ?a2 iso25964:identifier ?b1 . \n" +
      "        FILTER(STRSTARTS(STR(?a2), \"" + new_term.namespace + "\")) \n" +
      "      }\n" +
      "    } \n" +
      "  }"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri1Set = ModelUtility.getValue('a1', true, node)
      uri2Set = ModelUtility.getValue('a2', true, node)
      i1Set = ModelUtility.getValue('b1', false, node)
      n1Set = ModelUtility.getValue('c1', false, node)
      n2Set = ModelUtility.getValue('c2', false, node)
      p1Set = ModelUtility.getValue('d1', false, node)
      label = ModelUtility.getValue('f1', false, node)
      if !uri1Set.empty? 
        object = Hash.new 
        object = {:old_uri => uri1Set, :new_uri => uri2Set, :id => ModelUtility.extractCid(uri1Set), :namespace => ModelUtility.extractNs(uri1Set), 
          :identifier => i1Set, :label => label, :old_notation => n1Set, :new_notation => n2Set, :parent_identifier => p1Set}
        results << object
      end
    end
    return results
  end

  #def self.count(searchTerm, ns)
  #  count = 0
  #  if searchTerm == ""
  #    query = UriManagement.buildNs(ns, ["iso25964"]) +
  #      "SELECT DISTINCT (COUNT(?b) as ?total) WHERE \n" +
  #      "  {\n" +
  #      "    ?a iso25964:identifier ?b . \n" +
  #      "    FILTER(STRSTARTS(STR(?a), \"" + ns + "\"))" +
  #     "  }"
  #    response = CRUD.query(query)
  #    xmlDoc = Nokogiri::XML(response.body)
  #    xmlDoc.remove_namespaces!
  #    xmlDoc.xpath("//result").each do |node|
  #      countSet = node.xpath("binding[@name='total']/literal")
  #      count = countSet[0].text.to_i
  #    end
  #  else
  #    query = UriManagement.buildNs(ns, ["iso25964"]) + queryString(searchTerm, ns) 
  #    response = CRUD.query(query)
  #    xmlDoc = Nokogiri::XML(response.body)
  #    xmlDoc.remove_namespaces!
  #    count = xmlDoc.xpath("//result").length
  #  end
  #  return count
  #end

  #def self.search(offset, limit, col, dir, searchTerm, ns)
  #  results = Array.new
  #  variable = getOrderVariable(col)
  #  order = getOrdering(dir)
  #  query = UriManagement.buildNs(ns, ["iso25964"]) + 
  #    queryString(searchTerm, ns) + 
  #    " ORDER BY " + order + "(" + variable + ") OFFSET " + offset.to_s + " LIMIT " + limit.to_s
  #  response = CRUD.query(query)
  #  xmlDoc = Nokogiri::XML(response.body)
  #  xmlDoc.remove_namespaces!
  #  xmlDoc.xpath("//result").each do |node|
  #    processNode(node, results)
  #  end
  #  return results
  #end

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
    return results
  end

private

  def self.processNode(node, results)
    object = nil
    uriSet = node.xpath("binding[@name='a']/uri")
    idSet = node.xpath("binding[@name='b']/literal")
    nSet = node.xpath("binding[@name='c']/literal")
    ptSet = node.xpath("binding[@name='d']/literal")
    sSet = node.xpath("binding[@name='e']/literal")
    eSet = node.xpath("binding[@name='f']/literal")
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
      object.extensible = false
      object.topLevel = false
      object.parentIdentifier = ""
      if eSet.length == 1 
        object.extensible = true
      end
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
    query = "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g ?h ?k WHERE \n" +
      "  {\n" +
      "    ?a iso25964:identifier ?b . \n" +
      "    ?a iso25964:notation ?c . \n" +
      "    ?a iso25964:preferredTerm ?d . \n" +
      "    ?a iso25964:synonym ?e . \n" +
      "    ?a iso25964:definition ?g . \n" +
      "    OPTIONAL\n" +
      "    {\n" +
      "      ?a iso25964:extensible ?f . \n" +
      "    }\n" +
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
        "2" => "?g", # definition
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
