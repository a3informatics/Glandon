require 'rails_helper'

describe "Epoch" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/epoch"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      item = Epoch.create(label: "XXX", ordinal: 1)
      actual = Epoch.find(item.uri)
      expect(actual.label).to eq("XXX")
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end