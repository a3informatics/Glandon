require 'rails_helper'

describe "Visit" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/visit"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      item = Visit.create(label: "VVV")
      actual = Visit.find(item.uri)
      expect(actual.label).to eq("VVV")
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "simple update" do
      actual = Visit.create(identifier: "VVV")
      actual = Visit.find(actual.uri)
      actual.label = "New label"
      actual.save
      actual = Visit.find(actual.uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      actual.label = "Really new label"
      actual.save
      expect(actual.label).to eq("Really new label")
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end