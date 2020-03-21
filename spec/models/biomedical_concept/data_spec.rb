require 'rails_helper'
require 'complex_datatype/property'

describe BiomedicalConceptTemplate do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/biomedical_concept/data"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_local_file_into_triple_store(sub_dir, "complex_datatypes.ttl")
  end

  def create_item(params, ordinal)
    item = BiomedicalConcept::Item.new(label: params[:label], mandatory: params[:mandatory], enabled: params[:enabled], ordinal: ordinal)
    params[:complex_datatype].each do |datatype|
      cdt = ComplexDatatype.where(short_name: datatype[:short_name])
      cdt.each {|x| item.has_complex_datatype_push(x)}
    end
    item
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

end