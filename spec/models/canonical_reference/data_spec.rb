require 'rails_helper'

describe CanonicalReference do

	include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/canonical_reference/data"
  end

  describe "base reference" do

    before :all do
      data_files = []
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "create references" do
      results = []
      refs = read_yaml_file(sub_dir, "canonical_references.yaml")
      refs.each do |ref|
        item = CanonicalReference.new(label: ref[:label], sdtm: ref[:sdtm], bridg: ref[:bridg], definition: "Not currently defined.")
        item.uri = item.create_uri(item.class.base_uri)
        results << item
      end
      sparql = Sparql::Update.new
      sparql.default_namespace(results.first.uri.namespace)
      results.each{|x| x.to_sparql(sparql, true)}
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "canonical_references.ttl")
  	end

  end

  # No longer needed, kept just in case
  # describe "migration one" do

  #   before :all do
  #     data_files = []
  #     load_files(schema_files, data_files)
  #     load_data_file_into_triple_store("canonical_references.ttl")
  #   end

  #   after :all do
  #     delete_all_public_test_files
  #   end

  #   it "create migration 1, add SDTM references" do
  #     results = []
  #     refs = read_yaml_file(sub_dir, "canonical_references.yaml")
  #     item = CanonicalReference.where(bridg: refs.first[:bridg])
  #     sparql = Sparql::Update.new
  #     sparql.default_namespace(item.first.uri.namespace)
  #     refs.each do |ref|
  #       item = CanonicalReference.where(bridg: ref[:bridg])
  #       sparql.add({uri: item.first.uri}, {prefix: :fr, fragment: "sdtm"}, {literal: ref[:sdtm], primitive_type: XSDDatatype.new("string")})
  #     end
  #     full_path = sparql.to_file
  #   #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "canonical_references_migration_1.ttl")
  #   end

  # end

end
