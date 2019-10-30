require 'rails_helper'

describe "Thesaurus::UnmanagedConcept" do

  include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include ThesauriHelpers
  
  def sub_dir
    return "models/thesaurus/unmanaged_concept"
  end

  describe "general tests" do
  
    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
    end

    after :each do
      NameValue.destroy_all
    end

    it "allows validity of the object to be checked - error" do
      tc = Thesaurus::UnmanagedConcept.new
      expect(tc.valid?).to eq(false)
      expect(tc.errors.count).to eq(2)
      expect(tc.errors.full_messages.to_sentence).to eq("Uri can't be blank and Identifier is empty")
    end 

    it "allows validity of the object to be checked" do
      tc = Thesaurus::UnmanagedConcept.new
      tc.uri = Uri.new(uri:"http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00001")
      tc.identifier = "AAA"
      tc.notation = "A"
      valid = tc.valid?
      expect(valid).to eq(true)
    end 

    it "allows a TC to be found" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      expect(tc.identifier).to eq("A000011")    
    end

    it "allows a TC to be found - error" do
      expect{Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011x"))}.to raise_error(Errors::NotFoundError, 
        "Failed to find http://www.acme-pharma.com/A00001/V1#A00001_A000011x in Thesaurus::UnmanagedConcept.")  
    end

    it "allows the existance of a TC to be determined" do
      expect(Thesaurus::UnmanagedConcept.exists?("A000011")).to eq(true)
    end

    it "allows the existance of a TC to be determined - not there" do
      expect(Thesaurus::UnmanagedConcept.exists?("A000011x")).to eq(false)
    end

    it "finds by properties, single" do
    	results = Thesaurus::UnmanagedConcept.where({identifier: "A000011"})
    	expect(results.count).to eq(1)
  	end

    it "finds by properties, multiple" do
    	results = Thesaurus::UnmanagedConcept.where({notation: "T1", label: "Terminal 1"})
    	expect(results.count).to eq(1)
  	end


    
    it "allows to determine if TCs different" do
      tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000012"))
      results = tc1.diff?(tc2)
      expect(results).to eq(true)
    end

    it "allows to determine if TCs same" do
      tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      results = tc1.diff?(tc2)
      expect(results).to eq(false)
    end

    it "allows to determine if TCs different - notation" do
      tc1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      tc1.notation = "Tx5"
      tc2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      results = tc1.diff?(tc2)
      expect(results).to eq(true)
    end

    it "allows the object to be exported as Hash" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      check_file_actual_expected(tc.to_h, sub_dir, "to_h_expected.yaml")
    end

    it "allows a TC to be created from Hash" do
      input = read_yaml_file(sub_dir, "from_hash_input.yaml")
      tc = Thesaurus::UnmanagedConcept.from_h(input)
      check_file_actual_expected(tc.to_h, sub_dir, "from_hash_expected.yaml")
    end

    it "allows a TC to be exported as SPARQL I, WILL CURRENT FAIL (Timestamp issue)" do
      ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      sparql = Sparql::Update.new
      th = Thesaurus.new
      #th.uri = Uri.new(uri: "http://www.assero.co.uk/TH#OWNER-TH")
      tc_1 = Thesaurus::UnmanagedConcept.from_h({
          uri: "http://www.assero.co.uk/TC#OWNER-A00022", 
          label: "Axe",
          identifier: "A00022",
          defintion: "A definiton",
          notation: "AXE",
          preferred_term: Uri.new(uri: "http://www.assero.co.uk/PT#1")
        })
      tc_2 = Thesaurus::UnmanagedConcept.new
      tc_2.uri = Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001_A000011")
      tc_2.identifier = "A000011"
      tc_2.definition = "The definition."
      tc_2.extensible = false
      tc_2.notation = "NOTATION1"
      tc_2.synonym << Thesaurus::Synonym.where_only_or_create("synonym 1")
      tc_2.synonym << Thesaurus::Synonym.where_only_or_create("synonym 2")
      tc_2.preferred_term = Thesaurus::PreferredTerm.where_only_or_create("Preferred Term 1")
      th.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: tc_1.uri, local_label: "", enabled: true, ordinal: 1, optional: true})
      th.is_top_concept_reference << OperationalReferenceV3::TcReference.from_h({reference: tc_2.uri, local_label: "", enabled: true, ordinal: 2, optional: true})
      th.set_initial("NEW_TH")
      sparql.default_namespace(th.uri.namespace)
      th.to_sparql(sparql, true)
      tc_1.to_sparql(sparql, true)
      tc_2.to_sparql(sparql, true)
      #full_path = sparql.to_file << May fix timestamp issue
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.ttl")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.ttl")  
    end
    
    it "allows a TC to be exported as SPARQL II" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      sparql = Sparql::Update.new
      tc.to_sparql(sparql, true)
    #Xwrite_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_2.ttl")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_2.ttl") 
    end
    
    it "allows a TC to be destroyed" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      expect(Thesaurus::UnmanagedConcept.exists?("A000011")).to eq(true)
      result = tc.delete
      expect(result).to eq(1)
      expect{Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))}.to raise_error(Errors::NotFoundError, 
        "Failed to find http://www.acme-pharma.com/A00001/V1#A00001_A000011 in Thesaurus::UnmanagedConcept.")  
    end

    it "does not allow a TC to be destroyed if it has children" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      result = tc.delete
      expect(result).to eq(0)
      expect(tc.errors.count).to eq(1)
      expect(tc.errors.full_messages[0]).to eq("Cannot delete terminology concept with identifier A000011 due to the concept having children")
    end

    it "returns the parent concept" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      expect(tc.parent).to eq("A000011")
    end

    it "returns the parent concept, none" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011")) # Need a parent
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.create(params, tc)
      expect{tc.parent}.to raise_error(Errors::ApplicationLogicError, "Failed to find parent for A00004.")
    end

    it "replaces with previous if no difference" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011")) # Need a parent
      tc_current = Thesaurus::UnmanagedConcept.create({:label=>"A label", :identifier=>"A00021", :notation=>"NOTATION1", :definition=>"The definition."}, tc)
      tc_previous = Thesaurus::UnmanagedConcept.create({:label=>"A label", :identifier=>"A00021", :notation=>"NOTATION1", :definition=>"The definition."}, tc)
      expect(tc_current.replace_if_no_change(tc_previous).uri).to eq(tc_previous.uri)
      expect(tc_previous.narrower.count).to eq(0)
    end

    it "keeps current if difference" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011")) # Need a parent
      tc_current = Thesaurus::UnmanagedConcept.create({:label=>"A label", :identifier=>"A00021", :notation=>"NOTATION1", :definition=>"The definition."}, tc)
      tc_previous = Thesaurus::UnmanagedConcept.create({:label=>"A label", :identifier=>"A00021", :notation=>"NOTATION1", :definition=>"The definition."}, tc)
      tc_previous.update(notation: "SSSSSS")
      expect(tc_current.replace_if_no_change(tc_previous).uri).to eq(tc_current.uri)
      expect(tc_current.narrower.count).to eq(0)
    end

  end

  describe "write tests" do
  
    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_child_identifier", value: "999")
    end

    after :each do
      NameValue.destroy_all
    end

        it "allows a new child TC to be added, some data" do
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(0)
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_1.yaml")
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_2.yaml")
    end

    it "allows a new child TC to be added" do
      params = 
      {
        identifier: "A00005",
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(0)
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_3.yaml")
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "add_child_expected_4.yaml")
    end

    it "prevents a duplicate TC being added" do
      #local_configuration = {scheme_type: :flat, parent: {generated: {pattern: "NX[identifier]AA", width: "6"}}, child: {generated: {pattern: "YY[identifier]", width: "4"}}}
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).twice.and_return(local_configuration)
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(0)
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(1)
      expect(new_object.errors.full_messages[0]).to eq("An existing record exisits in the database")
    end

    it "prevents a TC being added with invalid identifier" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race",
        identifier: "?",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(1)
      expect(new_object.errors.full_messages[0]).to eq("Identifier contains a part with invalid characters")
    end

    it "prevents a TC being added with invalid data, I" do
      local_configuration = {scheme_type: :flat, parent: {entered: true}, child: {entered: true}} # Need to force manual entry
      expect(Thesaurus::UnmanagedConcept).to receive(:identification_configuration).and_return(local_configuration)
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race!@£$%^&*(){}",
        identifier: "?",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(2)
      expect(new_object.errors.full_messages.to_sentence).to eq("Identifier contains a part with invalid characters and Definition contains invalid characters")
    end

    it "prevents a TC being added with invalid data, II" do
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race!@£$%^&*(){}",
        identifier: "?",
        label: "New",
        notation: "NEWNEW"
      }
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      new_object = tc.add_child(params)
      expect(new_object.errors.count).to eq(1)
      expect(new_object.errors.full_messages.to_sentence).to eq("Definition contains invalid characters")
    end

    it "allows a TC to be saved" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New_ZZZ",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = "New_XXX"
      new_object.notation = "NEWNEWXXX"
      new_object.save
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_1.yaml")
    end

    it "allows a TC to be updated, quotes test" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = "New \"XXX\""
      new_object.save
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_2.yaml")
    end
    
    it "allows a TC to be updated, character test" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        uri: Uri.new(uri: "http://www.assero.co.uk/TC#OWNER-A00004"),
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      new_object.label = vh_all_chars
      new_object.notation = vh_all_chars + "^"
      new_object.definition = vh_all_chars
      new_object.save
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C"))
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_3.yaml")
    end

    it "multiple updates, preferred term and synonyms" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW"
      }
      new_object = tc.add_child(params)
      tc_uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.update(synonym: "Male")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_4.yaml")
      tc.update(synonym: "Male; Female")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_5.yaml")
      tc.update(preferred_term: "PT 1")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_6.yaml")
      tc.update(preferred_term: "PT 2", synonym: "")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_7.yaml")
      tc.update(preferred_term: "", synonym: "Male")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_8.yaml")
      tc.update(synonym: "")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_9.yaml")
    end

    it "multiple updates, preferred term and synonyms, synonym delete" do
      parent = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      params = 
      {
        definition: "Other or mixed race",
        identifier: "A00004",
        label: "New",
        notation: "NEWNEW",
      }
      tc = parent.add_child(params)
      tc_uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011_NC00000999C")
      tc.update(synonym: "Male; Female")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_10.yaml")
      tc.update(synonym: "")
      tc = Thesaurus::UnmanagedConcept.find(tc_uri)
      tc.synonym_objects
      tc.preferred_term_objects
      check_thesaurus_concept_actual_expected(tc.to_h, sub_dir, "update_expected_11.yaml")
    end

  end

  describe "changes and differences" do

    before :all  do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..60)
    end

    after :all do
      delete_all_public_test_files
    end

    it "finds changes count - NEEDS WORK" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      expect(tc.changes_count(4)).to eq(2)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      expect(tc.changes_count(40)).to eq(2)
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      expect(tc.changes_count(4)).to eq(2)
    end

    it "finds changes, 4 - NEEDS WORK" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      results = tc.changes(4)
      check_file_actual_expected(results, sub_dir, "changes_expected_1.yaml")
    end

    it "finds changes, 8 - NEEDS WORK" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      results = tc.changes(8)
      check_file_actual_expected(results, sub_dir, "changes_expected_2.yaml")
    end

    it "finds changes, 4 - NEEDS WORK" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C124661/V46#C124661_C124716"))
      results = tc.changes(4)
      check_file_actual_expected(results, sub_dir, "changes_expected_3.yaml")
    end

    it "finds changes, 4 - NEEDS WORK" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C100129/V55#C100129_C147585"))
      results = tc.changes(4)
      check_file_actual_expected(results, sub_dir, "changes_expected_4.yaml")
    end

    it "differences, I" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_1.yaml")
    end

    it "differences, II" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C124661/V46#C124661_C124716"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_2.yaml")
    end

    it "differences, III" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C100129/V55#C100129_C147585"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_3.yaml")
    end

    it "differences, IV" do
      tc = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C100129/V30#C100129_C100763"))
      results = tc.differences
      check_file_actual_expected(results, sub_dir, "differences_expected_4.yaml")
    end

  end

  describe "synonym and preferred term links" do

    before :all do
      IsoHelpers.clear_cache
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..60)
    end

    after :all do
      delete_all_public_test_files
    end

    it "synonym links, single synonym" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      results = tc.linked_by_synonym({context_id: th.id})
      check_file_actual_expected(results, sub_dir, "synonym_links_expected_1.yaml")
    end

    it "synonym links, empty with no synonym" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C99078/V28#C99078_C307"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      results = tc.linked_by_synonym({context_id: th.id})
      check_file_actual_expected(results, sub_dir, "synonym_links_expected_2.yaml")
    end

    it "synonym links, empty with no synonym" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C65047/V58#C65047_C156534"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"))
      results = tc.linked_by_synonym({context_id: th.id})
      check_file_actual_expected(results, sub_dir, "synonym_links_expected_3.yaml")
    end

    it "synonym links, empty with single synonym, no context" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      results = tc.linked_by_synonym({})
      check_file_actual_expected(results, sub_dir, "synonym_links_expected_4.yaml")
    end

    it "synonym links, empty with no synonym, no context" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C65047/V58#C65047_C156534"))
      results = tc.linked_by_synonym({})
      check_file_actual_expected(results, sub_dir, "synonym_links_expected_5.yaml")
    end

    it "PT link" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      results = tc.linked_by_preferred_term({context_id: th.id})
      check_file_actual_expected(results, sub_dir, "preferred_term_links_expected_1.yaml")
    end

    it "PT link no context" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      results = tc.linked_by_preferred_term({})
      check_file_actual_expected(results, sub_dir, "preferred_term_links_expected_2.yaml")
    end

  end

  describe "cross reference links" do

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..59)
      load_data_file_into_triple_store("cdisc/ct/changes/change_instructions_v47.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "cross reference links I" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C67154/V4#C67154_C61019"))
      results = tc.linked_change_instructions
      check_file_actual_expected(results, sub_dir, "cross_reference_links_expected_1.yaml")
    end

    it "cross reference links II" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C88025/V44#C88025_C27477"))
      results = tc.linked_change_instructions
      check_file_actual_expected(results, sub_dir, "cross_reference_links_expected_2.yaml")
    end

  end

  describe "csv test" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    after :all do
      delete_all_public_test_files
    end

    it "generates a CSV record with no header" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C43820"))
      expected = 
      [ 
        "C43820",false,"MedDRA","MedDRA","MedDRA; Medical Dictionary for Regulatory Activities",
        "MedDRA is an international medical terminology designed to support the classification, retrieval, presentation, and communication of medical information throughout the medical product regulatory cycle. MedDRA was developed under the auspices of the International Conference on Harmonisation of Technical Requirements for Registration of Pharmaceuticals for Human Use (ICH). The MedDRA Maintenance and Support Services Organization (MSSO) holds a contract with the International Federation of Pharmaceutical Manufacturers Associations (IFPMA) to maintain and support the implementation of the terminology. (NCI)",
        "MedDRA"
      ]
      expect(tc.to_csv_data).to eq(expected)
    end

  end

  describe "other tests" do
  
    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_1.ttl", "iso_concept_systems_baseline.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :each do
    end

    it "simple hash" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      check_file_actual_expected(tc.simple_to_h, sub_dir, "simple_to_h_expected.yaml")
    end 

    it "JSON alias" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      check_file_actual_expected(tc.to_json, sub_dir, "simple_to_h_expected.yaml")
    end 

    it "Preferred Term to string" do
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      expect(tc.preferred_term_to_s).to eq("Terminal 5")
      tc.preferred_term = nil
      expect(tc.preferred_term_to_s).to eq("")
    end 

    it "Replace if no change" do
      tc_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C43820"))
      tc_1.synonym_objects
      tc_1.preferred_term_objects
      tc_1_same = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C43820"))
      tc_1_same.synonym_objects
      tc_1_same.preferred_term_objects
      tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C53489"))
      tc_2.synonym_objects
      tc_2.preferred_term_objects
      result = tc_1.replace_if_no_change(tc_1_same)
      expect(result.uri).to eq(tc_1_same.uri)
      result = tc_1.replace_if_no_change(tc_2)
      expect(result.uri).to eq(tc_1.uri)
    end

    it "Add additional tags" do
      tc_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C43820"))
      tc_1.tagged_objects
      tc_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri:"http://www.cdisc.org/C66788/V2#C66788_C53489"))
      tc_2.tagged_objects
      tag_a = IsoConceptSystem::Node.new(pref_label: "SDTM TAG", uri: Uri.new(uri: "http://www.example.com/path#a"))
      set = []
      expect(tc_1.tagged.count).to eq(1)
      expect(tc_2.tagged.count).to eq(1)
      expect(set.count).to eq(0)
      # Add nil
      tc_1.add_additional_tags(nil, set)
      expect(tc_1.tagged.count).to eq(1)
      expect(tc_2.tagged.count).to eq(1)
      expect(set.count).to eq(0)
      # Add tag
      tc_2.tagged << tag_a
      tc_1.add_additional_tags(tc_2, set)
      expect(tc_1.tagged.count).to eq(1)
      expect(tc_2.tagged.count).to eq(2)
      expect(set.count).to eq(1)
      expect(set.first[:subject].to_s).to eq("http://www.cdisc.org/C66788/V2#C66788_C43820")
      expect(set.first[:object].to_s).to eq("http://www.example.com/path#a")
      # Add again
      tc_1.add_additional_tags(tc_2, set)
      expect(tc_1.tagged.count).to eq(1)
      expect(tc_2.tagged.count).to eq(2)
      expect(set.count).to eq(2)
      expect(set.last[:subject].to_s).to eq("http://www.cdisc.org/C66788/V2#C66788_C43820")
      expect(set.last[:object].to_s).to eq("http://www.example.com/path#a")
    end

  end

end