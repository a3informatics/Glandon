require 'rails_helper'

describe "Study" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/study"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      actual = Study.create(identifier: "XXX")
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.implements).to eq(nil)
      actual = Study.find_minimum(actual.uri)
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.implements).to eq(nil)
      check_dates(actual, sub_dir, "create_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "simple update I" do
      actual = Study.create(identifier: "XXX")
      actual = Study.find_minimum(actual.uri)
      actual.description = "New description"
      actual.save
      actual = Study.find_minimum(actual.uri)
      check_dates(actual, sub_dir, "update_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      actual.description = "Really new description"
      actual.save
      actual = Study.find_with_properties(actual.uri)
      expect(actual.description).to eq("Really new description")
    end

    it "simple update II" do
      actual = Study.create(identifier: "XXX")
      actual = Study.find_minimum(actual.uri)
      actual.label = "New label"
      actual.save
      actual = Study.find_minimum(actual.uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_3.yaml", equate_method: :hash_equal)
      actual.label = "Really new label"
      actual.save
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_4.yaml", equate_method: :hash_equal)
    end

    it "Study example" do
      p1 = Protocol.create(identifier: "XXX")
      s1 = Study.create(identifier: "MY STUDY", label: "My Study", description: "Some def", implements: p1.uri)
      s1.implements = p1.uri
      s1.save
      actual = Study.find_minimum(s1.uri)
      protocol = actual.implements_links
      protocol = Protocol.find_minimum(actual.implements_links)
      expect(actual.scoped_identifier).to eq("MY STUDY")
      check_dates(actual, sub_dir, "study_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, "study_expected_1.yaml", equate_method: :hash_equal)
      actual = actual.protocols
      expect(actual).to match_array([p1.uri])
    end

  end

end