require "nokogiri"
require "uri"

class CdiscTerm < Thesaurus
  
  # Constants
  C_NS_PREFIX = "thC"
  C_CLASS_NAME = "CdiscTerm"
  
  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  @@currentVersion = nil # The namespace for the current term version
    
  def self.find(id, ns, children=true)
    object = super(id, ns, false)
    if children
      object.children = CdiscCl.allTopLevel(id, ns)
    end
    return object
  end

  def self.searchText(searchTerm)
    currentCdiscTerm = current()
    ConsoleLogger::log(C_CLASS_NAME,"searchText","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
    results = ThesaurusConcept.searchTextWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
    return results
  end

  def self.searchIdentifier(searchTerm)
    currentCdiscTerm = current()
    ConsoleLogger::log(C_CLASS_NAME,"searchIdentifier","Id=" + currentCdiscTerm.id + ", term=" + searchTerm)
    results = ThesaurusConcept.searchIdentifierWithNs(currentCdiscTerm.id, currentCdiscTerm.namespace, searchTerm)
    return results
  end

  def self.all
    #ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    results = Hash.new
    if @@cdiscNamespace == nil 
      @@cdiscNamespace = IsoNamespace.findByShortName("CDISC")
    end
    tSet = Thesaurus.all
    tSet.each do |key, thesaurus|
      #ConsoleLogger::log(C_CLASS_NAME,"all","CDISC NS=" + @@cdiscNamespace.shortName)
      #ConsoleLogger::log(C_CLASS_NAME,"all","TH NS=" + thesaurus.scopedIdentifier.namespace.shortName)
      if thesaurus.scopedIdentifier.namespace.shortName == @@cdiscNamespace.shortName
        results[key] = thesaurus
      end
    end
    return results  
  end

  def self.allExcept(version)
    results = self.all
    results.each do |key, thesaurus|
      if (version == thesaurus.version)
        results.delete(theasurus.id)
        break
      end
    end
    return results  
  end
  
  def self.allPrevious(version)
    results = self.all
    newResults = Hash.new
    results.each do |key, thesaurus|
      if (version > thesaurus.version)
        newResults[key] = thesaurus
      end
    end
    return newResults  
  end
  
  def self.current 
    #ConsoleLogger::log(C_CLASS_NAME,"Current","*****ENTRY*****")
    object = nil
    if @@currentVersion == nil
      #ConsoleLogger::log(C_CLASS_NAME,"Current","Current nil")
      latest = nil
      results = self.all
      results.each do |key, thesaurus|
        if latest == nil
          latest = thesaurus
        elsif thesaurus.version > latest.version
          latest = thesaurus
        end
      end
      @@currentVersion = latest
      #ConsoleLogger::log(C_CLASS_NAME,"Current","CurrentVersion Id=" + @@currentVersion.id)
    end
    object = @@currentVersion
    #ConsoleLogger::log(C_CLASS_NAME,"Current","*****EXIT***** " + object.id)   
    return object
  end
  
  def self.create(params)
    object = self.new
    namespace = IsoNamespace.findByShortName("CDISC")
    identifier = "CDISC Terminology"
    version = params[:version]
    date = params[:date]
    files = params[:files]
    params[:identifier] = identifier
    params[:versionLabel] = date.to_s
    params[:label] = identifier + " " + date.to_s
    
    # Clean any empty entries
    files.reject!(&:blank?)
    
    # Create manifest file
    manifest = Xml::buildCdiscTermImportManifest(date, version, files)
    
    #Create the thesaurus
    thesaurus = Thesaurus.import(params, namespace)
    si = thesaurus.scopedIdentifier.id
    ns = thesaurus.namespace
    cid = thesaurus.id

    # Transform the files and upload. Note the quotes around the namespace & II but not version, important!!
    Xslt.execute(manifest, "thesaurus/import/cdisc/cdiscTermImport.xsl", {:UseVersion => version, :Namespace => "'" + ns + "'", :SI => "'" + si + "'", :CID => "'" + cid + "'"}, "CT.ttl")
    
    # upload the file to the database. Send the request, wait the resonse
    publicDir = Rails.root.join("public","upload")
    outputFile = File.join(publicDir, "CT.ttl")
    response = CRUD.file(outputFile)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"Create","CDISC import success")   
    else
      ConsoleLogger::log(C_CLASS_NAME,"Create","CDISC import failed!")   
    end
    
    # Set the object
    object = thesaurus
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
    if uriSet.length == 1 
      object = CdiscCl.new 
      object.identifier = idSet[0].text
      object.notation = nSet[0].text
      object.preferredTerm = ptSet[0].text
      object.synonym = sSet[0].text
      object.definition = dSet[0].text
      object.extensible = false
      object.topLevel = false
      if eSet.length == 1 
        object.extensible = true
      end
      if tlSet.length == 1 
        object.topLevel = true
      end
      results.push(object)
    end
  end

  def self.queryString(searchTerm, ns)
    query = "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
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
      "      ?a iso25964:inScheme ?h . \n" +
      "    }\n"
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
