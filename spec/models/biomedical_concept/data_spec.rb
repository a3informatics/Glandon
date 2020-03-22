require 'rails_helper'
require 'biomedical_concept/property'

describe BiomedicalConcept do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/biomedical_concept/data"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..62)
    load_local_file_into_triple_store(sub_dir, "complex_datatypes.ttl")
    @cdt_set = {}
    @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
  end

  def create_item(params, ordinal, template=true)
    item = BiomedicalConcept::Item.new(label: params[:label], mandatory: params[:mandatory], enabled: params[:enabled], ordinal: ordinal)
    params[:complex_datatype].each do |datatype|
      cdt = find_complex_datatype(datatype[:short_name])
      cdt = create_complex_datatype(datatype, cdt) if !template
      item.has_complex_datatype_push(cdt)
    end
    item
  end

  def create_property(params)
    property = BiomedicalConcept::Property.new(label: params[:label], format: params[:format], question_text: params[:question_text], prompt_text: params[:prompt_text])
    params[:has_coded_value].each do |term|
      items = @ct.find_by_identifiers([term[:cl], term[:cli]])
      property.has_coded_value_push(items[term[:cli]]) 
    end
    property
  end

  def create_complex_datatype(params, cdt_template)
    cdt = BiomedicalConcept::ComplexDatatype.new
    cdt.based_on = cdt_template
    params[:has_property].each do |property|
      cdt.has_property_push(create_property(property))
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
        object.has_item_push(create_item(x, index+1))
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
    results = []
    instances = read_yaml_file(sub_dir, "instances.yaml")
    instances.each do |instance|
      object = BiomedicalConceptInstance.new(label: instance[:label])
      object.identified_by = create_item(instance[:identified_by], 1)
      instance[:has_items].each_with_index do |item, index| 
        next if !item[:enabled]
        object.has_item_push(create_item(item, index+2, false))
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