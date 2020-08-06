class SdtmModel < ManagedCollection

  configure rdf_type: "http://www.assero.co.uk/BusinessDomain#Model",
            uri_suffix: "M"
  
  object_property :includesVariable, cardinality: :many, model_class: "SdtmModel::Variable"

  
  # Attributes
  # attr_accessor :children, :class_refs, :datatypes, :classifications
  
  # # Constants
  # C_SCHEMA_PREFIX = UriManagement::C_BD
  # C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  # C_CLASS_NAME = "SdtmModel"
  # C_RDF_TYPE = "Model"
  # C_CID_PREFIX = "M"
  # C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  # C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  # C_IDENTIFIER = "SDTM MODEL"
  # C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Class-wide variables
  # @@cdiscNamespace = nil # CDISC Organization identifier
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  # def initialize(triples=nil, id=nil)
  # 	@class_map = nil
  #   self.children = []
  #   self.class_refs = []
  #   self.datatypes = {}
  #   self.classifications = {}
  #   if triples.nil?
  #     super
  #     self.rdf_type = "#{UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})}"
  #   else
  #     super(triples, id)
  #   end
  # end

  # Find a given models.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmModelDomain] the domain object.
  # def self.find(id, ns, children=true)
  #   uri = UriV3.new(fragment: id, namespace: ns)
  #   super(uri.to_id)
  #   #object = super(id, ns)
  #   #if children
  #   #  children_from_triples(object, object.triples, id)
  #   #end
  #   #object.triples = ""
  #   #return object
  # end

  # Find all the models
  #
  # @return [Array] array of objects found
  #def self.all()
  #  results = IsoManaged.all_by_type(C_RDF_TYPE, C_SCHEMA_NS)
  #  return results
  #end

  # Find all the released models
  #
  # @return [Array] An array of objects
  #def self.list
  #  results = super(C_RDF_TYPE, C_SCHEMA_NS)
  #  return results
  #end

  # Find the Model history
  #
  # @return [Array] An array of SdtmModel objects.
  # def self.history
  #   @@cdiscNamespace ||= IsoNamespace.find_by_short_name("CDISC")
  #   return super({:identifier => C_IDENTIFIER, :scope => @@cdiscNamespace})
  # end

  # Create a new version. This is an import and runs in the background.
  #
  # @param [Hash] params the parameters
  # @option params [String] :date The release date of the version being created
  # @option params [String] :version The version being created
  # @option params [String] :version_label The label for the version being created
  # @option params [String] :files Array of files being used 
  # @return [Hash] A hash containing the object with any errors and the background job reference.
  # def self.create(params)
  #   job = nil
  #   object = self.new
  #   if import_params_valid?(params, object)
  #     params[:files].reject!(&:blank?)
		# 	job = Background.create
  # 	 	job.import_cdisc_sdtm_model(params)
  #   end
  #   return { :object => object, :job => job }
  # end

  # Build the object from the operational hash and gemnerate the SPARQL.
	#
  # @param [Hash] params the operational hash
  # @param [SparqlUpdateV2] sparql the SPARQL object to add triples to.
  # @return [SdtmModel] The created object. Valid if no errors set.
  # def self.build(params, sparql)
  #   cdisc_ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
  #   params[:managed_item][:scoped_identifier][:namespace] = cdisc_ra.ra_namespace.to_h
  #   params[:managed_item][:registration_state][:registration_authority] = cdisc_ra.to_json
  #   object = SdtmModel.from_json(params[:managed_item])
  #   build_datatypes(object.datatypes, params[:managed_item])
  #   build_classifications(object.classifications, params[:managed_item])
  #   update_variables(object.children, object.datatypes, object.classifications)
  #   object.from_operation(params[:operation], C_CID_PREFIX, C_INSTANCE_NS, cdisc_ra)
  #   object.lastChangeDate = object.creationDate # Make sure we don't set current time.
  #  	if object.valid? && object.create_permitted?
		# 	object.to_sparql_v2(sparql, false)
  #   end
  #   return object
  # end

  # To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @param [Boolean] refs output the domain references if true, defaults to true
  # @return [UriV2] The URI
  # def to_sparql_v2(sparql, refs=true)
  #   uri = super(sparql, C_SCHEMA_PREFIX)
  #   subject = {:uri => uri}
  #   self.datatypes.each { |k, dt| dt.to_sparql_v2(uri, sparql) }
  #   self.classifications.each { |k, c| c.to_sparql_v2(uri, sparql) if c.parent } # Note the if statement. Important only process the parents!
  #   self.children.each do |child|
  #   	ref_uri = child.to_sparql_v2(uri, sparql)
  #   	sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesVariable"}, {:uri => ref_uri})
  #   end
  #   domain_refs_to_sparql(sparql) if refs
  #   return self.uri
  # end

	# Refs To SPARQL
  #
  # @param [SparqlUpdateV2] sparql the SPARQL object
  # @return [UriV2] The subject URI
  # def domain_refs_to_sparql(sparql)
  #   self.class_refs.each do |ref|
  #   	ref_uri = ref.to_sparql_v2(self.uri, "includesTabulation", 'TR', ref.ordinal, sparql)
  #   	sparql.triple({:uri => self.uri}, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, {:uri => ref_uri})
  #   end
  #   return self.uri
  # end

  # From JSON
  #
  # @param [Hash] json the hash of values for the object 
  # @return [SdtmModel] the object created
  # def self.from_json(json)
  # 	variable_map = {}
  #   object = super(json)
  #   json[:children].each do |child|
  #   	if !json[:children].blank? 
  #   		object.children << SdtmModel::Variable.from_json(child) if !variable_map.has_key?(child[:name])
  #   		variable_map[child[:name]] = true
  #   	end
  #   end
  #   json[:class_refs].each { |ref| object.class_refs << OperationalReferenceV2.from_json(ref) } if !json[:class_refs].blank?
  #   return object
  # end

  # # To JSON
  # #
  # # @return [Hash] the object hash 
  # def to_json
  #   json = super
  #   json[:children] = []
  #   json[:class_refs] = []
  #   self.children.sort_by! {|u| u.ordinal}
  #   self.class_refs.sort_by! {|u| u.ordinal}
  #   self.children.each { |c| json[:children] << c.to_json }
  #   self.class_refs.each { |ref| json[:class_refs] << ref.to_json }
  #   return json
  # end

  # Add Domain
  #
  # @param [SdtmIgDomain] domain the domain object
  # @return [void] no return
  # def add_domain(domain)
  # 	ref = OperationalReferenceV2.new
  # 	ref.subject_ref = domain.uri
  # 	self.class_refs << ref
  # 	ref.ordinal = self.class_refs.count
  # end

  # Classes. Get list of model classes and associated variables
  #
  # @return [Hash] hash of classes and the variables
 	# def classes
 	# 	return @class_map if !@class_map.nil?
  #   result = {}
  #   v_map = {}
  #   self.children.each { |v| v_map["#{v.uri}"] = v.name}
  #   self.class_refs.each do |model_ref|
  #     model_class = SdtmModelDomain.find(model_ref.subject_ref.id, model_ref.subject_ref.namespace)
  #     result[model_class.label] = { :class => model_class.label, :uri => model_class.uri, :children => {} }
  #     model_class.children.each { |v| result[model_class.label][:children][v_map["#{v.variable_ref.subject_ref}"]] = v.uri }
  #   end
  #   @class_map = result
  #   return result
  # end

  # def children_from_triples
  #   self.children =  SdtmModel::Variable.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "includesVariable"))
  #   self.class_refs = OperationalReferenceV2.find_for_parent(self.triples, self.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  # end      

private

  # Update Variables. Update the variables with common references
 #  def self.update_variables(children, datatype_set, classification_set)
 # 		children.each do |child|
 # 			child.update_datatype(datatype_set)
 # 			child.update_classification(classification_set)
 # 		end
 # 	end

 #  # Build Classifications. Create the common classifcations.
 #  def self.build_classifications(classification_set, json)
 #  	return if json[:children].blank?
 #    build_classification(classification_set, SdtmModel::Variable::C_ROLE_NONE, SdtmModel::Variable::C_ROLE_Q_NA)
 #    json[:children].each { |c| build_classification(classification_set, c[:classification][:label], c[:sub_classification][:label]) }
 #  end
 
 #  # Build Datatypes. Create the common datatypes.
 #  def self.build_datatypes(datatype_set, json)
 #  	return if json[:children].blank?
 #    json[:children].each do |item|
 #    	label = item[:datatype][:label]
 #    	if !datatype_set.has_key?(label)
 #    		object = SdtmModelDatatype.new
 #    		object.label = label
 #      	datatype_set[label] = object
 #      end
 #    end
 #  end

 #  # Build classification
	# def self.build_classification(classification_set, classification, sub_classification)
	# 	if !classification_set.has_key?(classification)
	# 		object = SdtmModelClassification.new
	# 		object.label = classification
	# 		object.set_parent
	# 		classification_set[classification] = object
	# 	end
	# 	if !classification_set.has_key?(sub_classification) && sub_classification != SdtmModel::Variable::C_ROLE_Q_NA
	# 		parent = classification_set[classification] 
	# 		object = SdtmModelClassification.new
	# 		object.label = sub_classification
	# 		parent.add_child(object)
	# 		classification_set[sub_classification] = object
	# 	end        
	# end

 #  def self.import_params_valid?(params, object)
 #    result1 = FieldValidation::valid_version?(:version, params[:version], object)
 #    result2 = FieldValidation::valid_date?(:date, params[:date], object)
 #    result3 = FieldValidation::valid_files?(:files, params[:files], object)
 #    result4 = FieldValidation::valid_label?(:version_label, params[:version_label], object)
 #    return result1 && result2 && result3 && result4
 #  end

  #def self.create_params_valid?(params, object)
  #  result1 = FieldValidation::valid_identifier?(:version, params[:identifier], object)
  #  result2 = FieldValidation::valid_label?(:label, params[:label], object)
  #  return result1 && result2 
  #end

end
