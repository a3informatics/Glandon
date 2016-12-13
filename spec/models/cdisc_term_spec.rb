require 'rails_helper'

describe CdiscTerm do

  include DataHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V34.ttl")
    load_test_file_into_triple_store("CT_V35.ttl")
    load_test_file_into_triple_store("CT_V36.ttl")
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

  it "allows validity of the object to be checked - error" do
    th = CdiscTerm.new
    valid = th.valid?
    expect(valid).to eq(false)
    expect(th.errors.count).to eq(3)
    expect(th.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Namespace error: Short name contains invalid characters")
    expect(th.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Number does not contains 9 digits")
    expect(th.errors.full_messages[2]).to eq("Scoped Identifier error: Identifier contains invalid characters")
  end 

  it "allows validity of the object to be checked" do
    th =CdiscTerm.new
    th.registrationState.registrationAuthority.namespace.shortName = "AAA"
    th.registrationState.registrationAuthority.namespace.name = "USER AAA"
    th.registrationState.registrationAuthority.number = "123456789"
    th.scopedIdentifier.identifier = "hello"
    valid = th.valid?
    expect(th.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

  it "allows a CDISC Term to be found" do
    th =CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #write_hash_to_yaml_file(th.to_json, "cdisc_term_example_1.yaml")
    result_th = read_yaml_file_to_hash("cdisc_term_example_1.yaml")
    expect(th.to_json).to eq(result_th)
  end

  it "allows a CDISC Term to be found - error" do
    th =CdiscTerm.find("TH-CDISC_CDISCTerminologyX", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    expect(th.identifier).to eq("")    
  end

  it "Find only the root object" do
    th =CdiscTerm.find_only("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    #write_hash_to_yaml_file(th.to_json, "cdisc_term_example_2.yaml")
    result_th = read_yaml_file_to_hash("cdisc_term_example_2.yaml")
    expect(th.to_json).to eq(result_th)
  end

  it "Find the CL with a submission value" do
    th =CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    cl = th.find_submission("SKINTYP")
    #write_hash_to_yaml_file(cl.to_json, "cdisc_term_example_3.yaml")
    result_cl = read_yaml_file_to_hash("cdisc_term_example_3.yaml")
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
    #write_hash_to_yaml_file(results_json, "cdisc_term_example_4.yaml")
    results_ct = read_yaml_file_to_hash("cdisc_term_example_4.yaml")
    expect(results_json).to eq(results_ct)
  end

  it "finds history of an item entries" do
    results = []
    results [0] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 36}
    results [1] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 35}
    results [2] = {id: "TH-CDISC_CDISCTerminology", scoped_identifier_version: 34}
    items = CdiscTerm.history
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end
  end
  
  it "finds all except" do
    results = CdiscTerm.all_except(34)
    results_json = results.map { |result| result = result.to_json }
    #write_hash_to_yaml_file(results_json, "cdisc_term_example_5.yaml")
    results_ct = read_yaml_file_to_hash("cdisc_term_example_5.yaml")
    expect(results_json).to eq(results_ct)
  end

  it "find all previous" do
    results = CdiscTerm.all_previous(36)
    results_json = results.map { |result| result = result.to_json }
    #write_hash_to_yaml_file(results_json, "cdisc_term_example_6.yaml")
    results_ct = read_yaml_file_to_hash("cdisc_term_example_6.yaml")
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

  it "allows a new version to be created (imported)"

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

  it "determines changes in submission values" do
    old_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    new_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    results = CdiscTerm.submission_difference(old_ct, new_ct)
    #write_hash_to_yaml_file(results, "cdisc_term_submission_difference.yaml")
    expected = read_yaml_file_to_hash("cdisc_term_submission_difference.yaml")
    expect(results.to_json).to eq(expected.to_json)
  end

  it "determines impact of changes in submission values" do
    old_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    new_ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    results = CdiscTerm.submission_difference(old_ct, new_ct)
    #write_hash_to_yaml_file(results, "cdisc_term_submission_impact.yaml")
    expected = read_yaml_file_to_hash("cdisc_term_submission_impact.yaml")
    expect(results.to_json).to eq(expected.to_json)
  end
  
  it "determines the difference between two items" do
    term1 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    term2 = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    results = CdiscTerm.difference(term1, term2)
    #write_hash_to_yaml_file(results, "cdisc_term_example_difference.yaml")
    expected = read_yaml_file_to_hash("cdisc_term_example_difference.yaml")
    expect(results).to eq(expected)
  end

  it "self.next(offset, limit, ns)"

end