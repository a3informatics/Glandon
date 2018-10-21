require 'xpt'

class SdtmUserDomain < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :children, :prefix, :structure, :notes, :bc_refs, :model_ref, :ig_ref

  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_UD
  C_CLASS_NAME = "SdtmUserDomain"
  C_CID_PREFIX = "D"
  C_RDF_TYPE = "UserDomain"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  C_MD_REF_PREFIX = "MD"
  C_IGD_REF_PREFIX = "IGD"
  C_BC_REF_PREFIX = "BCR"
  C_BCP_REF_PREFIX = "PR"
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.prefix = SdtmUtility::C_PREFIX
    self.structure = ""
    self.notes = ""
    self.bc_refs = Array.new
    self.children = Array.new
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

  # Find a given user domain.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmUserDomain] the domain object.
  def self.find(id, ns, children=true)
    uri = UriV3.new(fragment: id, namespace: ns)
    super(uri.to_id)
    #children_from_triples(object, object.triples, id) if children
    #object.triples = ""
    #return object
  end

  # Find all managed items based on their type.
  #
  # @return [Array] array of objects found
  #def self.all
  #  return IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  #end

  # Find list of managed items of a given type.
  #
  # @return [Array] Array of objects found
  def self.unique
    return super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  # Find all released item for all identifiers of a given type.
  #
  # @return [Array] An array of objects
  #def self.list
  #  return super(C_RDF_TYPE, C_SCHEMA_NS)
  #end

  # Find history for a given identifier
  #
  # @params [Hash] {:identifier, :scope_id}
  # @return [Array] an array of objects
  #def self.history(params)
  #  return super(C_RDF_TYPE, C_SCHEMA_NS, params)
  #end

  # Create a clone based on a specified IG domain
  #
  # @params [SdtmIgDomain] the template IG domain
  # @raise [CreateError] If object not created.
  # @return [SdtmuserDomain] the new user domain object
  def self.create_clone_ig(params, ig_domain)
    object = self.new
    object.ordinal = 1
    object.label = params[:label]
    object.prefix = params[:prefix]
    object.ig_ref = OperationalReferenceV2.new
    object.ig_ref.subject_ref = ig_domain.uri
    object.model_ref = ig_domain.model_ref
    ig_domain.children.each do |child|
      variable = SdtmUserDomain::Variable.new
      if !child.variable_ref.nil?
        class_variable = SdtmModelDomain::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
        model_variable = SdtmModel::Variable.find(class_variable.variable_ref.subject_ref.id, class_variable.variable_ref.subject_ref.namespace)
      else
        model_variable = SdtmModel::Variable.new
      end
      variable.name = model_variable.name
      variable.name = SdtmUtility.overwrite_prefix(variable.name, object.prefix) if SdtmUtility.prefixed?(variable.name)
      variable.ordinal = child.ordinal
      variable.label = child.label
      if child.ct?
        variable.format = ""
        variable.ct = child.ct
      else
        variable.format = child.format
        variable.ct = ""
      end
      variable.used = true
      variable.datatype = model_variable.datatype
      variable.compliance = child.compliance
      variable.classification = model_variable.classification 
      variable.sub_classification = model_variable.sub_classification
      op_ref = OperationalReferenceV2.new
      op_ref.subject_ref = child.uri
      variable.variable_ref = op_ref
      object.children << variable
    end
    operation = object.to_clone
    managed_item = operation[:managed_item]
    managed_item[:scoped_identifier][:identifier] = "#{params[:prefix]} Domain"
    managed_item[:type] = "#{C_RDF_TYPE_URI}"
    new_object = SdtmUserDomain.create(operation)
    return new_object
  end

  # Create an item from the standard operation hash
  #
  # @param params [Hash] The standard operation hash
  # @raise [CreateError] If object not created.
  # @return [Object] The BC created. Includes errors if failed.
  def self.create(params)
    ConsoleLogger.debug(C_CLASS_NAME, "create", "params=#{params}")
    operation = params[:operation]
    managed_item = params[:managed_item]
    object = SdtmUserDomain.from_json(managed_item)
    object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, IsoRegistrationAuthority.owner)
    if object.valid? then
      if object.create_permitted?
        sparql = object.to_sparql_v2
        response = CRUD.update(sparql.to_s)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME, "create", "Failed to create object.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      end
    end
    return object
  end

  # Update a domain
  #
  # @param params [Hash] The operational hash
  # @return [SdtmUserDomain] The domain object. Valid if no errors set.
  def self.update(params)
    operation = params[:operation]
    managed_item = params[:managed_item]
    existing_domain = SdtmUserDomain.find(managed_item[:id], managed_item[:namespace])
    object = SdtmUserDomain.from_json(managed_item)
    object.from_operation(operation, C_CID_PREFIX, C_INSTANCE_NS, IsoRegistrationAuthority.owner)
    if object.valid? then
      #if object.create_permitted?
        sparql = object.to_sparql_v2
        existing_domain.destroy # Destroys the old entry before the creation of the new item
        response = CRUD.update(sparql.to_s)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
          raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
        end
      #end
    end
    return object
  end

  # Destroy a domain
  #
  # @raise [DestroyError] if object not destroyed
  # @return [Null] no return
  def destroy
    super
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:prefix] = self.prefix
    json[:structure] = self.structure
    json[:notes] = self.notes
    json[:model_ref] = self.model_ref.to_json
    json[:ig_ref] = self.ig_ref.to_json
    json[:children] = []
    json[:bc_refs] = []
    self.children.sort_by! {|u| u.ordinal}
    self.bc_refs.sort_by! {|u| u.ordinal}
    self.children.each do |child|
      json[:children] << child.to_json
    end
    self.bc_refs.each do |child|
      json[:bc_refs] << child.to_json
    end
    return json
  end

  # From JSON
  #
  # @param json [Hash] the hash of values for the object 
  # @return [SdtmUserDomain] the object created
  def self.from_json(json)
    object = super(json)
    object.prefix = json[:prefix]
    object.structure = json[:structure]
    object.notes = json[:notes]
    object.model_ref = OperationalReferenceV2.from_json(json[:model_ref])
    object.ig_ref = OperationalReferenceV2.from_json(json[:ig_ref])
    if !json[:children].blank?
      json[:children].each do |child|
        object.children << SdtmUserDomain::Variable.from_json(child)
      end
    end
    if !json[:bc_refs].blank?
      json[:bc_refs].each do |child|
        object.bc_refs << OperationalReferenceV2.from_json(child)
      end
    end
    return object
  end

  # To XPT. Export domain as a SAS XPT file.
  #
  # @return [String] full path to the file created.
  def to_xpt
    metadata = []
    self.children.each do |child|
      if child.used then # Only select variables in use
        variable = 
        {
          name: child.name,
          label: child.label[0..39],
          type: child.datatype.label.downcase
        }
        if variable[:type] == "char" then
          variable[:length] = child.length > 0 ? child.length : 200
        else
          variable[:length] = 8
        end
        # More info possible to add
        # variable[:key_ordinal] = child.key_ordinal
        # variable[:non_standard] = child.non_standard # Needs to be handled. SUPP--?
        # variable[:ct] = child.ct
        # variable[:format] = child.format
        # variable[:used] = child.used
        # variable[:comment] = child.comment
        # variable[:notes] = child.notes
        # variable[:compliance] = child.compliance
        # variable[:classification] = child.classification 
        # variable[:sub_classification] = child.sub_classification 
        # variable[:variable_ref] = child.variable_ref
        metadata << variable
      end
    end
    xpt = Xpt.new(APP_CONFIG['export_files'], self.prefix)
    cres = xpt.create_meta(self.label, metadata, true)
    return Rails.root.join "#{xpt.directory}#{xpt.filename}"
  end

  # To SPARQL
  #
  # @return [SparqlUpdateV2] the SPARQL object created
  def to_sparql_v2
    sparql = SparqlUpdateV2.new
    uri = super(sparql, C_SCHEMA_PREFIX)
    subject = {:uri => uri}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "prefix"}, {:literal => "#{self.prefix}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "structure"}, {:literal => "#{self.structure}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "notes"}, {:literal => "#{self.notes}", :primitive_type => "string"})
    ig_uri = self.ig_ref.to_sparql_v2(uri, "basedOnDomain", C_IGD_REF_PREFIX, 1, sparql)
    model_uri = self.model_ref.to_sparql_v2(uri, "basedOnDomain", C_MD_REF_PREFIX, 1, sparql)
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "basedOnDomain"}, {uri: ig_uri})
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "basedOnDomain"}, {uri: model_uri})
    ordinal = 1
    self.children.each do |item|
      ref_uri = item.to_sparql_v2(uri, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesColumn"}, {uri: ref_uri})
      ordinal += 1
    end
    ordinal = 1
    self.bc_refs.each do |item|
      ref_uri = item.to_sparql_v2(uri, "hasBiomedicalConcept", C_BCP_REF_PREFIX, ordinal, sparql)
      sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasBiomedicalConcept"}, {uri: ref_uri})
      ordinal += 1
    end
    return sparql
  end

  # Add 1 or more BC associations to the domain
  #
  # @param params [Hash] a hash of parameters
  # @option params [String] :bcs Array of BCs
  # @return [Null] no return
  def add(params)
    update = false
    bcs = params[:bcs]
    sparql = SparqlUpdateV2.new
    bc_ordinal = next_bc_ordinal
    bcs.each do |bc_uri|
      bc_uri = UriV2.new({:uri => bc_uri})
      if !bc_referenced?(bc_uri)
        update = true
        bc = BiomedicalConcept.find(bc_uri.id, bc_uri.namespace)
        bc.get_properties[:children].each do |property|
          if property[:enabled]
            sdtm = BridgSdtm.get(property[:bridg_path])
            if !sdtm.empty?
              variable = find_variable_by_name(self.prefix, sdtm)
              if !variable.nil?
                p_ref = OperationalReferenceV2.new
                p_ref.subject_ref = UriV2.new({:id => property[:id], :namespace => property[:namespace]})
                ref_uri = p_ref.to_sparql_v2(variable.uri, "hasProperty", C_BCP_REF_PREFIX, bc_ordinal, sparql)
                sparql.triple({:uri => variable.uri}, {:prefix => UriManagement::C_BD, :id => "hasProperty"}, {:uri => ref_uri})
              end
            end
          end
        end
        p_ref = OperationalReferenceV2.new
        p_ref.subject_ref = UriV2.new({:id => bc_uri.id, :namespace => bc_uri.namespace})
        ref_uri = p_ref.to_sparql_v2(self.uri, "hasBiomedicalConcept", C_BC_REF_PREFIX, bc_ordinal, sparql)
        sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_BD, :id => "hasBiomedicalConcept"}, {:uri => ref_uri})
        bc_ordinal += 1
      end
    end
    if update
      sparql.default_namespace(self.namespace)
      response = CRUD.update(sparql.to_s)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "add", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
      end
    end
  end

  # Remove 1 or more BC associations from the domain
  #
  # @param params [Hash] a hash of parameters
  # @option params [String] :bcs Array of BCs
  # @return [Null] no return
  def remove(params)
    bcs = params[:bcs]
    bcs.each do |bc_uri|
      uri = UriV2.new({:uri => bc_uri})
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
        "    #{uri.to_ref} (cbc:hasProperty|cbc:hasDatatype|cbc:hasItem|cbc:hasComplexDatatype)%2B ?property . \n" +
        "    ?s ?p ?o . \n" +
        "  }\n" +
        "}"
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "add", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
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

=begin
  def self.bc_impact(params)
    id = params[:id]
    namespace = params[:namespace]
    results = Hash.new
    # Build the query. Note the full namespace reference, doesnt seem to work with a default namespace. Needs checking.
    query = UriManagement.buildPrefix("", ["bd", "bo"])  +
      "SELECT DISTINCT ?domain WHERE \n" +
      "{ \n " +
      "  ?domain rdf:type bd:UserDomain . \n " +
      "  ?domain bd:hasBiomedicalConcept ?ref . \n" +
      "  ?ref bo:hasBiomedicalConcept " + ModelUtility.buildUri(namespace, id) + " . \n " +
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
=end

  # Check Valid
  #
  # @return [Boolean] returns true if valid, false otherwise.
  def valid?
    result = super
    # Bit of a special but check the prefix first. If not valid there will be a lot of errors
    # so dont check the children
    result = result &&
      FieldValidation::valid_sdtm_domain_prefix?(:prefix, self.prefix, self) && 
      FieldValidation::valid_markdown?(:notes, self.notes, self) && 
      FieldValidation::valid_label?(:structure, self.structure, self)
    if result
      self.children.each do |child|
        if !child.valid?
          self.copy_errors(child, "Variable, ordinal=#{child.ordinal}, error:")
          result = false
        end
      end
    end
    return result
  end

  def children_from_triples
    self.children = SdtmUserDomain::Variable.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "includesColumn"))
    self.bc_refs = OperationalReferenceV2.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "hasBiomedicalConcept"))
    refs = OperationalReferenceV2.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "basedOnDomain"))
    if refs.length > 0
      refs.each do |ref|
        item = IsoManaged.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
        if item.rdf_type == "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => SdtmIgDomain::C_RDF_TYPE})}"
          self.ig_ref = ref
        else
          self.model_ref = ref
        end
      end
    end
  end

private

  def find_variable_by_name(prefix, name)
    local_name = SdtmUtility.overwrite_prefix(name, prefix) if SdtmUtility.prefixed?(name)
    self.children.each do |variable|
      return variable if variable.name == local_name
    end
    return nil
  end

  def bc_referenced?(uri)
    self.bc_refs.each do |bc_ref|
      return true if bc_ref.subject_ref.to_s == uri.to_s
    end
    return false
  end

  def next_bc_ordinal
    ordinal = 1
    self.bc_refs.each do |bc_ref|
      ordinal = bc_ref.ordinal if bc_ref.ordinal >= ordinal
    end
    return ordinal + 1
  end


end
