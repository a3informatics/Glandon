require "nokogiri"
require "uri"

class CdiscTerm < Thesaurus
  
  # Constants
  C_NS_PREFIX = "thC"
  C_CLASS_NAME = "CdiscTerm"
  C_IDENTIFIER = "CDISC Terminology"
    
  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  @@currentVersion = nil # The namespace for the current term version
    
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    #object = super(id, ns, children)
    #if children
    #  object.children.each do |child|
    #    child.set_extensible
    #  end
    #end
    object = super(id, ns, false)
    if children
      object.children = CdiscCl.find_for_parent(object.triples, object.get_links(UriManagement::C_ISO_25964, "hasConcept"))
    end
    return object
  end

  #def self.searchText(searchTerm)
  #  currentCdiscTerm = current()
  #  ConsoleLogger::log(C_CLASS_NAME,"searchText","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
  #  results = ThesaurusConcept.searchTextWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
  #  return results
  #end

  #def self.searchIdentifier(searchTerm)
  #  currentCdiscTerm = current()
  #  ConsoleLogger::log(C_CLASS_NAME,"searchIdentifier","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
  #  results = ThesaurusConcept.searchIdentifierWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
  #  return results
  #end

  def self.all
    results = Array.new
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = IsoNamespace.findByShortName("CDISC")
    end
    tSet = Thesaurus.all
    tSet.each do |thesaurus|
      if thesaurus.scopedIdentifier.namespace.shortName == @@cdiscNamespace.shortName
        results << thesaurus
      end
    end
    return results  
  end

  def self.history
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = IsoNamespace.findByShortName("CDISC")
    end
    results = Thesaurus.history({ :identifier => C_IDENTIFIER, :scope_id => @@cdiscNamespace.id })
  end

  def self.allExcept(version)
    results = self.all
    results.each do |thesaurus|
      if (version == thesaurus.version)
        results.delete(theasurus.id)
        break
      end
    end
    return results  
  end
  
  def self.allPrevious(version)
    results = self.all
    newResults = Array.new
    results.each do |thesaurus|
      if (version > thesaurus.version)
        newResults << thesaurus
      end
    end
    return newResults  
  end
  
  def self.current 
    object = nil
    if @@currentVersion == nil
      latest = nil
      results = self.all
      results.each do |thesaurus|
        if latest == nil
          latest = thesaurus
        elsif thesaurus.version > latest.version
          latest = thesaurus
        end
      end
      @@currentVersion = latest
    end
    object = @@currentVersion
    return object
  end
  
  def self.create(params)
    object = self.new
    object.errors.clear
    namespace = IsoNamespace.findByShortName("CDISC")
    identifier = C_IDENTIFIER
    version = params[:version]
    date = params[:date]
    files = params[:files]
    params[:identifier] = identifier
    params[:versionLabel] = date.to_s
    params[:label] = identifier + " " + date.to_s
    
    # Check to ensure version does not exist
    if !versionExists?(identifier, version, namespace)
      ConsoleLogger::log(C_CLASS_NAME,"create","Proceding")

      # Clean any empty entries
      files.reject!(&:blank?)

      # Determine the SI, namespace and CID
      thesaurus = Thesaurus.import(params, namespace)
      params[:si] = thesaurus.scopedIdentifier.id
      params[:ns] = thesaurus.namespace
      params[:cid] = thesaurus.id

      # Create the background job status
      job = Background.create
      job.importCdiscTerm(params)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create","Duplicate")
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
      "SELECT DISTINCT ?a1 ?b1 ?c1 ?d1 ?a2 ?c2 WHERE \n" +
      "  {\n" +
      "    ?a1 iso25964:identifier ?b1 . \n" +
      "    ?a1 iso25964:notation ?c1 . \n" +
      "    OPTIONAL \n" +
      "    {\n" +
      "      ?e1 iso25964:hasChild ?a1 . \n" +
      "      ?e1 iso25964:identifier ?d1 . \n" +
      "    }\n" +
      "    FILTER(STRSTARTS(STR(?a1), \"" + old_term.namespace + "\")) \n" +
      "    ?a2 iso25964:identifier ?b1 . \n" +
      "    ?a2 iso25964:notation ?c2 . \n" +
      "    OPTIONAL \n" +
      "    {\n" +
      "      ?e2 iso25964:hasChild ?a2 . \n" +
      "      ?e2 iso25964:identifier ?d2 . \n" +
      "    }\n" +
      "    FILTER(STRSTARTS(STR(?a2), \"" + new_term.namespace + "\")) \n" +
      "    FILTER(?c1 != ?c2 %26%26 $d1 = $d2) \n" +
      "  }"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri1Set = node.xpath("binding[@name='a1']/uri")
      uri2Set = node.xpath("binding[@name='a2']/uri")
      i1Set = node.xpath("binding[@name='b1']/literal")
      n1Set = node.xpath("binding[@name='c1']/literal")
      n2Set = node.xpath("binding[@name='c2']/literal")
      p1Set = node.xpath("binding[@name='d1']/literal")
      if uri1Set.length == 1 
        object = Hash.new 
        object = {:old_uri => uri1Set[0].text, :new_uri => uri2Set[0].text, :identifier => i1Set[0].text, 
          :old_notation => n1Set[0].text, :new_notation => n2Set[0].text, :parent_identifier => p1Set[0].text}
        results << object
      end
    end
    return results
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
