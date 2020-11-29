require 'rails_helper'

describe "IsoConceptV2" do

	include DataHelpers
  include PauseHelpers
  include TimeHelpers
  include IsoHelpers
  include CustomPropertyHelpers

	def sub_dir
    return "models/iso_concept_v2"
  end

	context "Main Tests" do

    before :all do
      IsoHelpers.clear_cache
    end

	  before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_data_3.ttl"]
      load_files(schema_files, data_files)
	  end

		it "validates a valid object" do
	    result = IsoConceptV2.new
      result.uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
	    result.label = "123456789"
	    expect(result.valid?).to eq(true)
	  end

	  it "does not validate an invalid object" do
	    result = IsoConceptV2.new
	    result.label = "123456789@£$%"
	    expect(result.valid?).to eq(false)
	  end

	  it "allows an concept to be found" do
      uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
			expected =
				{
	      	:rdf_type => "http://www.assero.co.uk/ISO11179Concepts#Concept",
	      	:uri => uri.to_s,
	      	:label => "A Concept",
          :id => uri.to_id
	    	}
      result = IsoConceptV2.find(uri)
			expect(result.to_h).to eq(expected)
		end

		it "allows for the uri to be returned" do
			uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
      concept = IsoConceptV2.find(uri)
			expect(concept.uri.to_s).to eq("http://www.assero.co.uk/Y/V1#F-T_G1")
		end

    it "raises exception if item not found" do
      expect{IsoConceptV2.find("")}.to raise_error(Errors::ReadError, "Failed to query the database. SPARQL query failed.")
    end

		it "allows for the type fragment to be returned" do
			uri = Uri.new(uri: "http://www.assero.co.uk/Y/V1#F-T_G1")
      concept = IsoConceptV2.find(uri)
			expect(concept.uri.fragment).to eq("F-T_G1")
		end

    it "find or create" do
      expect(IsoConceptV2.where(label: "X").empty?).to eq(true)
      concept = IsoConceptV2.where_only_or_create("X")
      object = IsoConceptV2.where(label: "X")
      expect(object.count).to eq(1)
      expect(object.first.label).to eq("X")
    end

  end

  describe "Utility Methods" do

    def check_count(ct, n)
      query_string = %Q{
        SELECT ?o
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> ?o .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      expect(query_results.by_object(:o).count).to eq(n)
    end

    def check_uri(ct, set)
      query_string = %Q{
        SELECT ?o
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> ?o .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      expect(query_results.by_object(:o)).to eq(set)
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
    end

    it "add link" do
      item = Thesaurus::ManagedConcept.new
      item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      ct.add_link(:is_top_concept, item.uri)
      check_count(ct, 1)
      check_uri(ct, [item.uri])
    end

    it "delete link" do
      item1 = Thesaurus::ManagedConcept.new
      item1.uri = Uri.new(uri: "http://www.assero.co.uk/XXX1")
      item2 = Thesaurus::ManagedConcept.new
      item2.uri = Uri.new(uri: "http://www.assero.co.uk/XXX2")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      update_query = %Q{
        INSERT
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> #{item1.uri.to_ref} .
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> #{item2.uri.to_ref} .
        } WHERE {}
      }
      ct.partial_update(update_query, [])
      check_count(ct, 2)
      check_uri(ct, [item1.uri, item2.uri])
      ct.delete_link(:is_top_concept, item1.uri)
      check_uri(ct, [item2.uri])
      ct.delete_link(:is_top_concept, item2.uri)
      check_uri(ct, [])
    end

    # it "other parents" do
    #   uri_path_1 = Uri.new(uri: "http://www.assero.co.uk/Thesaurus#isTopConceptReference")
    #   uri_path_2 = Uri.new(uri: "http://www.assero.co.uk/BusinessOperational#reference")
    #   uri_th = Uri.new(uri: "http://www.cdisc.org/CT/V5#TH")
    #   uri_mc = Uri.new(uri: "http://www.cdisc.org/C66726/V4#C66726")
    #   th = IsoConceptV2.find(uri_th)
    #   mc = IsoConceptV2.find(uri_mc)
    #   results = mc.other_parents(th, [uri_path_1, uri_path_2])
    #   expect(results.map{|x| x.to_s}).to match_array(["http://www.cdisc.org/CT/V4#TH"])
    # end

  end

  describe "Tags" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..26)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    it "add and delete tags" do
      uri = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.new
      item_1.uri = uri
      item_1.save
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array([])
      tag_1 = IsoConceptSystem.path(["CDISC", "SDTM"])
      tag_2 = IsoConceptSystem.path(["CDISC", "ADaM"])
      item_1.add_tag(tag_1.id)
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array(["SDTM"])
      item_1.add_tag(tag_2.uri)
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array(["SDTM", "ADaM"])
      item_1.remove_tag(tag_1.uri)
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array(["ADaM"])
      item_1.remove_tag(tag_2.id)
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array([])
    end

    it "Gets tags" do
      uri = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.new
      item_1.uri = uri
      item_1.save
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array([])
      tag_1 = IsoConceptSystem.path(["CDISC", "SDTM"])
      tag_2 = IsoConceptSystem.path(["CDISC", "ADaM"])
      tag_3 = IsoConceptSystem.path(["CDISC", "CDASH"])
      tag_4 = IsoConceptSystem.path(["CDISC", "SEND"])
      item_1.add_tag(tag_1.id)
      item_1.add_tag(tag_2.uri)
      item_1.add_tag(tag_3.uri)
      item_1.add_tag(tag_4.uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array(["SDTM", "CDASH", "ADaM", "SEND"])
    end

		it "Gets tag labels" do
      uri = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.new
      item_1.uri = uri
      item_1.save
      item_1 = IsoConceptV2.find(uri)
      results = item_1.tags
      expect(results.map{|x| x.pref_label}).to match_array([])
      tag_1 = IsoConceptSystem.path(["CDISC", "SDTM"])
      tag_2 = IsoConceptSystem.path(["CDISC", "ADaM"])
      tag_3 = IsoConceptSystem.path(["CDISC", "CDASH"])
      tag_4 = IsoConceptSystem.path(["CDISC", "SEND"])
      item_1.add_tag(tag_1.id)
      item_1.add_tag(tag_2.uri)
      item_1.add_tag(tag_3.uri)
      item_1.add_tag(tag_4.uri)
      results = item_1.tag_labels
      expect(results).to eq(["ADaM", "CDASH", "SDTM", "SEND"])
		end

  end

  describe "indicators" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "thesaurus_new_airports.ttl", "change_instructions_test.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..26)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    it "Gets indicators, CL" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001")
      item_1 = IsoConceptV2.find(uri)
      results = item_1.indicators
      check_file_actual_expected(results, sub_dir, "indicators_expected_1.yaml")
    end

    it "Gets indicators, CLI" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011")
      item_1 = IsoConceptV2.find(uri)
      results = item_1.indicators
      check_file_actual_expected(results, sub_dir, "indicators_expected_2.yaml")
    end

    it "Gets indicators, CL" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001")
      item_1 = IsoConceptV2.find(uri)
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/CID")
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx1", reference: "ref 1", description: "description 1", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3400")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:10:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx2", reference: "ref 2", description: "description 2", context_id: uri_2.to_id)
      results = item_1.indicators
      check_file_actual_expected(results, sub_dir, "indicators_expected_3.yaml")
    end

    it "Gets indicators, CLI" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011")
      item_1 = IsoConceptV2.find(uri)
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/CID")
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx1", reference: "ref 1", description: "description 1", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3400")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:10:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx2", reference: "ref 2", description: "description 2", context_id: uri_2.to_id)
      results = item_1.indicators
      check_file_actual_expected(results, sub_dir, "indicators_expected_4.yaml")
    end

  end

  describe "Change Notes" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "add change notes" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/C1")
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/CID")
      item_1 = IsoConceptV2.create(uri: uri_1, label: "1")
      item_1.add_change_note(user_reference: "xxx", reference: "ref 1", description: "description", context_id: uri_2.to_id)
      uri_3 = Uri.new(uri: "http://www.assero.co.uk/CN#1234-5678-9012-3456")
      cn_1 = Annotation::ChangeNote.find(uri_3)
      check_file_actual_expected(cn_1.to_h, sub_dir, "add_change_notes_expected_1a.yaml")
      or_1 = OperationalReferenceV3.find(cn_1.current.first)
      check_file_actual_expected(or_1.to_h, sub_dir, "add_change_notes_expected_1b.yaml")
    end

    it "change notes" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/C1")
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/CID")
      item_1 = IsoConceptV2.create(uri: uri_1, label: "1")
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx1", reference: "ref 1", description: "description 1", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3400")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:10:00+01:00 2000"))
      item_1.add_change_note(user_reference: "xxx2", reference: "ref 2", description: "description 2", context_id: uri_2.to_id)
      results = item_1.change_notes
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "change_notes_expected_1.yaml")
    end

  end

  describe "Change Instructions" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..33)
    end

    it "change instructions, Iso Concept V2 with Change Notes and CI attached" do
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      tc = IsoConceptV2.find(Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779"))
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      tc.add_change_note(user_reference: "xxx1", reference: "ref 1", description: "description 1", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3400")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:10:00+01:00 2000"))
      tc.add_change_note(user_reference: "xxx2", reference: "ref 2", description: "description 2", context_id: uri_2.to_id)
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-4567")
      item = Annotation::ChangeInstruction.create
      item.update(description: "D", reference: "R", semantic: "S")
      item = Annotation::ChangeInstruction.find(item.id)
      item.add_references(previous: [uri_1.to_id], current: [uri_2.to_id])
      item = Annotation::ChangeInstruction.find(item.id)
      actual = tc.change_instructions
      check_file_actual_expected(actual, sub_dir, "change_instructions_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Change instructions, Iso Concept V2 with CI attached" do
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      tc = IsoConceptV2.find(Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779"))
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-4567")
      item = Annotation::ChangeInstruction.create
      item.update(description: "D", reference: "R", semantic: "S")
      item = Annotation::ChangeInstruction.find(item.id)
      item.add_references(previous: [uri_1.to_id], current: [uri_2.to_id])
      item = Annotation::ChangeInstruction.find(item.id)
      actual = tc.change_instructions
      check_file_actual_expected(actual, sub_dir, "change_instructions_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Clone" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "clone" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.create(uri: uri_1, label: "1")
      item_2 = item_1.clone
      expect(item_1.label).to eq(item_2.label)
      check_file_actual_expected(item_2.to_h, sub_dir, "clone_expected_1.yaml")
    end

    it "clone custom proprties" do
      create_data
      item_2 = @child_1.clone(@parent)
      expect(@child_1.label).to eq(item_2.label)
      check_file_actual_expected(item_2.to_h, sub_dir, "clone_expected_2a.yaml")
      check_file_actual_expected(item_2.custom_properties.to_h, sub_dir, "clone_expected_2b.yaml")
    end

  end

  describe "Create" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    it "create" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.create(uri: uri_1, label: "1")
      check_file_actual_expected(item_1.to_h, sub_dir, "create_expected_1.yaml")
    end

    it "create custom proprties" do
      @definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Some String", 
        description: "A description XXX", default: "Default String",
        custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
        uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
      @definition_2 = CustomPropertyDefinition.create(datatype: "boolean", label: "A Flag", 
        description: "A description YYY", default: "false",
        custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
        uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/C1")
      item_1 = IsoConceptV2.create(uri: uri_1, label: "1")
      check_file_actual_expected(item_1.to_h, sub_dir, "create_expected_2a.yaml")
      check_file_actual_expected(item_1.custom_properties.to_h, sub_dir, "create_expected_2b.yaml")
    end

  end

  describe "managed ancestors" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "raises exception unless path method overloaded" do
      expect{IsoConceptV2.managed_ancestors_path}.to raise_error(Errors::ApplicationLogicError, "Method not implemented for class.")
    end

    it "managed ancestors properties" do
      form = Form.new
      result = form.managed_ancestors_predicate(Form::Group::Normal)
      expect(result).to eq([:has_group])
    end

    it "managed ancestors properties set" do
      result = Form.new.managed_ancestors_children_set
      expect(result).to eq([])
    end

  end

end
