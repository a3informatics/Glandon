class SdtmIg < Tabular
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  # Attributes
  attr_accessor :domain_refs
  
  # Constants
  C_SCHEMA_PREFIX = UriManagement::C_BD
  C_INSTANCE_PREFIX = UriManagement::C_MDR_IG
  C_CLASS_NAME = "SdtmIg"
  C_RDF_TYPE = "ImplementationGuide"
  C_CID_PREFIX = "IG"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  C_IDENTIFIER = "SDTM IG"

  # Class-wide variables
  @@cdiscNamespace = nil # CDISC Organization identifier
  
  def initialize(triples=nil, id=nil)
    self.domain_refs = Array.new
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
        job.importCdiscSdtmIg(params, files)
      else
        object.errors.add(:base, "The version (#{params[:version]}) has already been created.")
        job = nil
      end
    else
      job = nil
    end
    return { :object => object, :job => job }
  end

  def self.import_sparql(params, sparql, ig_domains, map)
    # Init data
    object = self.new 
    object.errors.clear
    compliance = Hash.new
    # Get the Json structure
    data = params[:data]
    operation = data[:operation]
    managed_item = data[:managed_item]
    ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    uri = IsoManaged.create_sparql(C_CID_PREFIX, data, C_RDF_TYPE, C_SCHEMA_NS, C_INSTANCE_NS, sparql, ra)
    id = uri.id
    namespace = uri.namespace
    # Build the compliance (core) triples
    ig_domains.each do |result|
      result[:instance][:managed_item][:children].each do |variable|
        core = variable[:variable_core]
        if !compliance.has_key?(core)
          ref_id = id + Uri::C_UID_SECTION_SEPARATOR + 'C' + Uri::C_UID_SECTION_SEPARATOR + core.upcase.gsub(/\s+/, "")
          compliance[core] = { :id => ref_id, :label => core }
          map[core] = UriV2.new({:namespace => namespace, :id => ref_id})
        end
      end
    end    
    compliance.each do |key, item|
      IsoConcept.import_sparql(namespace, item[:id], sparql, C_SCHEMA_PREFIX, "VariableCompliance", item[:label])
    end
    return { :uri => uri, :object => object }
  end

  def self.add_domain_sparql(uri, ref_uri, ordinal, sparql)
    object = self.new 
    object.errors.clear
    subject = {:uri => uri}
    ref_id = "#{uri.id}#{Uri::C_UID_SECTION_SEPARATOR}TR#{ordinal}" 
    ref_subject ={:namespace => uri.namespace, :id => ref_id}
    sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "includesTabulation"}, ref_subject)
    sparql.triple(ref_subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_BO, :id => "TReference"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "hasTabulation"}, {:uri => ref_uri})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "enabled"}, {:literal => "true", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "optional"}, {:literal => "false", :primitive_type => "boolean"})
    sparql.triple(ref_subject, {:prefix => UriManagement::C_BO, :id => "ordinal"}, {:literal => "#{ordinal}", :primitive_type => "positiveInteger"})
    return { :object => object }
  end

  def to_json
    json = super
    json[:domain_refs] = Array.new
    self.domain_refs.each do |ref|
      json[:domain_refs] << ref.to_json
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

  def self.children_from_triples(object, triples, id, bc=nil)
    object.domain_refs = OperationalReferenceV2.find_for_parent(triples, object.get_links(C_SCHEMA_PREFIX, "includesTabulation"))
  end      

end
