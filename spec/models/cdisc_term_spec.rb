require 'rails_helper'

describe CdiscTerm do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/cdisc_term"
  end

  def check_term_differences(results, expected)
    expect(results[:status]).to eq(expected[:status])
    expect(results[:result]).to eq(expected[:result])
    expect(results[:children].count).to eq(expected[:children].count)
    results[:children].each do |key, result|
      found = expected[:children][key]
      expect(result).to eq(found)
    end
  end

  def load_versions(range)
    range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
  end

  describe "CDISC Terminology General" do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V35.ttl")
      load_test_file_into_triple_store("CT_V34.ttl")
      load_test_file_into_triple_store("CT_V36.ttl")
      load_test_file_into_triple_store("CT_V47.ttl")
      load_test_file_into_triple_store("CT_V48.ttl")
      load_test_file_into_triple_store("CT_V49_X.ttl")
    end

    it "allows an object to be initialised" do
      th = CdiscTerm.new
      result =     
        { 
          :type => "http://www.assero.co.uk/ISO25964#Thesaurus",
          :id => "", 
          :namespace => "", 
          :label => "",
          :extension_properties => [],
          :origin => "",
          :change_description => "",
          #:creation_date => Time.now,
          #:last_changed_date => Time.now,
          :explanatory_comment => "",
          :registration_state => IsoRegistrationState.new.to_json,
          :scoped_identifier => IsoScopedIdentifier.new.to_json,
          :children => []
        }
      result[:creation_date] = date_check_now(th.creationDate).iso8601
      result[:last_changed_date] = date_check_now(th.lastChangeDate).iso8601
      expect(th.to_json).to eq(result)
    end

    it "returns the owner" do
      expected =IsoRegistrationAuthority.find_by_short_name("CDISC")
      ra = CdiscTerm.owner
      expect(ra.uri).to eq(expected.uri)
    end    

    it "returns the configuration" do
      expected = {identifier: "CDISC Terminology"}
      expect(CdiscTerm.configuration).to eq(expected)
      th = CdiscTerm.new
      expect(th.configuration).to eq(expected)
    end    

    it "allows validity of the object to be checked - error" do
      result = CdiscTerm.new
      valid = result.valid?
      expect(valid).to eq(false)
      expect(result.errors.count).to eq(4)
      expect(result.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Uri can't be blank")
      expect(result.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Organization identifier is invalid")
      expect(result.errors.full_messages[2]).to eq("Registration State error: Registration authority error: Ra namespace: Empty object")
      expect(result.errors.full_messages[3]).to eq("Scoped Identifier error: Identifier contains invalid characters")
    end 

    it "allows validity of the object to be checked" do
      th =CdiscTerm.new
      ra = IsoRegistrationAuthority.new
      ra.uri = "na" # Bit naughty
      ra.organization_identifier = "123456789"
      ra.international_code_designator = "DUNS"
      ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
      th.registrationState.registrationAuthority = ra
      th.scopedIdentifier.identifier = "hello"
      valid = th.valid?
      expect(th.errors.count).to eq(0)
      expect(valid).to eq(true)
    end 

    it "allows validity of the object to be checked, version" do
      th =CdiscTerm.new
      ra = IsoRegistrationAuthority.new
      ra.uri = "na" # Bit naughty
      ra.organization_identifier = "123456789"
      ra.international_code_designator = "DUNS"
      ra.ra_namespace = IsoNamespace.find(Uri.new(uri:"http://www.assero.co.uk/NS#ACME"))
      th.registrationState.registrationAuthority = ra
      th.scopedIdentifier.identifier = "hello"
      th.scopedIdentifier.version = "hello"
      valid = th.valid?
      expect(valid).to eq(false)
      expect(th.errors.count).to eq(1)
      expect(th.errors.full_messages[0]).to eq("Scoped Identifier error: Version contains invalid characters, must be an integer")
    end 

    it "allows a CDISC Term to be found" do
      th =CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #Xwrite_yaml_file(th.to_json, sub_dir, "find_expected_1.yaml")
      result_th = read_yaml_file(sub_dir, "find_expected_1.yaml")
      expect(th.to_json).to eq(result_th)
    end

    it "allows a CDISC Term to be found - error" do
      th =CdiscTerm.find("TH-CDISC_CDISCTerminologyX", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
      expect(th.identifier).to eq("")    
    end

    it "Find only the root object" do
      th =CdiscTerm.find_only("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #Xwrite_yaml_file(th.to_json, sub_dir, "find_only_expected_1.yaml")
      result_th = read_yaml_file(sub_dir, "find_only_expected_1.yaml")
      expect(th.to_json).to eq(result_th)
    end

    it "Find the CL with a submission value" do
      th =CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
      cl = th.find_submission("SKINTYP")
    #Xwrite_yaml_file(cl.to_json, sub_dir, "find_submission_expected_1.yaml")
      result_cl = read_yaml_file(sub_dir, "find_submission_expected_1.yaml")
      expect(cl.to_json).to eq(result_cl)
    end

    it "Find the CL with a submission value, not found" do
      th =CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
      cl = th.find_submission("SKINTYPx")
      expect(cl).to eq(nil)
    end

    it "finds all items" do
      results = CdiscTerm.all
      results_json = results.map { |result| result = result.to_json }
    #Xwrite_yaml_file(results_json, sub_dir, "all_expected_1.yaml")
      results_ct = read_yaml_file(sub_dir, "all_expected_1.yaml")
      expect(results_json).to eq(results_ct)
    end

    it "finds history of an item entries" do
      results = []
      results [0] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 49}
      results [1] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 48}
      results [2] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 47}
      results [3] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 36}
      results [4] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 35}
      results [5] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 34}
      items = CdiscTerm.history
      items.each_with_index do |item, index|
        expect(results[index][:id]).to eq(items[index].id)
        expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
      end
    end
    
    it "finds all except" do
      results = CdiscTerm.all_except(34)
      results_json = results.map { |result| result = result.to_json }
    #Xwrite_yaml_file(results_json, sub_dir, "all_except_expected_1.yaml")
      results_ct = read_yaml_file(sub_dir, "all_except_expected_1.yaml")
      expect(results_json).to eq(results_ct)
    end

    it "find all previous" do
      results = CdiscTerm.all_previous(36)
      results_json = results.map { |result| result = result.to_json }
    #Xwrite_yaml_file(results_json, sub_dir, "all_previous_expected_1.yaml")
      results_ct = read_yaml_file(sub_dir, "all_previous_expected_1.yaml")
      expect(results_json).to eq(results_ct)
    end

    it "allows the current version to be found" do
      th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
      expect(th.current?).to eq(false)   
      expect(th.can_be_current?).to eq(true)
      IsoRegistrationState.make_current(th.registrationState.id)
      current_th = CdiscTerm.current
      expect(current_th.version).to eq(th.version)
    end

    it "prevents a new version to be created (imported) if version is in error"  do
      result = CdiscTerm.create({:date => "2016-12-12", :version => "12a", :files => ["xxx.ttl"]})
      expect(result[:object].errors.count).to eq(1)
      expect(result[:object].errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")    
    end

    it "prevents a new version to be created (imported) if date is in error, 1"  do
      result = CdiscTerm.create({:date => "2016x-12-12", :version => "12", :files => ["xxx.ttl"]})
      expect(result[:object].errors.count).to eq(1)
      expect(result[:object].errors.full_messages.to_sentence).to eq("Date contains invalid characters")    
    end

    it "prevents a new version to be created (imported) if date is in error, 2"  do
      result = CdiscTerm.create({:date => "2016/12/12", :version => "12", :files => ["xxx.ttl"]})
      expect(result[:object].errors.count).to eq(1)
      expect(result[:object].errors.full_messages.to_sentence).to eq("Date contains invalid characters")    
    end

    it "prevents a new version to be created (imported) if files are missing 1"  do
      result = CdiscTerm.create({:date => "2016-12-12", :version => "12", :files => []})
      expect(result[:object].errors.count).to eq(1)
      expect(result[:object].errors.full_messages.to_sentence).to eq("Files is empty, at least one file is required")    
    end

    it "prevents a new version to be created (imported) if files are missing 2"  do
      result = CdiscTerm.create({:date => "2016-12-12", :version => "12"})
      expect(result[:object].errors.count).to eq(1)
      expect(result[:object].errors.full_messages.to_sentence).to eq("Files is empty, at least one file is required")    
    end

    it "initiates the CDISC Terminology changes background job" do
      result = CdiscTerm.changes
      expect(result[:object].errors.count).to eq(0)
    end

    it "initiates the CDISC Terminology compare background job" do
      old_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
      new_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
      result = CdiscTerm.compare(old_ct, new_ct)
      expect(result[:object].errors.count).to eq(0)
    end

    it "initiates the CDISC Submission Changes background job" do
      result = CdiscTerm.submission_changes
      expect(result[:object].errors.count).to eq(0)
    end
    
    it "determines changes in submission values, 1" do
      old_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
      new_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
      results = CdiscTerm.submission_difference(old_ct, new_ct)
    #write_yaml_file(results, sub_dir, "submission_difference_expected_1.yaml")
      expected = read_yaml_file(sub_dir, "submission_difference_expected_1.yaml")
      results.each do |key, result|
        found = expected[key]
        expect(result.to_json).to eq(found.to_json)
      end
    end

    it "determines changes in submission values, 2" do
      old_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
      new_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
      results = CdiscTerm.submission_difference(old_ct, new_ct)
    #Xwrite_yaml_file(results, sub_dir, "submission_difference_expected_2.yaml")
      expected = read_yaml_file(sub_dir, "submission_difference_expected_2.yaml")
      results.each do |key, result|
        found = expected[key]
        expect(result.to_json).to eq(found.to_json)
      end
    end

    it "determines the difference between two items, 1" do
      term1 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
      term2 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
      results = CdiscTerm.difference(term1, term2)
    #Xwrite_yaml_file(results, sub_dir, "difference_expected_1.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_1.yaml")
      check_term_differences(results, expected)
    end

    it "determines the difference between two items, 2" do
      term1 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V47")
      term2 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
      results = CdiscTerm.difference(term1, term2)
    #Xwrite_yaml_file(results, sub_dir, "difference_expected_2.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_2.yaml")
      check_term_differences(results, expected)
    end

    it "determines the difference between two items, 3" do
    	# Special file to check for creation, deletion and 
      term1 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48")
      term2 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
      results = CdiscTerm.difference(term1, term2)
    #Xwrite_yaml_file(results, sub_dir, "difference_expected_3.yaml")
      expected = read_yaml_file(sub_dir, "difference_expected_3.yaml")
      check_term_differences(results, expected)
    end

    it "self.next(offset, limit, ns)"

    it "checks params, missing files" do
    	object = CdiscTerm.new
    	params = { version: "48", date: "2017-06-05"}
    	result = CdiscTerm.params_valid?(object, params)
    	expect(result).to eq(false)
    	expect(object.errors.full_messages.to_sentence).to eq("Files is empty, at least one file is required")    
    end

    it "checks params, missing version" do
    	object = CdiscTerm.new
    	params = { date: "2017-06-05", files: ["file1", "file2"]}
    	result = CdiscTerm.params_valid?(object, params)
    	expect(result).to eq(false)
    	expect(object.errors.full_messages.to_sentence).to eq("Version is empty")    
    end

    it "checks params, missing date" do
    	object = CdiscTerm.new
    	params = { version: "48", files: ["file1", "file2"]}
    	result = CdiscTerm.params_valid?(object, params)
    	expect(result).to eq(false)
    	expect(object.errors.full_messages.to_sentence).to eq("Date is empty")    
    end

    it "checks params, invalid version" do
    	object = CdiscTerm.new
    	params = { version: "48£££", date: "2017-06-05", files: ["file1", "file2"]}
    	result = CdiscTerm.params_valid?(object, params)
    	expect(result).to eq(false)
    	expect(object.errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")       
    end

    it "checks params, invalid date" do
    	object = CdiscTerm.new
    	params = { version: "48", date: "ABC", files: ["file1", "file2"]}
    	result = CdiscTerm.params_valid?(object, params)
    	expect(result).to eq(false)
    	expect(object.errors.full_messages.to_sentence).to eq("Date contains invalid characters")    
    end

    it "checks params, all good" do
    	object = CdiscTerm.new
    	params = { version: "48", date: "2017-06-05", files: ["file1", "file2"]}
    	result = CdiscTerm.params_valid?(object, params)
    #puts object.errors.full_messages.to_sentence
    	expect(result).to eq(true)
    	expect(object.errors.count).to eq(0)    
    end

    it "initiates the cross reference background job" do
      load_test_file_into_triple_store("CT_V44.ttl")
    	delete_public_file("text", "create_cross_reference_1.xlsx")
      copy_file_to_public_files(sub_dir, "create_cross_reference_1.xlsx", "test")
      filename = public_path("test", "create_cross_reference_1.xlsx")
      params = { uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V44#TH-CDISC_CDISCTerminology", 
      	version: "44", files: ["#{filename}"] }
      ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V44")
      result = ct.create_cross_reference(params)
      expect(result[:object].errors.count).to eq(0)
      expect(result[:job]).to be_a Background
      public_file_exists?("test", "CDISC_CT_Instructions_V44.txt")
      delete_public_file("test", "CDISC_CT_Instructions_V44.txt")
      delete_public_file("test", "create_cross_reference_1.xlsx")
    end

    it "allows a terminology to be built from json" do
      th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #Xwrite_yaml_file(th.to_json, sub_dir, "from_json_input_1.yaml")
      input = read_yaml_file(sub_dir, "from_json_input_1.yaml")
      expected = input
      result = CdiscTerm.from_json(input)
      expect(result.to_json).to eq(expected)
    end

  end

  describe "CDISC History" do

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
      load_versions(1..13)
    end

    after :each do
      #
    end

    it "history" do
      ct = CdiscTerm.history(identifier: "CT", scope: CdiscTerm.owner)
    end

  end

  describe "CDISC Terminology Changes" do

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
      load_versions(1..13)
    end

    after :each do
      #
    end

    it "calculates changes, window 4, general" do
      ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V10#TH"), false)
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_1.yaml")
    end

    it "calculates changes, window 10, large" do
      ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"), false)
      actual = ct.changes(10)
      check_file_actual_expected(actual, sub_dir, "changes_expected_2.yaml") 
    end

    it "calculates changes, window 4, first item" do
      ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"), false)
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_3.yaml")
    end

    it "calculates changes, window 4, second" do
      ct = CdiscTerm.find(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"), false)
      actual = ct.changes(4)
      check_file_actual_expected(actual, sub_dir, "changes_expected_4.yaml")
    end

  end

end