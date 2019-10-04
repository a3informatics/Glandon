require 'rails_helper'

describe Thesaurus do

  include DataHelpers
  include SparqlHelpers
  include TimeHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/thesaurus"
  end

  describe "Main Tests" do

    before :all do
      IsoHelpers.clear_cache
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"    
      ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..50)
    end

    after :all do
      delete_all_public_test_files
    end

    it "returns the owner" do
      expected = IsoRegistrationAuthority.owner
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(th.owner.uri).to eq(expected.uri)
    end    

    it "allows an object to be initialised" do
      th =Thesaurus.new
      result =     
        { 
          :rdf_type => "http://www.assero.co.uk/Thesaurus#Thesaurus",
          :id => nil,
          :uri => {},
          :label => "",
          :origin => "",
          :change_description => "",
          :creation_date => "".to_time_with_default.iso8601.to_s,
          :last_change_date => "".to_time_with_default.iso8601.to_s,
          :explanatory_comment => "",
          :has_state => nil,
          :has_identifier => nil,
          :is_top_concept => [],
          :is_top_concept_reference => []
        }
      expect(th.to_h).to hash_equal(result)
    end

    it "allows validity of the object to be checked - error" do
      result = Thesaurus.new
      valid = result.valid?
      expect(valid).to eq(false)
      expect(result.errors.count).to eq(3)
      expect(result.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier: Empty object, and Has state: Empty object")
    end 

    it "allows validity of the object to be checked" do
      th = Thesaurus.new
      ra = IsoRegistrationAuthority.new
      ra.uri = "na" # Bit naughty
      ra.organization_identifier = "123456789"
      ra.international_code_designator = "DUNS"
      ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
      th.has_state = IsoRegistrationStateV2.new
      th.has_state.uri = "na"
      th.has_state.by_authority = ra
      th.has_identifier = IsoScopedIdentifierV2.new
      th.has_identifier.uri = "na"
      th.has_identifier.identifier = "HELLO WORLD"
      th.has_identifier.semantic_version = "0.1.0"
      th.uri = "xxx"
      valid = th.valid?
      expect(th.errors.count).to eq(0)
      expect(valid).to eq(true)
    end 

    it "allows a Thesaurus to be found" do
      th = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      check_file_actual_expected(th.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows a Th to be found - error" do
      expect{Thesaurus.find(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#X"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRThesaurus/ACME/V1#X in Thesaurus.")
    end

    # it "allows the thesaurus to be found from a concept" do
    #   th =Thesaurus.find_from_concept("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   check_file_actual_expected(th.to_h, sub_dir, "find_expected_2.yaml", equate_method: :hash_equal, write_method: true)  
    # end

    # it "finds by properties, single" do
    #   th =Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   expected = ThesaurusConcept.find("THC-A00002", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   results = th.find_by_property({identifier: "A00002"})
    #   expect(results[0].to_json).to eq(expected.to_json)
    # end

    # it "finds by properties, multiple" do
    #   th =Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   expected = ThesaurusConcept.find("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   results = th.find_by_property({notation: "ETHNIC SUBGROUP [1]", preferredTerm: "Ethnic Subgroup 1"})
    #   expect(results[0].to_json).to eq(expected.to_json)
    # end

    # it "allows all records to be retrieved" do
    #   results = Thesaurus.all
    #   expect(results.count).to eq(5) # Another added for new test
    # #Xwrite_yaml_file(results, sub_dir, "thesaurus_all_1.yaml")
    #   expected = read_yaml_file(sub_dir, "thesaurus_all_1.yaml")
    #   results.each do |result|
    #     found = expected.find { |x| x.id == result.id }
    #     expect(result.id).to eq(found.id)
    #   end
    # end

    # it "allows the list to be retrieved" do
    #   result = Thesaurus.list
    #   expect(result.count).to eq(5) # Another added for new test
    #   expect(result[4].identifier).to eq("CDISC EXT")
    #   expect(result[4].id).to eq("TH-SPONSOR_CT-1")
    #   expect(result[4].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    #   expect(result[3].identifier).to eq("CDISC Terminology")
    #   expect(result[3].id).to eq("TH-CDISC_CDISCTerminology")
    #   expect(result[3].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #   expect(result[2].identifier).to eq("CDISC Terminology")
    #   expect(result[2].id).to eq("TH-CDISC_CDISCTerminology")
    #   expect(result[2].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    #   expect(result[1].identifier).to eq("CDISC Terminology")
    #   expect(result[1].id).to eq("TH-CDISC_CDISCTerminology")
    #   expect(result[1].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    #   expect(result[0].identifier).to eq("CDISC Terminology")
    #   expect(result[0].id).to eq("TH-CDISC_CDISCTerminology")
    #   expect(result[0].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
    # end

    it "allows the unique item to be retrived" do
      result = Thesaurus.unique
      check_file_actual_expected(result, sub_dir, "unique_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows the history to be retrived" do
      results = []
      result = Thesaurus.history(:identifier => "CT", :scope => IsoNamespace.find_by_short_name("CDISC"))
      result.each {|x| results << x.to_h}
      check_file_actual_expected(results, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows the current item to be retrived" do
      owner = IsoRegistrationAuthority.owner
      result = Thesaurus.current({:identifier => "CDISC EXT", :scope => IsoRegistrationAuthority.owner.ra_namespace})
      expect(result.to_s).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1")
    end
    
    it "allows a creation of a thesaurus" do
      th = Thesaurus.create({:identifier => "TEST", :label => "Test Thesaurus"})
    #Xwrite_yaml_file(th.to_h, sub_dir, "thesaurus_example_4.yaml")
      expected = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_4.yaml")
      expected[:creation_date] = date_check_now(th.creation_date).iso8601
      expected[:last_change_date] = date_check_now(th.last_change_date).iso8601
      expect(th.errors.count).to eq(0)
      expect(th.to_h).to eq(expected)
    end

    it "allows for a thesaurus to be destroyed" do
      th = Thesaurus.create({:identifier => "TEST1", :label => "Test Thesaurus 1"})
      expect(Thesaurus.find_minimum(th.id).uri.to_s).to eq("http://www.acme-pharma.com/TEST1/V1#TH")
      th.delete
      expect{Thesaurus.find_minimum(th.id)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.acme-pharma.com/TEST1/V1#TH in Thesaurus.")
    end

    it "allows the thesaurus to be exported as SPARQL" do
      th = Thesaurus.find(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      sparql = Sparql::Update.new
      th.to_sparql(sparql, true)
    #write_text_file_2(sparql.to_create_sparql, sub_dir, "to_sparql_expected_1.txt")
      check_sparql_no_file(sparql.to_create_sparql, "to_sparql_expected_1.txt") 
    end

    it "allows the impact to be assessed - WILL CURRENTLY FAIL" do
    	th = Thesaurus.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
    	result = th.impact
    #Xwrite_yaml_file(result, sub_dir, "thesaurus_impact.yaml")
      expected = read_yaml_file(sub_dir, "thesaurus_impact.yaml")
      expect(result).to eq(expected)
    end

  end

  describe "Terminology Changes" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
      ]
      load_files(schema_files, data_files)
      load_versions(1..59)
    end

    after :each do
      #
    end

    it "calculates changes, window 4, general" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_1.yaml")
    end

    it "calculates changes, window 10, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      actual = ct.changes(10)
      check_file_actual_expected(actual, sub_dir, "changes_expected_2.yaml") 
    end

    it "calculates changes, window 4, first item" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_3.yaml")
    end

    it "calculates changes, window 4, second" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_4.yaml")
    end

    it "calculates changes_cdu, window 3 " do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      actual = ct.changes_cdu(3)
      check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_1.yaml")
    end

    it "calculates changes_cdu, window 3 " do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V7#TH"))
      actual = ct.changes_cdu(3)
      check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_2.yaml")
    end

    it "calculates changes_cdu, window 4 " do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V13#TH"))
      actual = ct.changes_cdu(4)
      check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_3.yaml")
    end

    it "calculates changes_cdu, window 4 " do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V55#TH"))
      actual = ct.changes_cdu(4)
      check_file_actual_expected(actual, sub_dir, "changes_cdu_expected_4.yaml")
    end

  end

  describe "Terminology Submission Changes" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all  do
      IsoHelpers.clear_cache
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
      ]
      load_files(schema_files, data_files)
      load_versions(1..59)
    end

    after :all do
      #
    end

    it "calculates changes, window 4, general" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V10, 4 versions")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_1.yaml")
    end

    it "calculates changes, window 10, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      timer_start
      actual = ct.submission(10)
      timer_stop("V2, 10 versions")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_2.yaml")
    end

    it "calculates changes, window 4, first item" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V1, 4 versions")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_3.yaml")
    end

    it "calculates changes, window 4, second" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      timer_start
      actual = ct.submission(4)
      timer_stop("V2, 4 versions")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_4.yaml")
    end

    it "calculates changes, window 12, large" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V30#TH"))
      timer_start
      actual = ct.submission(12)
      timer_stop("V30, 12 versions")
      check_file_actual_expected(actual, sub_dir, "submisson_expected_5.yaml")
    end

  end

  describe "Child Operations" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl", "thesaurus_new_airports.ttl"      
      ]
      load_files(schema_files, data_files)
      load_versions(1..59)
    end

    after :each do
      #
    end

    it "get children" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      actual = ct.managed_children_pagination(offset: 0, count: 10)
      check_file_actual_expected(actual, sub_dir, "managed_child_pagination_expected_1.yaml")
    end

    it "get children, speed" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      timer_start
      (1..100).each {|x| actual = ct.managed_children_pagination(offset: 0, count: 10)}
      timer_stop("100 searches")
    end

    it "add child, manual entry" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(false)
      ct.add_child(identifier: "S123")
      actual = ct.managed_children_pagination(count: 100, offset: 0) 
      check_file_actual_expected(actual, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S123/V1#S123"))
      actual = item.to_h
    #Xwrite_yaml_file(item.to_h, sub_dir, "add_child_expected_2.yaml")
      expected = read_yaml_file(sub_dir, "add_child_expected_2.yaml")
      expect(actual[:preferred_term][:label]).to eq(expected[:preferred_term][:label])
      expected[:preferred_term] = actual[:preferred_term] # Cannot predict URI for the created PT Not_Set
      expected[:creation_date] = date_check_now(item.creation_date).iso8601
      expected[:last_change_date] = date_check_now(item.last_change_date).iso8601
      expect(actual).to hash_equal(expected)
    end

    it "add child, generated identifier" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("S12345X")
      ct.add_child(identifier: "S123")
      actual = ct.managed_children_pagination(count: 100, offset: 0) 
      check_file_actual_expected(actual, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
      item = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/S12345X/V1#S12345X")) 
      actual = item.to_h
    #Xwrite_yaml_file(actual.to_h, sub_dir, "add_child_expected_4.yaml")
      expected = read_yaml_file(sub_dir, "add_child_expected_4.yaml")
      expect(actual[:preferred_term][:label]).to eq(expected[:preferred_term][:label])
      expected[:preferred_term] = actual[:preferred_term] # Cannot predict URI for the created PT Not_Set
      expected[:creation_date] = date_check_now(item.creation_date).iso8601
      expected[:last_change_date] = date_check_now(item.last_change_date).iso8601
      expect(actual).to hash_equal(expected)
    end

    it "allows a child TC to be added - error, invalid identifier" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(false)
      item = ct.add_child(identifier: "S123£%^@")
      expect(item.errors.count).to eq(2)
      expect(item.errors.full_messages.to_sentence).to eq("Has identifier: Identifier contains invalid characters and Identifier contains a part with invalid characters")
      actual = ct.managed_children_pagination(count: 100, offset: 0) 
      check_file_actual_expected(actual, sub_dir, "add_child_expected_5.yaml", equate_method: :hash_equal)
    end

    it "add extension" do
      uri1 = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      ct = Thesaurus.find_minimum(uri1)
      ct1 = Thesaurus.find_full(uri1)
      ct.is_top_concept_reference_objects
      expect(ct.is_top_concept_reference.count).to eq(2)
      uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V32#C96779")
      item = ct.add_extension(uri2.to_id)
      result = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/C96779E/V1#C96779E")) 
      source = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C96779/V32#C96779")) 
      expect(result.narrower.count).to eq(source.narrower.count)
      expect(result.extends.uri.to_s).to eq(source.uri.to_s)
      item = Thesaurus.find_full(uri1)
      item.is_top_concept_objects
      expect(item.is_top_concept_reference.last.reference.to_s).to eq(result.uri.to_s)
      expect(item.is_top_concept_reference.count).to eq(3)
      actual = item.to_h
      check_file_actual_expected(actual.to_h, sub_dir, "add_extension_expected_1.yaml", equate_method: :hash_equal)
    end

  end

    describe "Complex Finds" do

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :all do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"    
      ]
      load_files(schema_files, data_files)
      load_versions(1..59)
    end

    after :all do
      #
    end

    it "find by identifiers" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      actual = ct.find_by_identifiers(["C106655", "C161764"])
      check_file_actual_expected(actual, sub_dir, "find_by_identifier_1.yaml")
    end

    it "find by identifiers" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"))
      actual = ct.find_by_identifiers(["C106655"])
      check_file_actual_expected(actual, sub_dir, "find_by_identifier_2.yaml")
    end

  end


end