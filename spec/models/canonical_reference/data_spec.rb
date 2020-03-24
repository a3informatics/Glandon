require 'rails_helper'

describe CanonicalReference do
	
	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/canonical_reference/data"
  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
  end

  it "create references" do
    results = []
    refs = read_yaml_file(sub_dir, "canonical_references.yaml")
    refs.each do |ref|
      item = CanonicalReference.new(label: ref[:label], bridg: ref[:bridg], definition: "Not set.")
      item.uri = item.create_uri(item.class.base_uri)
      results << item
    end
    sparql = Sparql::Update.new
    sparql.default_namespace(results.first.uri.namespace)
    results.each{|x| x.to_sparql(sparql, true)}
    full_path = sparql.to_file
  copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "canonical_references.ttl")
	end

end