require 'rails_helper'
require 'biomedical_concept/property'

describe BiomedicalConcept do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/biomedical_concept/data"
  end

  before :each do
    data_files = 
    [
      "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",
      "canonical_references.ttl", "complex_datatypes.ttl"
    ]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..62)
    @cdt_set = {}
    @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
  end

  def create_item(params, ordinal, bc_template=nil)
    t_item = bc_template.has_items.find{|x| x[:label] == params[:label]} if !bc_template.nil?
    params[:ordinal] = ordinal
    item = BiomedicalConcept::Item.new(params)
    params[:complex_datatype].each do |datatype|
      cdt = find_complex_datatype(datatype[:short_name])
      cdt = create_complex_datatype(datatype, cdt, t_item) 
      item.has_complex_datatype_push(cdt)
    end
    item
  end

  def create_property(params, t_cdt)
    params = params.merge(format: "", question_test: "", prompt_text: "") if t_cdt.nil?
    property = BiomedicalConcept::Property.new(params)
    ref = CanonicalReference.where(label: params[:is_a])
    property.is_a = ref.first.uri
    return property if t_cdt.nil?
    t_property = t_cdt.has_property.find{|x| x[:label] == params[:label]} 
    params[:has_coded_value].each_with_index do |term, index|
      items = @ct.find_by_identifiers([term[:cl], term[:cli]])
      op_ref = OperationalReferenceV3::TucReference.new(context: @ct.uri, reference: items[term[:cli]], optional: true)
      property.has_coded_value_push(op_ref) 
    end
    property
  end

  def create_complex_datatype(params, cdt_template, t_item)
    cdt = BiomedicalConcept::ComplexDatatype.new(label: cdt_template.short_name)
    cdt.based_on = cdt_template
    t_cdt = t_item.has_complex_datatype.find{|x| x[:label] == cdt_template.short_name} if !t_item.nil?
    params[:has_property].each do |property|
      cdt.has_property_push(create_property(property, t_cdt))
    end
    cdt
  end

  def find_complex_datatype(short_name)
    return @cdt_set[short_name] if @cdt_set.key?(short_name)
    cdt = ComplexDatatype.where(short_name: short_name)
    cdt = ComplexDatatype.find_children(cdt.first.uri)
    @cdt_set[short_name] = cdt
    cdt
  end

  it "create templates" do
    results = []
    templates = read_yaml_file(sub_dir, "templates.yaml")
    templates.each do |template|
      object = BiomedicalConceptTemplate.new(label: template[:label])
      object.identified_by = create_item(template[:identified_by], 1)
      template[:has_items].each_with_index do |x, index| 
        object.has_item_push(create_item(x, index+2))
      end
      object.set_initial(template[:identifier])
      results << object
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "biomedical_concept_templates.ttl")
	end

  it "create instances" do
    load_local_file_into_triple_store(sub_dir, "biomedical_concept_templates.ttl")
    results = []
    instances = read_yaml_file(sub_dir, "instances.yaml")
    instances.each do |instance|
      template = BiomedicalConceptTemplate.find(Uri.new(uri: instance[:based_on]))
      object = BiomedicalConceptInstance.new(label: instance[:label])
      object.based_on = template.uri
      object.identified_by = create_item(instance[:identified_by], 1, template)
      instance[:has_items].each_with_index do |item, index| 
        next if !item[:enabled]
        object.has_item_push(create_item(item, index+2, template))
      end
      object.set_initial(instance[:identifier])
      results << object
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "biomedical_concept_instances.ttl")
  end

end