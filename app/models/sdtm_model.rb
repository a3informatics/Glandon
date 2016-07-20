class SdtmModel < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :class_refs
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_M
  C_CLASS_NAME = "SdtmModel"
  C_RDF_TYPE = "ClassModel"
  C_CID_PREFIX = "M"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "SDTM MODEL"

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  def initialize(triples=nil, id=nil)
    self.children = Array.new
    self.class_refs = Array.new
    if triples.nil?
      super
    else
      super(triples, id)
    end
  end

  def self.find(id, ns, children=true)
    object = super(id, ns)
    if children
      children_from_triples(object, object.triples, id)
    end
    object.triples = ""
    return object
  end

  def self.all()
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

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
    id = uri.getCid()
    namespace = uri.getNs()
    # Build the data type and classification info. Fill in the blank classification first. Explicitly set the label to "".
    classification = SdtmModel::Variable::C_ROLE_NONE
    sub_classification = SdtmModel::Variable::C_ROLE_Q_NA
    classification_id = id + Uri::C_UID_SECTION_SEPARATOR + 'C' + Uri::C_UID_SECTION_SEPARATOR + classification.upcase.gsub(/\s+/, "")
    classification_classes[classification] = { :id => classification_id, :label => "", :children => Array.new }
    # Now from the data
    if managed_item.has_key?(:children)
      managed_item[:children].each do |key, item|
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
    if managed_item.has_key?(:children)
      managed_item[:children].each do |key, item|
        ref_id = SdtmModel::Variable.import_sparql(id, sparql, item, datatypes, classifications)
        sparql.triple("", id, C_SCHEMA_PREFIX, "includesVariable", "", ref_id)
        map[item[:variable_name]] = ModelUtility.buildUri(namespace, ref_id)
      end
    end
    # Build the datatype and classifier references triples
    datatypes.each do |key, datatype|
      IsoConcept.import_sparql(datatype[:id], sparql, C_SCHEMA_PREFIX, "VariableType", datatype[:label])
    end
    classification_classes.each do |key, parent|
      IsoConcept.import_sparql(parent[:id], sparql, C_SCHEMA_PREFIX, "VariableClassification", parent[:label])
      parent[:children].each do |child|
        sparql.triple("", parent[:id], C_SCHEMA_PREFIX, "childClassification", "", child[:id])
        sparql.triple("", child[:id], C_SCHEMA_PREFIX, "parentClassification", "", parent[:id])
        IsoConcept.import_sparql(child[:id], sparql, C_SCHEMA_PREFIX, "VariableClassification", child[:label])  
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "classification_classes=" + classification_classes.to_json.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"to_sparql", "classifications=" + classifications.to_json.to_s) 
    return { :uri => uri, :map => map, :object => object }
  end

  def self.add_class_sparql(uri, ref_uri, ordinal, sparql)
    object = self.new 
    object.errors.clear
    id = uri.getCid
    ref_id = "#{uri.getCid}#{Uri::C_UID_SECTION_SEPARATOR}TR#{ordinal}" 
    sparql.triple("", id, C_SCHEMA_PREFIX, "includesTabulation", "", "#{ref_id}")
    sparql.triple("", ref_id, UriManagement::C_RDF, "type", UriManagement::C_BO, "TReference")
    sparql.triple_uri_full("", ref_id, UriManagement::C_BO, "hasTabulation", ref_uri.to_ref)
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "enabled", "true", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "optional", "false", "boolean")
    sparql.triple_primitive_type("", ref_id, UriManagement::C_BO, "ordinal", "#{ordinal}", "positiveInteger")
    return { :object => object }
  end

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
