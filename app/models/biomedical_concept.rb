require "uri"

class BiomedicalConcept < BiomedicalConceptCore
  
  attr_accessor :template_ref
  
  # Constants
  C_CLASS_NAME = "BiomedicalConcept"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "BiomedicalConceptInstance"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Initialize
  #
  # @param triples [hash] The raw triples keyed by subject
  # @param id [string] The identifier for the concept being built from the triples
  # @return [object] The new object
  def initialize(triples=nil, id=nil)
    self.template_ref = OperationalReferenceV2.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find the object
  #
  # @param id [string] The id of the item to be found
  # @param ns [string] The namespace of the item to be found
  # @param children [boolean] Find children object, defaults to true.
  # @return [object] The new object
  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    if children
      if object.link_exists?(C_SCHEMA_PREFIX, "basedOnTeplate")
        links = object.get_links_v2(C_SCHEMA_PREFIX, "basedOnTeplate")
        object.template_ref = OperationalReferenceV2.find(links[0])
      else
        object.template_ref = nil 
      end 
    end
    return object 
  end

  def self.all
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.list
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.history(params)
    return super(C_RDF_TYPE, C_SCHEMA_NS, params)
  end

  def self.create(params)
    ConsoleLogger::log(C_CLASS_NAME, "create", "params=#{params}")
    operation = params[:operation]
    managed_item = params[:managed_item]
    object = BiomedicalConcept.from_json(managed_item)
    object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, IsoRegistrationAuthority.owner)
    if object.valid? then
      if object.create_permitted?
        sparql = object.to_sparql_v2
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Biomedical Concept was not created in the database.")
        end
      end
    end
    return object
  end

  def self.update(params)
    object = self.new 
    object.errors.clear
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    #ConsoleLogger::log(C_CLASS_NAME,"update", "managed_item=" + managed_item.to_json.to_s)
    bc = BiomedicalConcept.find(managed_item[:id], managed_item[:namespace])
    ra = IsoRegistrationAuthority.owner
    object = BiomedicalConcept.from_json(data)
    sparql = object.to_sparql(ra)
    bc.destroy # Destroys the old entry before the creation of the new item
    ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
    response = CRUD.update(sparql.to_s)
    if response.success?
      object.errors.clear
    else
      object.errors.add(:base, "The Biomedical Concept was not updated in the database.")
    end
    return object
  end

  def self.term_impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix("", ["cbc"])  +
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
        results[id] = find(id, namespace, false)
        ConsoleLogger::log(C_CLASS_NAME,"impact","Object found, id=" + id)        
      end
    end
    return results
  end

  def upgrade
    term_map = Hash.new
    thesauri = Thesaurus.unique
    thesauri.each do |item|
      params = {:identifier => item[:identifier], :scope_id => item[:owner_id]}
      history = Thesaurus.history(params)
      update_ns = ""
      history.each do |item|
        update_ns = item.namespace if item.current?
      end
      if update_ns != ""
        history.each do |item|
          term_map[item.namespace] = {:update => !item.current?, :update_ns => update_ns}
        end
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"upgrade","term_map=" + term_map.to_json.to_s)

    bc_edit = self.to_edit
    ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON=" + bc_edit.to_s)

    proceed = true
    mi = bc_edit[:managed_item]
    op = bc_edit[:operation]
    children = mi[:children]
    children.each do |child|
      term_refs = child[:values]
      term_refs.each do |term_ref|
        if term_map[term_ref[:uri_ns]][:update]
          id = term_ref[:uri_id]
          ns_old = term_ref[:uri_ns]
          ns_new = term_map[term_ref[:uri_ns]][:update_ns]
          old_cli = ThesaurusConcept.find(id, ns_old)
          new_cli = ThesaurusConcept.find(id, ns_new)
          ConsoleLogger::log(C_CLASS_NAME,"upgrade","Old CLI=" + old_cli.to_json.to_s)
          ConsoleLogger::log(C_CLASS_NAME,"upgrade","New CLI=" + new_cli.to_json.to_s)
          if ThesaurusConcept.diff?(old_cli, new_cli)
            proceed = false
          end
        end
      end
    end
    ConsoleLogger::log(C_CLASS_NAME,"upgrade","Proceed=" + proceed.to_s)

    if proceed
      children.each do |child|
        term_refs = child[:values]
        term_refs.each do |term_ref|
          if term_map[term_ref[:uri_ns]][:update]
            id = term_ref[:uri_id]
            ns_new = term_map[term_ref[:uri_ns]][:update_ns]
            term_ref[:uri_ns] = ns_new
          end
        end
      end
      ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON=" + bc_edit.to_s)
      bc_json = bc_edit.to_json.to_s
      ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON String=" + bc_json)
      if op[:action] == "CREATE"
        BiomedicalConcept.create({:data => bc_edit})
        ConsoleLogger::log(C_CLASS_NAME,"upgrade","Create BC")
      else
        BiomedicalConcept.update({:id => self.id, :namespace => self.namespace, :data => bc_edit})
        ConsoleLogger::log(C_CLASS_NAME,"upgrade","Update BC")
      end
    end
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json)
    object.template_ref = OperationalReferenceV2.from_json(json[:template_ref])
    if !json[:children].blank?
      json[:children].each do |child|
        object.items << BiomedicalConceptCore::Item.from_json(child)
      end
    end
    return object
  end
  
  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = super
    json[:template_ref] = template_ref.to_json
    json[:children] = Array.new
    self.items.each do |item|
      json[:children] << item.to_json
    end 
    json[:children] = json[:children].sort_by {|item| item[:ordinal]}
    return json
  end
  
  # To SPARQL
  #
  # @param sparql [object] The SPARQL object
  # @return [object] The URI
  def to_sparql_v2
    sparql = SparqlUpdateV2.new
    uri = super(sparql)
    self.template_ref.to_sparql_v2(sparql)
    sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "basedOnTemplate"}, { :uri => self.bct })
    return sparql
  end

  def references
    results = Array.new
    term_map = Hash.new
    bc_edit = self.to_edit
    mi = bc_edit[:managed_item]
    op = bc_edit[:operation]
    children = mi[:children]
    children.each do |child|
      if child[:enabled].to_bool
        term_refs = child[:values]
        term_refs.each do |term_ref|
          id = term_ref[:uri_id]
          ns = term_ref[:uri_ns]
          if !term_map.has_key?(ns)
            thesaurus = Thesaurus.find_from_concept(id, ns)
            term_map[ns] = thesaurus
          else  
            thesaurus = term_map[ns]
          end
          results << {cli_identifier: term_ref[:identifier], cli_notation: term_ref[:useful_1], 
            term_owner: thesaurus.owner, term_identifier: thesaurus.identifier, term_version_label: thesaurus.versionLabel, term_version: thesaurus.version}
        end
      end
    end
    return results
  end

end
