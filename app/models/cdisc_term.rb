class CdiscTerm < Thesaurus
  
  C_IDENTIFIER = "CT"

  @@cdisc_ra = nil

=begin  
  
  # Constants
  C_CLASS_NAME = "CdiscTerm"
  C_SCHEMA_PREFIX = Thesaurus::C_SCHEMA_PREFIX
  C_INSTANCE_PREFIX = Thesaurus::C_INSTANCE_PREFIX
  C_CID_PREFIX = Thesaurus::C_CID_PREFIX
  C_RDF_TYPE = Thesaurus::C_RDF_TYPE
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # class variables
  @@cdisc_ra = nil

  # Initialize the object
  #
  # @param triples [hash] The raw triples keyed by id
  # @param id [string] The id of the form
  # @return [object] The form object
  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

=end

  # Owner
  #
  # @return [IsoRegistrationAuthority] the owner
  def self.owner
    return @@cdisc_ra if !@@cdisc_ra.nil?
    @@cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    @@cdisc_ra.freeze
  end

  def self.child_klass
    ::CdiscCl
  end

  # Configuration
  #
  # @return [Hash] the configuration hash
  def self.configuration
    #schema_namespace = Namespaces.namespace(:iso25964)
    { 
      #schema_namespace: schema_namespace,
      #instance_namespace: Namespaces.namespace(:mdrTH),
      #cid_prefix: "TH",
      #rdf_type: Uri.new({namespace: schema_namespace, fragment: "Thesaurus"})
      identifier: C_IDENTIFIER
    }
  end

  # Configuration
  #
  # @return [Hash] the configuration hash
  def configuration
    self.class.configuration
  end

  def add(item, ordinal)
    ref = OperationalReferenceV3::TcReference.new(ordinal: ordinal, reference: item.uri)
    ref.uri = ref.create_uri(self.uri)
    self.is_top_concept_reference << ref
    self.is_top_concept << item.uri
  end

  def changes(length)
    final = {}
    cl_set = {}
    versions = []
    start = 0

    items = self.class.history(identifier: C_IDENTIFIER, scope: owner)
    first = items.index {|x| x.uri == self.uri}    
    if first == 0 
      start = 0 
      final["dummy"] = {version: "0", date: "", children: []} if first == 0
    else
      start = first - 1
      final = {}
    end    
    versions_set = items.map {|e| e.uri}
    versions_set = versions_set[start, first + length - 1]
    query_string = %Q{SELECT ?e ?v ?d ?i ?cl ?l ?n WHERE
{
  #{versions_set.map{|x| "{ #{x.to_ref} th:isTopConceptReference ?r . #{x.to_ref} isoT:creationDate ?d . #{x.to_ref}isoT:hasIdentifier ?si1 . ?si1 isoI:version ?v . BIND (#{x.to_ref} as ?e)} "}.join(" UNION\n")}
  ?r bo:reference ?cl .
  ?cl isoT:hasIdentifier ?si2 .
  ?cl isoC:label ?l .
  ?cl th:notation ?n .
  ?si2 isoI:identifier ?i .
}}
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :th, :bo])
    results = query_results.by_object_set([:e, :v, :d, :i, :cl, :l, :n])

    results.each do |entry|
      uri = entry[:e].to_s
      final[uri] = {version: entry[:v], date: entry[:d].to_time_with_default.strftime("%Y-%m-%d"), children: []} if !final.key?(uri)
      final[uri][:children] << DiffResult[key: entry[:i], uri: entry[:cl], label: entry[:l], notation: entry[:n]]
    end

    the_results = []
    final.sort_by {|k,v| v[:version]}
    final.each {|k,v| versions << v[:date]}
    versions = versions.drop(1)
    previous_version = nil
    initial_status = [:not_present] * versions.length
    final.each do |uri, version|
      version[:children].each do |entry|
        key = entry[:key].to_sym
        next if cl_set.key?(key)
        cl_set[key] = {key: entry[:key], label: entry[:label] , notation: entry[:notation], status: initial_status.dup}
      end
    end
    final.each do |uri, version|
      ver = version[:version].to_i - start - 2
      if previous_version.nil?
        # nothing needed?
      else
        # :created = B-A
        # :updated = A Union B URI != URI
        # :no_change = A Union B URI == URI
        # :deleted = A-B
        new_items = version[:children] - previous_version[:children]
        common_items = version[:children] & previous_version[:children]
        deleted_items = previous_version[:children] - version[:children]
        new_items.each do |entry|
          cl_set[entry[:key].to_sym][:status][ver] = :created
        end
        common_items.each do |entry|
          prev = previous_version[:children].find{|x| x[:key] == entry[:key]}
          curr = version[:children].find{|x| x[:key] == entry[:key]}
          cl_set[entry[:key].to_sym][:status][ver] = curr.no_change?(prev) ? :no_change : :updated
        end
        deleted_items.each do |entry|
          cl_set[entry[:key].to_sym][:status][ver] = :deleted
        end
      end
      previous_version = version
    end
    {versions: versions, items: cl_set}
  end

  class DiffResult < Hash

    def no_change?(other_hash)
      self[:uri] == other_hash[:uri]
    end

    def eql?(other_hash)
      self[:key] == other_hash[:key]
    end

    def hash
      self[:key].hash
    end

  end
=begin
  # Get the next version
  #
  # @return [integet] the integer version
  def self.next_version
    super(C_IDENTIFIER, owner)
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

  # Find Only the root object.
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

  # Find all items.
  #
  # @return [array] Array of objects found.
  def self.all
    results = Array.new
    tSet = super
    tSet.each do |thesaurus|
      results << thesaurus if thesaurus.owner.ra_namespace.uri == cdisc_namespace.uri
    end
    results.sort_by! {|u| u.version}
    return results  
  end

  # Find history
  #
  # @return [array] An array of objects.
  def self.history
    return super({ :identifier => C_IDENTIFIER, :scope => cdisc_namespace })
  end

  # Find all except the specified version.
  #
  # @param version [integer] The version not to be found.
  # @return [array] Array of objects found.
  def self.all_except(version)
    results = self.all
    results.delete_if { |h| h.scopedIdentifier.version == version }
    return results  
  end
  
  # Find all versions previous to the specified version.
  #
  # @param version [integer] The version not to be found.
  # @return [array] Array of objects found.
  def self.all_previous(version)
    results = self.all
    results.delete_if { |h| h.scopedIdentifier.version >= version }
    return results
  end
  
  # Find the current item
  #
  # @return [object] The object or nil if no current version.
  def self.current
    return super({ :identifier => C_IDENTIFIER, :scope => cdisc_namespace })
  end
  
  # Create a new version. This is an import and runs in the background.
  #
  # @param params [Hash] The parameters
  # @option opts [String] :date The release date of the version being created
  # @option opts [String] :version The version being created
  # @option opts [String] :files Array of files being used 
  # @return [Hash] A hash containing any errors and the background job reference.
  def self.create(params)
    job = nil
    object = self.new
    if params_valid?(object, params)
    	files = params[:files]
    	version = params[:version]
    	date = params[:date]
    	# Save the core info
      object.label = "#{C_IDENTIFIER} #{params[:date]}"
      object.scopedIdentifier.identifier = C_IDENTIFIER
      object.scopedIdentifier.versionLabel = params[:date]
      # Build the full object
      operation = object.to_operation
      operation[:new_version] = params[:version]
      operation[:new_state] = IsoRegistrationState.releasedState
      object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, owner)
      # Check the full object
      if object.valid? then
        ConsoleLogger.debug(C_CLASS_NAME, "create", "Valid 2")
        if object.create_permitted?
          files.reject!(&:blank?)
          params[:identifier] = object.identifier
          params[:versionLabel] = object.versionLabel
          params[:label] = object.label
          params[:si] = object.scopedIdentifier.id
          params[:rs] = object.registrationState.id
          params[:ns] = object.namespace
          params[:cid] = object.id
          job = Background.create
          job.import_cdisc_term(params)
        end
      end
    end
    return { :object => object, :job => job }
  end

  def self.build(params)
    super(params, IsoRegistrationAuthority.find_by_short_name("CDISC"))
  end
    
  # Initiate background job to create cross references
  #
  # @param params [Hash] The parameters
  # @option [String] :version The version to whcih the xrefs refer
  # @option [String] :files Array of files, should be single entry
  # @return [Hash] A hash containing any errors and the job reference.
  def create_cross_reference(params)
    object = CdiscTerm.new
    object.errors.clear
    job = Background.create
    job.import_cdisc_term_changes(params)
    return { :object => object, :job => job }
  end

  
  # Initiate background job to detect all changes
  #
  # @return [Hash] A hash containing any errors and the job reference.
  def self.changes
    object = self.new
    object.errors.clear
    job = Background.create
    job.changes_cdisc_term()
    return { :object => object, :job => job }
  end

  # Initiate background job to detect all changes
  #
  # @param old_term [Object] The old CDISC terminology
  # @param new_term [Object] The new CDISC terminology
  # @return [Hash] A hash containing any errors and the job reference.
  def self.compare(old_term, new_term)
    object = self.new
    object.errors.clear
    job = Background.create
    job.compare_cdisc_term([old_term, new_term])
    return { :object => object, :job => job }
  end

  # Initiate background job to detect all submission value (notation) changes
  #
  # @return [Hash] A hash containing any errors and the job reference.
  def self.submission_changes
    object = self.new
    object.errors.clear
    job = Background.create
    job.submission_changes_cdisc_term()
    return { :object => object, :job => job }
  end

  # Initiate background job to detect impact of all submission value (notation) changes
  #
  # @return [Hash] A hash containing any errors and the job reference.
  def self.impact(params)
    object = self.new
    object.errors.clear
    job = Background.create
    job.submission_changes_impact(params)
    return { :object => object, :job => job }
  end

  # Get differences in notations (submission value) between two terminology versions
  #
  # @param old_term [Object] The old CDISC terminology
  # @param new_term [Object] The new CDISC terminology
  # @return [Hash] A hash containing any errors and the job reference.
  def self.submission_difference(old_term, new_term)
    results = {}
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT DISTINCT ?a1 ?b1 ?c1 ?d1 ?f1 ?g1 ?a2 ?c2 WHERE \n" +
      "  {\n" +
      "    {\n" +
      "      ?a1 iso25964:identifier ?b1 . \n" +
      "      ?a1 iso25964:notation ?c1 . \n" +
      "      ?a1 iso25964:preferredTerm ?g1 . \n" +
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
      "      ?a1 iso25964:preferredTerm ?g1 . \n" +
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
      uri1 = ModelUtility.getValue('a1', true, node)
      uri2 = ModelUtility.getValue('a2', true, node)
      i1 = ModelUtility.getValue('b1', false, node)
      n1 = ModelUtility.getValue('c1', false, node)
      n2 = ModelUtility.getValue('c2', false, node)
      p1 = ModelUtility.getValue('d1', false, node)
      label = ModelUtility.getValue('f1', false, node)
      pt = ModelUtility.getValue('g1', false, node)
      if !uri1.empty? 
        object = 
        {
          :previous_uri => UriV2.new({uri: uri1}), 
          :current_uri => UriV2.new({uri: uri2}), 
          :identifier => i1, 
          :label => label, 
          :preferred_term => pt, 
          :result => { :previous => n1, :current => n2 },
          :parent_identifier => p1
        }
        results["#{p1}.#{i1}".to_sym] = object
      end
    end
    return results
  end

  # Differences between this and another terminology. Details for the terminology
  # and a staus on the children.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Hash] The differenc hash
  def self.difference(previous, current)
    results = super(previous, current)
    children = {}
    if previous.nil? && current.nil?
      children = {}
    elsif previous.nil?
      current.children.each do |child|
        children[child.identifier.to_sym] = 
        { 
          status: :created, 
          identifier: child.identifier, 
          preferred_term: child.preferredTerm, 
          notation: child.notation, id: child.id, 
          namespace: child.namespace
        }
      end
    elsif current.nil?
      previous.children.each do |child|
        children[child.identifier.to_sym] = 
        { 
          status: :deleted, 
          identifier: child.identifier, 
          preferred_term: child.preferredTerm, 
          notation: child.notation, 
          id: child.id, namespace: 
          child.namespace
        }
      end
    else
      deleted = current.deleted_set(previous, "children", "identifier" )
      current_index = Hash[current.children.map{|x| [x.identifier, x]}]
      previous_index = Hash[previous.children.map{|x| [x.identifier, x]}]
      current.children.each do |child|
        status = :no_change
        previous = previous_index[child.identifier]
      	if previous.nil? 
          status = :created
        else
      		#update_cl(child)
    			#update_cl(previous)
        	#status = :updated if CdiscCl.diff?(previous, child)
        	status = :updated if CdiscCl.new_diff?(previous, child)
    		end
        children[child.identifier.to_sym] = 
        { 
          status: status, 
          identifier: child.identifier, 
          preferred_term: child.preferredTerm, 
          notation: child.notation, 
          id: child.id, 
          namespace: child.namespace
        }
      end
      deleted.each do |deleted|
        item = previous_index[deleted]
        children[deleted.to_sym] = 
        { 
          status: :deleted, 
          identifier: item.identifier, 
          preferred_term: item.preferredTerm, 
          notation: item.notation, 
          id: item.id, 
          namespace: item.namespace
        }
      end
    end
    results[:children] = children
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
    return results
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    super
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.children = []
    json[:children].each {|child| object.children << CdiscCl.from_json(child)} if !json[:children].blank?
    return object
  end

  def to_csv_no_header
    results = []  
    children.each do |c|
      results += CdiscCl.find(c.id, c.namespace).to_csv_no_header(c.identifier)
    end
    return results
  end

  def to_csv
    headers = ["Code","Codelist Code","Codelist Extensible (Yes/No)","Codelist Name","CDISC Submission Value","CDISC Synonym(s)","CDISC Definition","NCI Preferred Term"]
    data = to_csv_no_header
    generate_csv(headers, data)
  end

private

	# Check Params Valid
  def self.params_valid?(object, params)
    object.errors.clear
    result = FieldValidation.valid_files?(:files, params[:files], object) &&
    	FieldValidation.valid_version?(:version, params[:version], object) &&
      FieldValidation.valid_date?(:date, params[:date], object)
    return result
  end

  # Update the Code List
	def self.update_cl(cl)
		if cl.children.empty?
			new_cl = CdiscCl.find(cl.id, cl.namespace)
			cl.children = new_cl.children
		end
	end

  # CDISC namespace
  def self.cdisc_namespace
    return owner.ra_namespace
  end

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
=end
  
end
