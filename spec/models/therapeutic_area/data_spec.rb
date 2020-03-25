require 'rails_helper'

describe "Therapeutic Area Data" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/therapeutic_area/data"
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
    setup
  end

  after :each do
    delete_all_public_test_files
  end

  describe "Basic Definitons" do

    it "TAs" do
      item_1 = TherapeuticArea.new(label:"Influenza")
      item_1.uri = item_1.create_url()
    end

  end

end