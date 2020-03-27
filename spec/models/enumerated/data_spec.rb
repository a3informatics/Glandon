require 'rails_helper'

describe "Enumerated Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/enumerated/data"
  end

  before :all do
    IsoHelpers.clear_cache
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
  end

  after :all do
    #
  end

  before :each do
    #
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Basic Definitons" do

    it "Enumerated labels" do
      item_1 = Enumerated.new(label: "Primary")
      item_1.uri = item_1.create_uri(Enumerated.base_uri)
      item_2 = Enumerated.new(label: "Secondary")
      item_2.uri = item_2.create_uri(Enumerated.base_uri)
      item_3 = Enumerated.new(label: "Not Defined")
      item_3.uri = item_3.create_uri(Enumerated.base_uri)
      sparql = Sparql::Update.new
      sparql.default_namespace(item_1.uri.namespace)
      item_1.to_sparql(sparql)
      item_2.to_sparql(sparql)
      item_3.to_sparql(sparql)
      full_path = sparql.to_file
    copy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "enumerated.ttl")
    end

  end

end