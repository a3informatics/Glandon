class SdtmModel < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :children, :class_refs
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmModel"
  C_RDF_TYPE = "Model"
  C_CID_PREFIX = "M"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "SDTM MODEL"
  C_RDF_TYPE_URI = UriV2.new({:namespace => C_SCHEMA_NS, :id => C_RDF_TYPE})

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  # Initialize
  #
  # @params triples [Hash] the triples
  # @params id [String] the id to be initialized
  # @return [Null]
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    self.class_refs = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  # Find a given models.
  #
  # @param id [String] the id of the domain
  # @param namespace [String] the namespace of the domain
  # @param children [Boolean] find all child objects. Defaults to true.
  # @return [SdtmModelDomain] the domain object.
  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  # Find all the models
  #
  # @return [Array] array of objects found
  def self.all()
    results = IsoManaged.find_by_type(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  # Find all the released models
  #
  # @return [Array] An array of objects
  def self.list
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  # Find the Model history
  #
  # @return [array] An array of objects.
  def self.history()
    @@cdiscNamespace ||= IsoNamespace.findByShortName("CDISC")
    results = super(C_RDF_TYPE, C_SCHEMA_NS, { :identifier => C_IDENTIFIER, :scope_id => @@cdiscNamespace.id })
    return results
  end

  def get_class_map
    variable_map = Hash.new
    class_map = Hash.new
    self.children.each do |variable|
      uri = UriV2.new({:namespace => variable.namespace, :id => variable.id})
      variable_map["#{uri}"] = variable
    end
    self.class_refs.each do |model_ref|
      model_class = SdtmModelDomain.find(model_ref.subject_ref.id, model_ref.subject_ref.namespace)
      model_class_name = model_class.label
      uri = UriV2.new({:namespace => model_class.namespace, :id => model_class.id})
      class_map[model_class_name] = {:class => model_class.label, :uri => uri, :children => {}}
      model_class.children.each do |variable|
        class_variable = variable_map["#{variable.variable_ref.subject_ref}"]
        class_map[model_class_name][:children][class_variable.name] = variable
      end
    end
    return class_map
  end

  def self.import(params)
    object = self.new
    object.errors.clear
    if import_params_valid?(params, object)
      # Clean files
      files = params[:files]
      files.reject!(&:blank?)
      # Check to ensure version does not exist
      ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
      if !versionExists?(C_IDENTIFIER, params[:version], ra.namespace)
        job = Background.create
        job.importCdiscSdtmModel(params, files)
      else
        object.errors.add(:base, "The version (#{params[:version]}) has already been created.")
        job = nil
      end
    else
      job = nil
    end
    return { :object => object, :job => job }
  end

  def self.import_sparql(params, sparql)
    # Init data
    object = self.new 
    object.errors.clear
    classifications = Hash.new
    classification_classes = Hash.new
    datatypes = Hash.new
    map = Hash.new
    # Get the Json structure
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    uri = IsoManaged.create_sparql(C_CID_PREFIX, data, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql, ra)
    id = uri.id
    namespace = uri.namespace
    ConsoleLogger::log(C_CLASS_NAME,"import_sparql", "URI=#{uri}")
    # Build the data type and classification info. Fill in the blank classification first. Explicitly set the label to "".
    classification = SdtmModel::Variable::C_ROLE_NONE
    sub_classification = SdtmModel::Variable::C_ROLE_Q_NA
    classification_id = id + Uri::C_UID_SECTION_SEPARATOR + 'C' + Uri::C_UID_SECTION_SEPARATOR + classification.upcase.gsub(/\s+/, "")
    classification_classes[classification] = { :id => classification_id, :label => "", :children => Array.new }
    # Now from the data
    if !managed_item[:children].blank?
      managed_item[:children].each do |item|
        classification = item[:variable_classification]
        sub_classification = item[:variable_sub_classification]
        datatype = item[:variable_type]
        if !datatypes.has_key?(datatype)
          datatypes[datatype] = { :id => id + Uri::C_UID_SECTION_SEPARATOR + 'DT' + Uri::C_UID_SECTION_SEPARATOR + datatype.upcase.gsub(/\s+/, ""), :label => datatype }
        end
        key = "#{classification}.#{sub_classification}"
        classification_id = id + Uri::C_UID_SECTION_SEPARATOR + 'C' + Uri::C_UID_SECTION_SEPARATOR + classification.upcase.gsub(/\s+/, "")
        sub_classification_id = id + Uri::C_UID_SECTION_SEPARATOR + 'SC' + Uri::C_UID_SECTION_SEPARATOR + sub_classification.upcase.gsub(/\s+/, "")
        if !classifications.has_key?(key)
          if sub_classification == "Not Applicable"
            classifications[key] = { :id => classification_id, :label => classification }
            if !classification_classes.has_key?(classification)
              classification_classes[classification] = { :id => classification_id, :label => classification, :children => Array.new }
            end
          else
            classifications[key] = { :id => sub_classification_id, :label => sub_classification }
            if !classification_classes.has_key?(classification)
              classification_classes[classification] = { :id => classification_id, :label => classification, :children => Array.new  }
            end
            entry = classification_classes[classification]
            entry[:children] << { :id => sub_classification_id, :label => sub_classification, :children => Array.new  }
          end
        end
      end
    end
    # Build the variable triples
    if !managed_item[:children].blank?
      managed_item[:children].each do |item|
        ref_id = SdtmModel::Variable.import_sparql(namespace, id, sparql, item, datatypes, classifications)
        ref_uri = UriV2.new({:namespace=> namespace, :id => ref_id})
        sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "includesVariable"}, {:uri => ref_uri})
        map[item[:variable_name]] = ref_uri
      end
    end
    # Build the datatype and classifier references triples
    datatypes.each do |key, datatype|
      IsoConcept.import_sparql(namespace, datatype[:id], sparql, C_SCHEMA_PREFIX, "VariableType", datatype[:label])
    end
    classification_classes.each do |key, parent|
      IsoConcept.import_sparql(namespace, parent[:id], sparql, C_SCHEMA_PREFIX, "VariableClassification", parent[:label])
      parent[:children].each do |child|
        sparql.triple({:namespace => namespace, :id => parent[:id]}, {:prefix => C_SCHEMA_PREFIX, :id => "childClassification"}, {:prefix => "", :id => child[:id]})
        sparql.triple({:namespace => namespace, :id => child[:id]}, {:prefix => C_SCHEMA_PREFIX, :id => "parentClassification"}, {:prefix => "", :id => parent[:id]})
        IsoConcept.import_sparql(namespace, child[:id], sparql, C_SCHEMA_PREFIX, "VariableClassification", child[:label])  
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "classification_classes=" + classification_classes.to_json.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "classifications=" + classifications.to_json.to_s) 
    return { :uri => uri, :map => map, :object => object }
  end

  def self.add_class_sparql(uri, ref_uri, ordinal, sparql)
    object = self.new 
    object.errors.clear
    ref_id = "#{uri.id}#{Uri::C_UID_SECTION_SEPARATOR}TR#{ordinal}" 
    ref_subject ={:namespace => uri.namespace, :id => ref_id}
    sparql.triple({:uri => uri}, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, ref_subject)
    sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id => "TReference"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasTabulation"}, {:uri => ref_uri})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "#{ordinal}", :primitive_type => "positiveInteger"})
    return { :object => object }
  end

  # To JSON
  #
  # @return [Hash] the object hash 
  def to_json
    json = super
    json[:children] = Array.new
    json[:class_refs] = Array.new
    self.children.each do |child|
      json[:children] << child.to_json
    end
    self.class_refs.each do |ref|
      json[:class_refs] << ref.to_json
    end
    return json
  end

private

  def self.import_params_valid?(params, object)
    result1 = FieldValidation::valid_version?(:version, params[:version], object)
    result2 = FieldValidation::valid_date?(:date, params[:date], object)
    result3 = FieldValidation::valid_files?(:files, params[:files], object)
    result4 = FieldValidation::valid_label?(:version_label, params[:version_label], object)
    return result1 && result2 && result3 && result4
  end

  def self.create_params_valid?(params, object)
    result1 = FieldValidation::valid_identifier?(:version, params[:identifier], object)
    result2 = FieldValidation::valid_label?(:label, params[:label], object)
    return result1 && result2 
  end

  def self.children_from_triples(object, triples, id, bc=nil)
    object.children =  SdtmModel::Variable.find_for_parent(object.triples, object.get_links(C_SCHEMA_PREFIX, "includesVariable"))
    object.class_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
