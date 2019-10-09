require 'rails_helper'

describe "Thesaurus::ManagedConcept" do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  
  def sub_dir
    return "models/thesaurus/managed_concept"
  end

  describe "general tests" do

    def simple_thesaurus_1
      @ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      @th_1 = Thesaurus.new
      @tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      @tc_1.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
      @tc_1.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
      @tc_1.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
      @tc_1a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
      @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
      @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
      @tc_1a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
      @tc_1a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
      @tc_1b = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 1",
          identifier: "A000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        })
      @tc_1b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
      @tc_1.narrower << @tc_1a
      @tc_1.narrower << @tc_1b
      @tc_2 = Thesaurus::ManagedConcept.new
      @tc_2.identifier = "A00002"
      @tc_2.definition = "Copenhagen"
      @tc_2.extensible = false
      @tc_2.notation = "CPH"
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_1.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
    end

    def simple_thesaurus_2
      @th_2 = Thesaurus.new
      @tc_3 = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      @tc_3.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
      @tc_3.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
      @tc_3.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
      @tc_3a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
      @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
      @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
      @tc_3a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
      @tc_3a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
      params = {
          label: "Terminal 1",
          identifier: "A000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        }
      params[:definition] = "The oldest LHR Terminal. A real mess",
      @tc_3b = Thesaurus::UnmanagedConcept.from_h(params)
      @tc_3b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
      @tc_3.narrower << @tc_3a
      @tc_3.narrower << @tc_3b
      @tc_4 = Thesaurus::ManagedConcept.new
      @tc_4.identifier = "A00002"
      @tc_4.definition = "Copenhagen"
      @tc_4.extensible = false
      @tc_4.notation = "CPH"
      @th_2.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_3.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_2.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_4.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
    end

    def simple_thesaurus_3
      @th_3 = Thesaurus.new
      @tc_5 = Thesaurus::ManagedConcept.from_h({
          label: "London Heathrow",
          identifier: "A00001",
          definition: "A definition",
          notation: "LHR"
        })
      @tc_5.synonym << Thesaurus::Synonym.where_only_or_create("Heathrow")
      @tc_5.synonym << Thesaurus::Synonym.where_only_or_create("LHR")
      @tc_5.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("London Heathrow")
      @tc_5c = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal X",
          identifier: "A000014",
          definition: "The new new LHR Terminal. Never going to happen",
          notation: "TX"
        })
      @tc_5c.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal X")
      @tc_5a = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 5",
          identifier: "A000011",
          definition: "The 5th LHR Terminal",
          notation: "T5"
        })
      @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("T5")
      @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("Terminal Five")
      @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("BA Terminal")
      @tc_5a.synonym << Thesaurus::Synonym.where_only_or_create("British Airways Terminal")
      @tc_5a.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 5")
      @tc_5b = @tc_1b = Thesaurus::UnmanagedConcept.from_h({
          label: "Terminal 1",
          identifier: "A000012",
          definition: "The oldest LHR Terminal",
          notation: "T1"
        })
      @tc_5b.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Terminal 1")
      @tc_5.narrower << @tc_5a
      @tc_5.narrower << @tc_5b
      @tc_5.narrower << @tc_5c
      @tc_6 = Thesaurus::ManagedConcept.new
      @tc_6.identifier = "A00002"
      @tc_6.definition = "Copenhagen"
      @tc_6.extensible = false
      @tc_6.notation = "CPH"
      @th_3.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_5.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      @th_3.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: @tc_6.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    it "allows validity of the object to be checked - error" do
      tc = Thesaurus::ManagedConcept.new
      expect(tc.valid?).to eq(false)
      expect(tc.errors.count).to eq(4)
      expect(tc.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier: Empty object, Has state: Empty object, and Identifier is empty")
    end 

    it "allows validity of the object to be checked" do
      tc = Thesaurus::ManagedConcept.new
      tc.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      tc.identifier = "AAA"
      tc.notation = "A"
      tc.has_state = IsoRegistrationStateV2.new
      tc.has_state.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#RS_A00001")
      tc.has_state.by_authority = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      tc.has_identifier = IsoScopedIdentifierV2.new
      tc.has_identifier.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#SI_A00001")
      tc.has_identifier.identifier = "AAA"
      tc.has_identifier.semantic_version = "0.0.1"
      valid = tc.valid?
      expect(valid).to eq(true)
    end 

    it "allows a TC to be found" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.identifier).to eq("A00001")    
    end

    it "allows a TC to be found - error" do
      expect{Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001x"))}.to raise_error(Errors::NotFoundError, 
        "Failed to find http://www.acme-pharma.com/A00001/V1#A00001x in Thesaurus::ManagedConcept.")  
    end

    it "allows the existance of a TC to be determined" do
      expect(Thesaurus::ManagedConcept.exists?("A00001")).to eq(true)
    end

    it "allows the existance of a TC to be determined - not there" do
      expect(Thesaurus::ManagedConcept.exists?("A00001x")).to eq(false)
    end

    it "finds by properties, single" do
    	results = Thesaurus::ManagedConcept.where({identifier: "A00001"})
    	expect(results.count).to eq(1)
  	end

    it "finds by properties, multiple" do
    	results = Thesaurus::ManagedConcept.where({notation: "LHR", label: "London Heathrow"})
    	expect(results.count).to eq(1)
  	end

    it "allows a new child TC to be added" do
      params = 
      {
        definition: "The Queen's Terminal, the second terminal at Heathrow",
        identifier: "A00014",
        label: "Terminal 2",
        notation: "T2"
      }
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(0)
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_1.yaml")
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_NC00000456C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_2.yaml")
    end

    it "prevents a duplicate TC being added" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00014",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(0)
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(1)
      expect(new_object.errors.full_messages[0]).to eq("An existing record exisits in the database")
    end

    it "prevents a TC being added with invalid identifier" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      params = 
      {
        definition: "Other or mixed race",
        identifier: "?",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(1)
      expect(new_object.errors.full_messages[0]).to eq("Identifier contains a part with invalid characters")
    end

    it "prevents a TC being added with invalid data" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      params = 
      {
        definition: "Other or mixed race!@£$%^&*(){}",
        identifier: "?",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(2)
      expect(new_object.errors.full_messages.to_sentence).to eq("Identifier contains a part with invalid characters and Definition contains invalid characters")
    end

    it "allows a TC to be saved" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00014",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = "New_XXX"
      new_object.notation = "NEWNEWXXX"
      new_object.save
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_NC00000456C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_1.yaml")
    end

    it "allows a TC to be saved, quotes test" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00014",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = "New \"XXX\""
      new_object.save
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_NC00000456C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_2.yaml")
    end
    
    it "allows a TC to be updated, character test" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00014",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = vh_all_chars
      new_object.notation = vh_all_chars + "^"
      new_object.definition = 
      new_object.update(definition: vh_all_chars)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_NC00000456C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_3.yaml")
    end
    
    it "allows to determine if TCs different" do
      tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00002/V1#A00002"))
      results = tc1.diff?(tc2)
      expect(results).to eq(true)
    end

    it "allows to determine if TCs same" do
      tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      results = tc1.diff?(tc2)
      expect(results).to eq(false)
    end

    it "allows to determine if TCs different - notation" do
      tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      tc1.notation = "MODIFIED"
      tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      results = tc1.diff?(tc2)
      expect(results).to eq(true)
    end

    it "allows the object to be exported as Hash" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "to_hash_expected.yaml")
    end

    it "allows a TC to be created from Hash" do
      input = read_yaml_file(sub_dir, "from_hash_input.yaml")
      tc = Thesaurus::ManagedConcept.from_h(input)
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "from_hash_expected.yaml")
    end

    it "allows a TC to be exported as SPARQL" do
      sparql = Sparql::Update.new
      simple_thesaurus_1
      @th_1.set_initial("NEW_TH")
      @tc_1.set_initial(@tc_1.identifier)
      @tc_2.set_initial(@tc_2.identifier)
      sparql.default_namespace(@th_1.uri.namespace)
      @th_1.to_sparql(sparql, true)
      @tc_1.to_sparql(sparql, true)
      @tc_2.to_sparql(sparql, true)
      full_path = sparql.to_file
    #Xcopy_file_from_public_files_rename("test", File.basename(full_path), sub_dir, "managed_concept.ttl")
    end
    
    it "allows a TC to be exported as SPARQL, I" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      sparql = Sparql::Update.new
      tc.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt") 
    end

    it "allows a TC to be exported as SPARQL, II - WILL CURRENTLY FAIL (Timestamp Issue)" do
      sparql = Sparql::Update.new
      simple_thesaurus_1
      @tc_1.set_initial(@tc_1.identifier)
      sparql.default_namespace(@tc_1.uri.namespace)
      @tc_1.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_2.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_2.txt") 
    end
    
    it "allows a TC to be created" do
      object = Thesaurus::ManagedConcept.create({identifier: "A000001", notation: "A"})
      tc = Thesaurus::ManagedConcept.find_full(object.uri)
      expect(tc.scoped_identifier).to eq("A000001")
      expect(tc.identifier).to eq("A000001")
      expect(tc.notation).to eq("A")
    end

    it "allows a TC to be destroyed" do
      object = Thesaurus::ManagedConcept.create({identifier: "AAA", notation: "A"})
      tc = Thesaurus::ManagedConcept.find(object.uri)
      result = tc.delete
      expect(result).to eq(1)
      expect{Thesaurus::ManagedConcept.find(object.uri)}.to raise_error(Errors::NotFoundError, 
        "Failed to find http://www.acme-pharma.com/AAA/V1#AAA in Thesaurus::ManagedConcept.")  
    end

    it "does not allow a TC to be destroyed if it has children" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      result = tc.delete
      expect(result).to eq(0)
      expect(tc.errors.count).to eq(1)
      expect(tc.errors.full_messages[0]).to eq("Cannot delete terminology concept with identifier A00001 due to the concept having children")
    end

    it "returns the parent concept" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00014",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_NC00000456C"))
      expect(tc.parent).to eq("A00001")
    end

    it "returns the parent concept, none" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect{tc.parent}.to raise_error(Errors::ApplicationLogicError, "Failed to find parent for A00001.")
    end

    it "replaces with previous if no difference" do
      simple_thesaurus_1
      @tc_1.uri = "XXX"
      expect(@tc_1.replace_if_no_change(@tc_1).uri).to eq(@tc_1.uri)
    end

    it "replaces with previous, difference" do
      simple_thesaurus_1
      simple_thesaurus_2
      @tc_1.uri = "XXX" # URIs just need to be unique strings
      @tc_3.uri = "YYY"
      expect(@tc_3.replace_if_no_change(@tc_1).uri).to eq(@tc_1.uri)
    end

    it "replaces with previous, difference" do
      simple_thesaurus_1
      simple_thesaurus_3
      @tc_5.uri = "XXX" # URIs just need to be unique strings
      @tc_6.uri = "YYY"
      expect(@tc_6.replace_if_no_change(@tc_5).uri).to eq(@tc_6.uri)
    end

    it "determines if code list extended and finds the URIs" do
      tc1 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      tc2 = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00002/V1#A00002"))
      expect(tc1.extended?).to eq(false)
      expect(tc2.extended?).to eq(false)
      expect(tc1.extension?).to eq(false)
      expect(tc2.extension?).to eq(false)
      sparql = %Q{INSERT DATA { #{tc2.uri.to_ref} th:extends #{tc1.uri.to_ref} }}
      Sparql::Update.new.sparql_update(sparql, "", [:th]) 
      expect(tc1.extended?).to eq(true)
      expect(tc2.extended?).to eq(false)
      expect(tc1.extension?).to eq(false)
      expect(tc2.extension?).to eq(true)
      expect(tc1.extended_by).to eq(tc2.uri)
      expect(tc1.extension_of).to eq(nil)
      expect(tc2.extension_of).to eq(tc1.uri)
      expect(tc2.extended_by).to eq(nil)
    end

  end

  describe "changes and differences" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..59)
      delete_all_public_test_files
    end

    it "finds changes count" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      expect(tc.changes_count(4)).to eq(4)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V29#C65047"))
      expect(tc.changes_count(40)).to eq(29)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V1#C65047"))
      expect(tc.changes_count(40)).to eq(40)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V1#C65047"))
      expect(tc.changes_count(4)).to eq(4)
    end

    it "finds changes, 4" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      results = tc.changes(4)
      check_file_actual_expected(results, sub_dir, "changes_expected_1.yaml")
    end

    it "finds changes, 8" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      results = tc.changes(8)
      check_file_actual_expected(results, sub_dir, "changes_expected_2.yaml")
    end

    it "finds changes, 8" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V30#C101805"))
      results = tc.changes(8)
      check_file_actual_expected(results, sub_dir, "changes_expected_3.yaml", write_file: true)
    end

    it "differences, I" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_1.yaml")
    end

    it "differences, II" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C124661/V45#C124661"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_2.yaml")
    end

    it "differences, III" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C100129/V54#C100129"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_3.yaml")
    end

    it "differences, IV" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C100129/V29#C100129"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_4.yaml")
    end

    it "differences, V" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V30#C101805"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_5.yaml")
    end

    it "differences, VI" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V36#C101805"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_6.yaml")
    end

    it "differences_summary, first item first version" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V30#C101805"))
      last = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V59#C101805"))
      results = tc.differences_summary(last)
      check_file_actual_expected(results, sub_dir, "differences_summary_expected_1.yaml")
    end

    it "differences_summary, first item other version" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V36#C101805"))
      last = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V59#C101805"))
      results = tc.differences_summary(last)
      check_file_actual_expected(results, sub_dir, "differences_summary_expected_2.yaml")
    end

    it "changes_summary" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V36#C101805"))
      last = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C101805/V59#C101805"))
      results = tc.changes_summary(last)
      check_file_actual_expected(results, sub_dir, "changes_summary_expected_1.yaml")
    end

  end

  describe "updates" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "assigns properties, prevent identifier update" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.definition).to eq("A definition")    
      tc.update({identifier: "A00001a", definition: "Updated"})
      expect(tc.identifier).to eq("A00001") # Note, no ability to change identifier
      expect(tc.definition).to eq("Updated")    
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.identifier).to eq("A00001")    
      expect(tc.definition).to eq("Updated")      
    end

    it "assigns properties, synonyms" do
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.definition).to eq("A definition")    
      expect(tc.synonym.count).to eq(2)
      expect(tc.synonym.first.label).to eq("LHR")
      expect(tc.synonym.last.label).to eq("Heathrow")
      tc.update({definition: "Updated", synonym: "LHR; Heathrow; Worst Airport Ever"})
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.definition).to eq("Updated")    
      expect(tc.synonym.count).to eq(3)
      expect(tc.synonym.map{|x| x.label}).to match_array(["LHR", "Heathrow", "Worst Airport Ever"])
      tc.update({synonym: "aaaa; bbbb"})
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.definition).to eq("Updated")    
      expect(tc.synonym.count).to eq(2)
      expect(tc.synonym.map{|x| x.label}).to match_array(["aaaa", "bbbb"])
    end

    it "assigns properties, preferred term and label" do
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.label).to eq("London Heathrow")    
      expect(tc.synonym.count).to eq(2)
      expect(tc.synonym.first.label).to eq("LHR")
      expect(tc.synonym.last.label).to eq("Heathrow")
      tc.update({synonym: "LHR; Heathrow; Worst Airport Ever", preferred_term: "Woah!"})
      tc = Thesaurus::ManagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.label).to eq("Woah!")    
      expect(tc.synonym.count).to eq(3)
      expect(tc.synonym.map{|x| x.label}).to match_array(["LHR", "Heathrow", "Worst Airport Ever"])
      expect(tc.preferred_term.label).to eq("Woah!")
    end

    it "add and delete extensions" do
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.narrower.count).to eq(2)
      tc_1 = Thesaurus::ManagedConcept.from_h({
          label: "Bristol",
          identifier: "A00003",
          definition: "A definition",
          notation: "BRS"
        })
      tc_1.set_initial("A00003")
      tc_1.save
      tc_2 = Thesaurus::ManagedConcept.from_h({
          label: "Exeter",
          identifier: "A00004",
          definition: "A definition",
          notation: "EXT"
        })
      tc_2.set_initial("A00004")
      tc_2.save
      tc_3 = Thesaurus::ManagedConcept.from_h({
          label: "Birmingham",
          identifier: "A00005",
          definition: "A definition",
          notation: "BXM"
        })
      tc_3.set_initial("A00005")
      tc_3.save
      tc.add_extensions([tc_1.uri, tc_2.uri])
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.narrower.count).to eq(4)
      tc.add_extensions([tc_3.uri])
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.narrower.count).to eq(5)
      tc.delete_extensions([tc_3.uri, tc_2.uri])
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.narrower.count).to eq(3)
      tc.delete_extensions([tc_1.uri])
      tc = Thesaurus::ManagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(tc.narrower.count).to eq(2)
    end

  end

  describe "csv test" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    after :all do
      delete_all_public_test_files
    end

    it "to csv data" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66790/V2#C66790"))
      results = tc.to_csv_data
      check_file_actual_expected(results, sub_dir, "csv_data_expected_1.yaml")
    end

    it "to csv" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66790/V2#C66790"))
      results = tc.to_csv
      check_file_actual_expected(results, sub_dir, "csv_expected_1.yaml")
    end

    it "to csv 2" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66788/V2#C66788"))
      results = tc.to_csv
      check_file_actual_expected(results, sub_dir, "csv_expected_2.yaml")
    end
    
  end

  describe "child pagination" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..30)
    end

    after :all do
      delete_all_public_test_files
    end

    it "normal" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      results = tc.children_pagination(count: 20, offset: 0)
      check_file_actual_expected(results, sub_dir, "child_pagination_expected_1.yaml")
    end

    it "normal, count and offset" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V20#C65047"))
      results = tc.children_pagination(count: 10, offset: 10)
      check_file_actual_expected(results, sub_dir, "child_pagination_expected_2.yaml")
    end

    it "normal, extended" do
      thesaurus = Thesaurus.create({identifier: "XXX", label: "YYY"})
      thesaurus = Thesaurus.find_minimum(thesaurus.uri)
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V30#C99079"))
      item = thesaurus.add_extension(tc.id)
      results = item.children_pagination(count: 20, offset: 0)
      check_file_actual_expected(results, sub_dir, "child_pagination_expected_3.yaml")
      ext = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C99078/V28#C99078_C307"))
      item.add_extensions([ext.uri])
      results = item.children_pagination(count: 20, offset: 0)
      check_file_actual_expected(results, sub_dir, "child_pagination_expected_4.yaml")
    end

  end

end