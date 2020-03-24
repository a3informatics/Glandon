require 'rails_helper'

describe "Protocol" do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers

  def sub_dir
    return "models/protocol"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "create an instance" do
      actual = Protocol.create(identifier: "XXX")
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.studyPhase).to eq(nil)
      expect(actual.studyType).to eq(nil)
      actual = Protocol.find_minimum(actual.uri)
      expect(actual.scoped_identifier).to eq("XXX")
      expect(actual.version).to eq(1)
      expect(actual.semantic_version).to eq("0.1.0")
      expect(actual.studyPhase).to eq(nil)
      expect(actual.studyType).to eq(nil)
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "simple update" do
      actual = Protocol.create(identifier: "XXX")
      actual = Protocol.find_minimum(actual.uri)
      actual.label = "New label"
      actual.save
      actual = Protocol.find_minimum(actual.uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      actual.label = "Really new label"
      actual.save
      check_file_actual_expected(actual.to_h, sub_dir, "update_expected_2.yaml", equate_method: :hash_equal)
    end

    # it "Study example" do
    #   s1 = Study.create(identifier: "MY STUDY", name: "My Study")
    #   p1 = Protocol.create(identifier: "XXX", implements: s1.uri)
    #   p1.implements = s1.uri
    #   p1.save
    #   actual = Protocol.find_minimum(p1.uri)
    #   study = actual.implements_links
    #   study = Study.find_minimum(actual.implements_links)
    #   expect(study.scoped_identifier).to eq("MY STUDY")
    #   check_file_actual_expected(study.to_h, sub_dir, "study_expected_1.yaml", equate_method: :hash_equal)
    #   actual = study.protocols
    #   expect(actual).to match_array([p1.uri])
    # end

  end

end