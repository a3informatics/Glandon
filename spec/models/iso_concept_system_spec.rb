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

  end

  describe "Create Tags" do

    before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl"
      ]
      load_files(schema_files, data_files)
      #clear_iso_concept_object
    end

    after :all do
      delete_all_public_test_files
    end

    it "allows a child object to be added" do
      cs = IsoConceptSystem.root
      cdisc = cs.add({label: "CDISC", description: "CDISC related tags"})
      sdtm = cdisc.add({label: "SDTM", description: "SDTM related information."})
      cdash = cdisc.add({label: "CDASH", description: "CDASH related information."})
      adam = cdisc.add({label: "ADaM", description: "ADaM related information."})
      send = cdisc.add({label: "SEND", description: "SEND related information."})
      protocol = cdisc.add({label: "Protocol", description: "Protocol related information."})
      qs = cdisc.add({label: "QS", description: "Questionnaire related information."})
      qs_ft = cdisc.add({label: "QS-FT", description: "Questionnaire and Functional Test related information."})
      coa = cdisc.add({label: "COA", description: "Clinical Outcome Assessent related information."})
      qrs = cdisc.add({label: "QRS", description: "Questionnaire and Rating Scale related information."})

      cs.is_top_concept_objects
      cdisc.narrower_objects

      sparql = Sparql::Update.new
      sparql.default_namespace(cs.uri.namespace)
      cs.to_sparql(sparql, true)
      cdisc.to_sparql(sparql, true)
      cdisc.narrower.each {|x| x.to_sparql(sparql, true)}
      file = sparql.to_file

      copy_file_from_public_files_rename("test", file.basename, sub_dir, "iso_concept_systems_baseline.ttl")
    end

  end

end