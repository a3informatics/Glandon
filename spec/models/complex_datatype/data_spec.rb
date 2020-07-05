require 'rails_helper'

describe ComplexDatatype do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/complex_datatype/data"
  end

  before :each do
    load_files(schema_files, [])
  end

  it "create datatypes" do
    results = []
    cdts = read_yaml_file(sub_dir, "complex_datatypes.yaml")
    cdts.each do |cdt|
      item = ComplexDatatype.new(label: cdt[:label], short_name: cdt[:short_name])
      item.uri = item.create_uri(item.class.base_uri)
      cdt[:properties].each do |property|
        prop = ComplexDatatype::PropertyX.new(label: property[:label], simple_datatype: property[:simple_datatype])
        prop.uri = prop.create_uri(item.uri)
        item.has_property.push(prop)
      end
      results << item
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "complex_datatypes.ttl")
	end

end