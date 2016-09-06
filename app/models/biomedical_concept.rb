require "uri"

class BiomedicalConcept < BiomedicalConceptCore
  
  attr_accessor :bct
  validates_presence_of :bct

  # Constants
  C_CLASS_NAME = "BiomedicalConcept"
  C_INSTANCE_PREFIX = "mdrBcs"
  C_CID_PREFIX = "BC"
  C_RDF_TYPE = "BiomedicalConceptInstance"
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns, children=true)
    object = super(id, ns, children)
    if children
      if object.link_exists?(C_SCHEMA_PREFIX, "basedOn")
        bct_uri = object.get_links(C_SCHEMA_PREFIX, "basedOn")[0]
        # TODO: Don't get the template, not used as yet. Think about this this, save a query or two.
        # TODO: Amended to put back in. Used when editing the BC. 
        object.bct = BiomedicalConceptTemplate.find(ModelUtility.extractCid(bct_uri), ModelUtility.extractNs(bct_uri), false)
        #object.bct = nil 
      else
        object.bct = nil 
      end 
    end
    return object 
  end

  def flatten
    results = super
  end

  def to_api_json
    result = super
    result[:type] = "Biomedical Concept"
    result[:template] = { :id => self.bct.id, :namespace => self.bct.namespace, :identifier => self.bct.identifier, :label => self.bct.label  }
    return result
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.list
    ConsoleLogger::log(C_CLASS_NAME,"list","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.create(params)
    #ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    object = self.new 
    object.errors.clear
    ConsoleLogger::log(C_CLASS_NAME,"create","data=" + params[:data].to_s)
    data = params[:data]
    managed_item = data[:managed_item]
    operation = data[:operation]
    ConsoleLogger::log(C_CLASS_NAME,"create","identifier=#{managed_item[:identifier]}, new version=#{operation[:new_version]}")
    ConsoleLogger::log(C_CLASS_NAME,"create","operation=#{operation}")
    if params_valid?(managed_item, object) then
      ra = IsoRegistrationAuthority.owner
      if create_permitted?(managed_item[:identifier], operation[:new_version].to_i, object, ra) 
        bc = BiomedicalConceptTemplate.find(managed_item[:id], managed_item[:namespace])
        sparql = SparqlUpdate.new
        bc.scopedIdentifier.identifier = managed_item[:identifier]
        bc.label = managed_item[:label]
        bc.scopedIdentifier.version = operation[:new_version].to_i
        bc.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
        bc.registrationState.previousState = managed_item[:state]
        bc.registrationState.registrationStatus = operation[:new_state]
        uri = bc.to_sparql(sparql, ra, C_CID_PREFIX, C_INSTANCE_NS, data)
        ConsoleLogger::log(C_CLASS_NAME,"create","SPARQL=#{sparql}")
        response = CRUD.update(sparql.to_s)
        if response.success?
          object = BiomedicalConceptTemplate.find(uri.id, uri.namespace)
          object.errors.clear
        else
          object.errors.add(:base, "The Biomedical Concept was not created in the database.")
        end
      end
    end
    return object
  end

   def self.update(params)
    object = self.new 
    object.errors.clear
    id = params[:id]
    namespace = params[:namespace]
    data = params[:data]
    managed_item = data[:managed_item]
    operation = data[:operation]
    ConsoleLogger::log(C_CLASS_NAME,"create","identifier=" + managed_item[:identifier] + ", new version=" + operation[:new_version].to_s)
    ConsoleLogger::log(C_CLASS_NAME,"create","operation=" + operation.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"create","label=" + managed_item[:label])
    bc = BiomedicalConcept.find(id, namespace)
    sparql = SparqlUpdate.new
    ra = IsoRegistrationAuthority.owner
    #bc.scopedIdentifier.identifier = managed_item[:identifier]
    bc.label = managed_item[:label]
    bc.scopedIdentifier.version = operation[:new_version].to_i
    #bc.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    bc.registrationState.previousState = managed_item[:state]
    bc.registrationState.registrationStatus = operation[:new_state]
    uri = bc.to_sparql(sparql, ra, C_CID_PREFIX, C_INSTANCE_NS, data)
    ConsoleLogger::log(C_CLASS_NAME,"create","SPARQL=#{sparql}")
    bc.destroy # Destroys the old entry before the creation of the new item
    response = CRUD.update(sparql.to_s)
    if response.success?
      object = BiomedicalConceptTemplate.find(uri.id, uri.namespace)
      object.errors.clear
    else
      object.errors.add(:base, "The Biomedical Concept was not created in the database.")
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
