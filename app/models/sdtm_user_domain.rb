class SdtmUserDomain < Tabular::Tabulation
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :prefix, :structure, :notes, :bc_refs, :model_ref, :ig_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_D
  C_CLASS_NAME = "SdtmUserDomain"
  C_CID_PREFIX = "D"
  C_RDF_TYPE = "UserDomain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  C_MD_REF_PREFIX = "MD"
  C_IGD_REF_PREFIX = "IGD"
  C_BC_REF_PREFIX = "BC"
  C_BCP_REF_PREFIX = "BCP"
  
  def initialize(triples=nil, id=nil)
    self.prefix = SdtmUtility::C_PREFIX
    self.structure = ""
    self.bc_refs = Array.new
    self.model_ref = OperationalReferenceV2.new
    self.ig_ref = OperationalReferenceV2.new
    if triples.nil?
      super
      # Set the type. Overwrite default.
      self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    return object
  end

  def self.history(params)
    results = super(C_RDF_TYPE, C_SCHEMA_NS, params)
    return results
  end

  def self.unique
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.upgrade(ig_domain)
    object = self.new
    object.label = ig_domain.label
    object.prefix = ig_domain.prefix
    object.ig_ref = OperationalReferenceV2.new
    object.ig_ref.subject_ref = ig_domain.uri
    object.model_ref = ig_domain.model_ref
    ig_domain.children.each do |child|
      variable = SdtmUserDomain::Variable.new
      class_variable = SdtmModelDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
      model_variable = SdtmModel::Variable.find(class_variable.variable_ref.subject_ref.id, class_variable.variable_ref.subject_ref.namespace)
      variable.name = model_variable.name
      variable.ordinal = child.ordinal
      variable.label = child.label
      variable.datatype = model_variable.datatype
      variable.compliance = child.compliance
      variable.classification = model_variable.classification 
      variable.sub_classification = model_variable.sub_classification
      op_ref = OperationalReferenceV2.new
      op_ref.subject_ref = child.uri
      variable.variable_ref = op_ref
      object.children << variable
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
      object = SdtmUserDomain.from_json(data)
      object.scopedIdentifier.identifier = "SDTM USER " + managed_item[:prefix]
      #ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{object.to_json}")
      # Can we create?
      if object.create_permitted?(ra)
        # Amend the prefix
        object.children.each do |item|
          item.name = SdtmUtility.overwrite_prefix(item.name, object.prefix) if SdtmUtility.prefixed?(item.name)
        end
        # Build sparql
        sparql = object.to_sparql(ra)
        # Send to database
        ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
        response = CRUD.update(sparql.to_s)
        if !response.success?
          object.errors.add(:base, "The Domain was not created in the database.")
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
    domain = SdtmUserDomain.find(managed_item[:id], managed_item[:namespace])
    ra = IsoRegistrationAuthority.owner
    object = SdtmUserDomain.from_json(data)
    sparql = object.to_sparql(ra)
    domain.destroy # Destroys the old entry before the creation of the new item
    ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
    response = CRUD.update(sparql.to_s)
    if response.success?
      object.errors.clear
    else
      object.errors.add(:base, "The Domain was not created in the database.")
    end
    return object
  end

  def destroy
    super(self.namespace)
  end

  def to_json
    json = super
    json[:prefix] = self.prefix
    json[:structure] = self.structure
    json[:notes] = self.notes
    json[:model_ref] = self.model_ref.to_json
    json[:ig_ref] = self.ig_ref.to_json
    json[:children] = Array.new
    json[:bc_refs] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    self.bc_refs.each do |child|
      json[:bc_refs] << child.to_json
    end
    return json
  end

  def self.from_json(json)
    object = super(json)
    managed_item = json[:managed_item]
    object.prefix = managed_item[:prefix]
    object.structure = managed_item[:structure]
    object.notes = managed_item[:notes]
    object.model_ref = OperationalReferenceV2.from_json(managed_item[:model_ref])
    object.ig_ref = OperationalReferenceV2.from_json(managed_item[:ig_ref])
    if managed_item.has_key?(:children)
      managed_item[:children].each do |key, child|
        object.children << SdtmUserDomain::Variable.from_json(child)
      end
    end
    if managed_item.has_key?(:bc_refs)
      managed_item[:bc_refs].each do |key, child|
        object.bc_refs << OperationalReferenceV2.from_json(child)
      end
    end
    return object
  end

  def to_sparql(ra)
    sparql = SparqlUpdate.new
    uri = super(sparql, ra, C_CID_PREFIX, C_INSTANCE_NS, C_SCHEMA_PREFIX)
    # Set the properties
    sparql.triple_primitive_type("", uri.id, C_SCHEMA_PREFIX, "prefix", "#{self.prefix}", "string")
    sparql.triple_primitive_type("", uri.id, C_SCHEMA_PREFIX, "structure", "#{self.structure}", "string")
    sparql.triple_primitive_type("", uri.id, C_SCHEMA_PREFIX, "notes", "#{self.notes}", "string")
    # References
    ig_id = self.ig_ref.to_sparql(uri.id, "basedOnDomain", C_IGD_REF_PREFIX, 1, sparql)
    model_id = self.model_ref.to_sparql(uri.id, "basedOnDomain", C_MD_REF_PREFIX, 1, sparql)
    sparql.triple("", self.id, UriManagement::C_BD, "basedOnDomain", "", "#{ig_id}")
    sparql.triple("", self.id, UriManagement::C_BD, "basedOnDomain", "", "#{model_id}")
    # Now deal with the children
    ordinal = 1
    self.children.each do |item|
      ref_id = item.to_sparql(uri.id, sparql)
      sparql.triple("", uri.id, C_SCHEMA_PREFIX, "includesColumn", "", ref_id)
      ordinal += 1
    end
    ordinal = 1
    self.bc_refs.each do |item|
      ref_id = item.to_sparql(uri.id, "hasBiomedicalConcept", C_BCP_REF_PREFIX, ordinal, sparql)
      sparql.triple("", uri.id, C_SCHEMA_PREFIX, "hasBiomedicalConcept", "", ref_id)
      ordinal += 1
    end
    ConsoleLogger::log(C_CLASS_NAME,"to_sparql","SPARQL=#{sparql}")
    return sparql
  end

  def add(params)
    update = false
    bcs = params[:bcs]
    sparql = SparqlUpdate.new
    bc_ordinal = self.bc_refs.length + 1
    bcs.each do |key|
      #ConsoleLogger::log(C_CLASS_NAME,"add","Add BC=" + key.to_s )
      parts = key.split("|")
      bc_id = parts[0]
      bc_namespace = parts[1]
      if !bc_referenced?(bc_namespace, bc_id)
        update = true
        bc = BiomedicalConcept.find(bc_id, bc_namespace)
        bc.flatten.each do |property|
          if property.enabled
            bridg = property.bridgPath
            sdtm = BridgSdtm::get(bridg)
            ConsoleLogger::log(C_CLASS_NAME,"add","bridg=" + bridg.to_s + " , sdtm=" + sdtm.to_s )
            if sdtm != ""
              variable = find_variable_by_name(self.prefix, sdtm)
              if variable != nil
                ConsoleLogger::log(C_CLASS_NAME,"add","variable=" + variable.name )
                p_ref = OperationalReferenceV2.new
                p_ref.subject_ref = UriV2.new({:id => property.id, :namespace => property.namespace})
                ref_id = p_ref.to_sparql(variable.id, "hasProperty", C_BCP_REF_PREFIX, bc_ordinal, sparql)
                sparql.triple("", variable.id, UriManagement::C_BD, "hasProperty", "", "#{ref_id}")
              end
            end
          end
        end
        # Add in the domain reference
        p_ref = OperationalReferenceV2.new
        p_ref.subject_ref = UriV2.new({:id => bc.id, :namespace => bc.namespace})
        ref_id = p_ref.to_sparql(self.id, "hasBiomedicalConcept", C_BC_REF_PREFIX, bc_ordinal, sparql)
        sparql.triple("", self.id, UriManagement::C_BD, "hasBiomedicalConcept", "", "#{ref_id}")
        # Increment ordinal
        bc_ordinal += 1
      end
    end
    # Create the query if anything to do
    if update
      sparql.add_default_namespace(self.namespace)
      ConsoleLogger::log(C_CLASS_NAME,"add","sparql=#{sparql}" )    
      response = CRUD.update(sparql.to_s)
      if !response.success?
        ConsoleLogger::log(C_CLASS_NAME,"add","Update failed!.")
      end
    end
  end

  def remove(params)
    bcs = params[:bcs]
    deleteSparql = ""    
    bcs.each do |key|
      ConsoleLogger::log(C_CLASS_NAME,"remove","Add BC=#{key}")
      parts = key.split("|")
      bc_id = parts[0]
      bc_namespace = parts[1]
      uri = UriV2.new({:namespace => bc_namespace, :id => bc_id})
      # Create the query
      update = UriManagement.buildNs(self.namespace, ["bd", "bo", "cbc"]) +
        "DELETE \n" +
        "{ \n" +
        "  :" + self.id + " bd:hasBiomedicalConcept ?s . \n" +
        "  ?col bd:hasProperty ?s . \n" + 
        "  ?s ?p ?o . \n" +
        "} \n" + 
        "WHERE" +
        "{\n" + 
        "  {\n" + 
        "    :" + self.id + " bd:hasBiomedicalConcept ?s . \n" + 
        "    ?s bo:hasBiomedicalConcept #{uri.to_ref} . \n" + 
        "    ?s ?p ?o . \n" +
        "  } UNION { \n" +
        "    :" + self.id + " bd:includesColumn ?col . \n" + 
        "    ?col bd:hasProperty ?s . \n" + 
        "    ?s bo:hasProperty ?property . \n" +  
        "    ?property (cbc:isPropertyOf | cbc:isDatatypeOf | cbc:isItemOf)%2B #{uri.to_ref} . \n" +
        "    ?s ?p ?o . \n" +
        "  }\n" +
        "}"
      ConsoleLogger::log(C_CLASS_NAME,"remove","SPARQL=#{update}")
      # Send the request, wait the resonse
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger::log(C_CLASS_NAME,"remove","Update failed!.")
      end
    end

  end

  def report(options, user)
    doc_history = Array.new
    if options[:full]
      history = IsoManaged::history(C_RDF_TYPE, C_SCHEMA_NS, {:identifier => self.identifier, :scope_id => self.owner_id})
      history.each do |item|
        if self.same_version?(item.version) || self.later_version?(item.version)
          doc_history << item.to_json
        end
      end
    end
    domain = self.to_json
    pdf = Reports::DomainReport.create(domain, options, doc_history, user)
  end

  def self.bc_impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bd", "bo", "mms"])  +
      "SELECT DISTINCT ?domain WHERE \n" +
      "{ \n " +
      "  ?domain rdf:type bd:Domain . \n " +
      "  ?domain bd:hasBiomedicalConcept " + ModelUtility.buildUri(namespace, id) + " . \n " +
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      domain = ModelUtility.getValue('domain', true, node)
      if domain != ""
        id = ModelUtility.extractCid(domain)
        namespace = ModelUtility.extractNs(domain)
        results[id] = find(id, namespace, false)
      end
    end
    return results
  end

private

  def self.params_valid?(params, object)
    result1 = FieldValidation::valid_domain_prefix?(:prefix, params[:prefix], object)
    return result1 # && result2 && result3 && result4
  end

  def find_variable_by_name(prefix, name)
    local_name = SdtmUtility.overwrite_prefix(name, prefix) if SdtmUtility.prefixed?(name)
    self.children.each do |variable|
      if variable.name == local_name
        return variable
      end
    end
    return nil
  end

  def bc_referenced?(namespace, id)
    uri = UriV2.new({:namespace => namespace, :id => id})
    self.bc_refs.each do |bc_ref|
      ConsoleLogger::log(C_CLASS_NAME,"bc_referenced?","BC Ref=#{bc_ref.subject_ref}, New=#{uri}")
      if "#{bc_ref.subject_ref}" == "#{uri}"
        ConsoleLogger::log(C_CLASS_NAME,"bc_referenced?","Return true")
        return true
      end
    end
    return false
  end

  def self.children_from_triples(object, triples, id)
    object.children = SdtmUserDomain::Variable.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesColumn"))
    object.bc_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "hasBiomedicalConcept"))
    refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "basedOnDomain"))
    if refs.length > 0
      refs.each do |ref|
        item = IsoManaged.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
        if item.rdf_type == "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => SdtmIgDomain::C_RDF_TYPE})}"
          object.ig_ref = ref
        else
          object.model_ref = ref
        end
      end
    end
  end

end
