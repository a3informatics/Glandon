require 'rails_helper'

describe IsoConceptSystem do

	include DataHelpers
  include PauseHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/iso_concept_system"
  end

  describe "No root" do

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl"
      ]
      data_files = 
      [
        "iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"    
      ]
      load_files(schema_files, data_files)
      #clear_iso_concept_object
    end

    it "creates the root node if not present" do
      concept = IsoConceptSystem.root
      expect(concept.pref_label).to eq("Tags")
      expect(concept.description).to eq("Root node for all tags")
    end

    it "only creates a single root node" do
      concept_1 = IsoConceptSystem.root
      concept_2 = IsoConceptSystem.root
      expect(concept_1.uri).to eq(concept_2.uri)
    end

    it "handles a bad response error - create" do
      response = IsoConceptSystem.new
      response.errors.add(:base, "Failure!")
      expect(IsoConceptSystem).to receive(:create).and_return(response)
      expect{IsoConceptSystem.root}.to raise_error(Errors::ApplicationLogicError, "Errors creating the tag root node. Failure!")
    end

  end

  describe "Existing data" do

  	before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl"
      ]
      data_files = 
      [
        "iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_concept_system_generic_data.ttl"  
      ]
      load_files(schema_files, data_files)
      #clear_iso_concept_object
    end

    it "allows the object to be created from params" do
      actual = IsoConceptSystem.create({uri: IsoConceptSystem.create_uri(IsoConceptSystem.base_uri), pref_label: "Node 3", description: "Node 3"})
      check_file_actual_expected(actual.to_h, sub_dir, "create_expected_1.yaml", equate_method: :iso_concept_system_equal)
    end

    it "prevents an object being created from invalid json" do
      actual = IsoConceptSystem.create({uri: IsoConceptSystem.create_uri(IsoConceptSystem.base_uri), pref_label: "Node 3", description: "Node 3±"})
      expect(actual.errors.count).to eq(1)
    end

    it "allows a child object to be added" do
      concept = IsoConceptSystem.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C3"))
      params = { :label => "Node 3_3", :description => "Node 3_3"}
      actual = concept.add(params)
      expect(actual.errors.count).to eq(0)
      actual = IsoConceptSystem.find(actual.uri)
      check_file_actual_expected(actual.to_h, sub_dir, "add_expected_1.yaml", equate_method: :iso_concept_system_equal)
    end

    it "allows an object to be destroyed" do
      concept = IsoConceptSystem.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))
      concept.delete
      expect{IsoConceptSystem.find(Uri.new(uri: "http://www.assero.co.uk/MDRConcepts#GSC-C2"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRConcepts#GSC-C2 in IsoConceptSystem.")
    end

    it "tag separator" do
      actual = IsoConceptSystem.tag_separator
      expect(actual).to eq(";")
    end


  end

  describe "Path" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "Find SDTM" do
      result = IsoConceptSystem.path(["CDISC", "SDTM"])
      check_file_actual_expected(result.to_h, sub_dir, "path_expected_1.yaml", equate_method: :iso_concept_system_equal)
    end

    it "Find ADaM" do
      result = IsoConceptSystem.path(["CDISC", "ADaM"])
      check_file_actual_expected(result.to_h, sub_dir, "path_expected_2.yaml", equate_method: :iso_concept_system_equal)
    end

  end

end