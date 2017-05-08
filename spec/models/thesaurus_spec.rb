require 'rails_helper'

describe Thesaurus do

  include DataHelpers

  def sub_dir
    return "models"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("thesaurus.ttl")
    load_test_file_into_triple_store("CT_V34.ttl")
    load_test_file_into_triple_store("CT_V35.ttl")
    load_test_file_into_triple_store("CT_V36.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows an object to be initialised" do
    th =Thesaurus.new
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
    th = Thesaurus.new
    valid = th.valid?
    expect(valid).to eq(false)
    expect(th.errors.count).to eq(3)
    expect(th.errors.full_messages[0]).to eq("Registration State error: Registration authority error: Namespace error: Short name contains invalid characters")
    expect(th.errors.full_messages[1]).to eq("Registration State error: Registration authority error: Number does not contains 9 digits")
    expect(th.errors.full_messages[2]).to eq("Scoped Identifier error: Identifier contains invalid characters")
  end 

  it "allows validity of the object to be checked" do
    th =Thesaurus.new
    th.registrationState.registrationAuthority.namespace.shortName = "AAA"
    th.registrationState.registrationAuthority.namespace.name = "USER AAA"
    th.registrationState.registrationAuthority.number = "123456789"
    th.scopedIdentifier.identifier = "HELLO WORLD"
    valid = th.valid?
    expect(th.errors.count).to eq(0)
    expect(valid).to eq(true)
  end 

  it "allows a Thesaurus to be found" do
    th =Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    result_th = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_1.yaml")
    expect(th.to_json).to eq(result_th)
  end

  it "allows a Th to be found - error" do
    th =Thesaurus.find("THC-A00001x", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(th.identifier).to eq("")    
  end

  it "allows the complete Th to be found" do
    th =Thesaurus.find_complete("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
  write_yaml_file(th.to_json, sub_dir, "thesaurus_example_2.yaml")
  	expected = read_yaml_file(sub_dir, "thesaurus_example_2.yaml")
    expect(th.to_json).to be_eql(expected)    
  end

  it "allows the thesaurus to be found from a concept" do
    result_th = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_3.yaml")
    th =Thesaurus.find_from_concept("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(th.to_json).to eq(result_th)
  end

  it "allows all records to be retrieved" do
    results = Thesaurus.all
    expect(results.count).to eq(4)
    write_yaml_file(results, sub_dir, "thesaurus_all_1.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_all_1.yaml")
    results.each do |result|
      found = expected.find { |x| x.id == result.id }
      expect(result.id).to eq(found.id)
    end
  end

  it "allows the list to be retrieved" do
    result = Thesaurus.list
    expect(result.count).to eq(4)
    expect(result[3].identifier).to eq("CDISC EXT")
    expect(result[3].id).to eq("TH-SPONSOR_CT-1")
    expect(result[3].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(result[2].identifier).to eq("CDISC Terminology")
    expect(result[2].id).to eq("TH-CDISC_CDISCTerminology")
    expect(result[2].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V34")
    expect(result[1].identifier).to eq("CDISC Terminology")
    expect(result[1].id).to eq("TH-CDISC_CDISCTerminology")
    expect(result[1].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    expect(result[0].identifier).to eq("CDISC Terminology")
    expect(result[0].id).to eq("TH-CDISC_CDISCTerminology")
    expect(result[0].namespace).to eq("http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
  end

  it "allows the unique item to be retrived" do
    result = Thesaurus.unique
    expect(result.count).to eq(2)
    expect(result[1][:identifier]).to eq("CDISC EXT")
    expect(result[0][:identifier]).to eq("CDISC Terminology")
    expect(result[1][:owner]).to eq("ACME")
    expect(result[0][:owner]).to eq("CDISC")
  end

  it "allows the history to be retrived" do
    owner = IsoRegistrationAuthority.owner
    result = Thesaurus.history({:identifier => "CDISC EXT", :scope_id => owner.namespace.id})
    expect(result.count).to eq(1)
  end

  it "allows the current item to be retrived" do
    owner = IsoRegistrationAuthority.owner
    result = Thesaurus.current({:identifier => "CDISC EXT", :scope_id => owner.namespace.id})
    expect(result.identifier).to eq("CDISC EXT")
    expect(result.id).to eq("TH-SPONSOR_CT-1")
    expect(result.namespace).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V1")
  end
  
  it "allows a simple creation of a thesaurus" do
    result_th = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_4.yaml")
    th = Thesaurus.create_simple({:identifier => "TEST", :label => "Test Thesaurus"})
    result_th[:creation_date] = date_check_now(th.creationDate).iso8601
    result_th[:last_changed_date] = date_check_now(th.lastChangeDate).iso8601
    expect(th.errors.count).to eq(0)
    expect(th.to_json).to eq(result_th)
  end

  it "allows for the creation of a thesaurus" do
    th_result = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_6.yaml")
    operation = read_yaml_file_to_hash_2(sub_dir, "thesaurus_example_5.yaml")
    th = Thesaurus.create(operation)
    th_result[:creation_date] = operation[:managed_item][:creation_date]
    th_result[:last_changed_date] = date_check_now(th.lastChangeDate).iso8601
    expect(th.errors.count).to eq(0)
    expect(th.to_json).to eq(th_result)
  end

  it "allows for a thesaurus to be destroyed" do
    th = Thesaurus.find("TH-ACME_NEW", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(th.exists?).to eq(true)
    th.destroy
    expect(th.exists?).to eq(false)
  end

  it "allows the Th to be exported as SPARQL" do
    th =Thesaurus.find_complete("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    sparql = th.to_sparql_v2
    result_sparql = read_text_file_2(sub_dir, "thesaurus_example_7.txt")
    expect(sparql.to_s).to be_eql(result_sparql)
  end

  it "allows a child TC to be added" do
    child =
    {
      :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
      :id => "",
      :namespace => "",
      :parentIdentifier => "",
      :identifier => "A0001",
      :label => "Label",
      :notation => "SV",
      :preferredTerm => "PT",
      :synonym => "Syn",
      :definition => "Def"
    }
    th = Thesaurus.create_simple({:identifier => "TEST", :label => "Test Thesaurus"})
    expect(th.children.count).to eq(0)
    tc = th.add_child(child)
    expect(tc.errors.count).to eq(0)
    th = Thesaurus.find(th.id, th.namespace)
    expect(th.children.count).to eq(1)      
  end

  it "allows a child TC to be added - error, invalid identifier" do
    child =
    {
      :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
      :id => "",
      :namespace => "",
      :parentIdentifier => "",
      :identifier => "",
      :label => "Label",
      :notation => "SV",
      :preferredTerm => "PT",
      :synonym => "Syn",
      :definition => "Def"
    }
    th = Thesaurus.find("TH-ACME_TEST", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
    expect(th.children.count).to eq(1)
    tc = th.add_child(child)
    expect(tc.errors.count).to eq(1)
    th = Thesaurus.find(th.id, th.namespace)
    expect(th.children.count).to eq(1)      
  end

end