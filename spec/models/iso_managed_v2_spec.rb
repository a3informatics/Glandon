require 'rails_helper'

describe IsoManagedV2 do

	include DataHelpers
  include ValidationHelpers
  include SparqlHelpers
  include IsoHelpers

  def sub_dir
    return "models/iso_managed_v2"
  end
    
	before :each do
    IsoHelpers.clear_cache
    IsoHelpers.clear_schema_cache
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
    load_test_file_into_triple_store("iso_managed_data_4.ttl")
  end

	it "validates a valid object, general" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    expect(item.valid?).to eq(true)
  end

  it "validates a valid object, markdown" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    item.origin = vh_all_chars
    item.explanatory_comment  = vh_all_chars
    item.change_description = vh_all_chars
    expect(item.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    item.origin = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Origin contains invalid markdown")
  end

  it "does not validate an invalid object" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    item.explanatory_comment  = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Explanatory comment contains invalid markdown")
  end

  it "does not validate an invalid object" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    item.change_description = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Change description contains invalid markdown")
  end

  it "does not validate an invalid object" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    item.label = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
  end

  it "allows a blank item to be created" do
		result =     
			{ 
      	:uri => {},
        :has_identifier => {},
        :has_state => {},
        :rdf_type => "http://www.assero.co.uk/ISO11179Types#AdministeredItem",
      	:label => "",
      	:origin => "",
      	:change_description => "",
      	:creation_date => "2016-01-01T00:00:00+00:00",
      	:last_change_date => "2016-01-01T00:00:00+00:00",
      	:explanatory_comment => ""
    	}
		item = IsoManagedV2.new
    expect(item.to_h).to eq(result)
	end

	it "allows an item to be found" do
		uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
  #Xwrite_yaml_file(item.to_h, sub_dir, "find_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "find_expected_1.yaml")
    expect(item.to_h).to eq(expected)   
	end

  it "allows an item to be found, II" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
  #Xwrite_yaml_file(item.to_h, sub_dir, "find_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "find_expected_2.yaml")
    expect(item.to_h).to eq(expected)   
    #expect(true).to be(false)
  end

  it "allows the version, semantic_version, version_label and indentifier to be found" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.version).to eq(1)   
    expect(item.semantic_version.to_s).to eq("1.2.3")   
    expect(item.version_label).to eq("0.1")   
    expect(item.identifier).to eq("TEST")   
  end

  it "allows the latest, later, earlier and same version to be assessed" do
   uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.latest?).to eq(true)   
    expect(item.later_version?(0)).to eq(true)   
    expect(item.later_version?(1)).to eq(false)   
    expect(item.earlier_version?(1)).to eq(false)   
    expect(item.earlier_version?(2)).to eq(true)   
    expect(item.same_version?(1)).to eq(true)   
    expect(item.same_version?(2)).to eq(false)   
  end

  it "allows owner and owned? to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, true)
    expect(item.owner.organization_identifier).to eq("123456789")   
    expect(item.owned?).to eq(true)
  end

  it "allows registration status and registered to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.has_state.registration_status).to eq("Incomplete")   
    expect(item.registered?).to eq(true)   
  end

  it "allows edit, state on edit and delete status to be determined" do
   uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.edit?).to eq(true)   
    expect(item.state_on_edit).to eq("Incomplete")
    expect(item.delete?).to eq(true)   
  end

  it "allows current and can be current status to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.current?).to eq(false)   
    expect(item.can_be_current?).to eq(false)   
  end

  it "allows new_version, next_version, next_semantic_version, and first_version to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.new_version?).to eq(false)   
    expect(item.next_version).to eq(2)   
    expect(item.next_semantic_version.to_s).to eq("1.3.0")   
    expect(item.first_version).to eq(1)   
  end

  it "allows next version for an indentifier to be determned" do
  	next_version = IsoManagedV2.next_version("TEST", IsoRegistrationAuthority.owner.ra_namespace)
  	expect(next_version).to eq(2)
  	next_version = IsoManagedV2.next_version("TEST", IsoRegistrationAuthority.find_by_short_name("AAA"))
  	expect(next_version).to eq(1)
  	next_version = IsoManagedV2.next_version("TESTxxxxx", IsoRegistrationAuthority.owner)
  	expect(next_version).to eq(1)
  end

  it "handles not finding an item correctly" do
    expect{IsoManagedV2.find(Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#XXX"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRForms/ACME/V1#XXX in IsoManagedV2.")
  end

  it "allows the item to be updated" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri)
    result = item.to_h
    result[:explanatory_comment] = "New comment"
    result[:change_description] = "Description"
    result[:origin] = "Origin"
    item.update({:explanatory_comment => "New comment", :change_description => "Description", :origin => "Origin"})
    item = IsoManagedV2.find(uri)
    result[:last_change_date] = date_check_now(item.last_change_date).iso8601
    expect(item.to_h).to eq(result)
  end

  it "finds history of an item entries" do
    results = []
    results[0] = {:id => "F-BBB_VSB2", :scoped_identifier_version => 2}
    results[1] = {:id => "F-BBB_VSB1", :scoped_identifier_version => 1}
    items = IsoManagedV2.history("Form", "http://www.assero.co.uk/BusinessForm", {:identifier => "VSB", :scope => IsoRegistrationAuthority.owner.ra_namespace})
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end
  end

=begin
  it "checks if an item cannot be created, existing identifier and version" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expect(item.create_permitted?).to eq(false)
  end

  it "checks if an item can be created, new version" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    item.scoped_identifier.version = 2
    expect(item.create_permitted?).to eq(true)
  end

  it "checks if an item can be created, new identifier" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    item.scoped_identifier.identifier = "TEST NEW"
    expect(item.create_permitted?).to eq(true)
  end
=end

  it "allows an item to be created from JSON" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    new_item = IsoManagedV2.from_h(item.to_h)
    expect(item.to_h).to eq(new_item.to_h)
  end

=begin
  it "allows an item to be created from Operation JSON" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    old_item = IsoManagedV2.find(uri)
    new_item = IsoManagedV2.find(uri)
    operation = 
      {
        :action => "CREATE",
        :new_version => 1,
        :new_semantic_version => "2.2.2",
        :new_state => "Standard",
        :identifier_edit => true
      }
    new_item.from_operation(operation, "F", "http://www.assero.co.uk/NewNamespace", IsoRegistrationAuthority.owner)
    old_item.id = "F-BBB_TEST"
    old_item.namespace = "http://www.assero.co.uk/NewNamespace/BBB/V1"
    old_item.lastChangeDate = date_check_now(new_item.lastChangeDate)
    old_item.scopedIdentifier.id = "SI-BBB_TEST-1"
    old_item.scopedIdentifier.semantic_version = SemanticVersion.from_s("2.2.2")
    old_item.registrationState.id = "RS-BBB_TEST-1"
    old_item.registrationState.registrationStatus = "Standard"
    expect(new_item.to_json).to eq(old_item.to_json)
  end
=end

  it "allows the next version of an object to be adjusted" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    expected = item.version + 1
    item.adjust_next_version
    expect(item.version).to eq(expected)
  end

	it "permits the item to be exported as SPARQL" do
    result = "PREFIX : <http://www.assero.co.uk/MDRForms/ACME/V1#>\n" +
       "PREFIX isoR: <http://www.assero.co.uk/ISO11179Registration#>\n" +
       "PREFIX mdrItems: <http://www.assero.co.uk/MDRItems#>\n" +
       "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
       "PREFIX isoT: <http://www.assero.co.uk/ISO11179Types#>\n" +
       "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
       "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
       "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
       "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
       "INSERT DATA \n" + 
       "{ \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> rdf:type <http://www.assero.co.uk/BusinessForm#Form> . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> rdfs:label \"Iso Concept Test Form\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> rdf:type isoR:RegistrationState . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:byAuthority mdrItems:RA-123456789 . \n" + 
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:registrationStatus \"Incomplete\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:administrativeNote \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:effectiveDate \"2016-01-01T00:00:00%2B00:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:untilDate \"2016-01-01T00:00:00%2B00:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:unresolvedIssue \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:administrativeStatus \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:previousState \"Incomplete\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:identifier \"TEST\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> rdf:type isoI:ScopedIdentifier . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:version \"1\"^^xsd:positiveInteger . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:versionLabel \"0.1\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:semantic_version \"1.2.3\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:hasScope mdrItems:NS-BBB . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoI:hasIdentifier <http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoR:hasState <http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:creationDate \"2016-06-15T21:06:10%2B01:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:lastChangeDate \"2016-06-16T13:14:24%2B01:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:changeDescription \"Creation\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:explanatoryComment \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:origin \"\"^^xsd:string . \n" +
       "}"
  #Xwrite_text_file_2(result, sub_dir, "to_sparql_expected.txt")
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
    sparql = SparqlUpdateV2.new
    result_uri = item.to_sparql_v2(sparql, "bf")
    #expect(sparql.to_s).to eq(result)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
    expect(result_uri.to_s).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
  end

  it "permits the item to be exported as JSON" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    item = IsoManagedV2.find(uri, false)
  #write_text_file_2(item.to_h, sub_dir, "to_json_1.yaml")
    expected = read_yaml_file(sub_dir, "to_json_1.yaml")
    expect(item.to_h).to eq(expected)
  end

=begin
  it "permits the item to be exported as operational hash, same version" do
    form = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    result = 
      { 
        :operation => 
        { 
        	:action => "UPDATE", :new_version => 1, :new_semantic_version=>"1.2.3", 
        	:new_state => "Incomplete", :identifier_edit => false 
        }, 
        :managed_item => form
      }
    item = IsoManagedV2.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.to_operation).to eq(result)
  end

  it "permits the item to be exported as the operational hash, new version" do
    form = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    form[:registration_state][:registration_status] = "Qualified"
    expected = 
      { 
        :operation => 
        { 
        	:action => "CREATE", :new_version => 2, :new_semantic_version=>"1.3.0", 
        	:new_state => "Qualified", :identifier_edit => false 
        }, 
        :managed_item => form
      }
    item = IsoManagedV2.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.registrationState.registrationStatus = "Qualified"
    result = item.to_operation
    expected[:managed_item][:creation_date] = result[:managed_item][:creation_date] # Fix the date for comparison
    expect(result).to eq(expected)
  end

  it "permits the item to be exported as the operational hash, update" do
    form = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    form[:registration_state][:registration_status] = "Qualified"
    expected = 
      { 
        :operation => 
        { 
        	:action => "UPDATE", :new_version => 1, 
        	:new_semantic_version=>"1.2.3", :new_state => "Qualified", 
        	:identifier_edit => false 
        }, 
        :managed_item => form
      }
    item = IsoManagedV2.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.registrationState.registrationStatus = "Qualified"
    result = item.update_operation
    expected[:managed_item][:creation_date] = result[:managed_item][:creation_date] # Fix the date for comparison
    expect(result).to eq(expected)
  end
=end

  it "where, empty text" do
    all = IsoManagedV2.all # Empty search will find all items
    results = []
    IsoManagedV2.where({text: ""}).each { |x| results << x.to_json }
    expect(results.count).to eq(all.count)
  end

  it "where, I" do
    results = []
    IsoManagedV2.where({text: "VSB"}).each { |x| results << x.to_json }
  write_yaml_file(results, sub_dir, "where_2.yaml")
    expected = read_yaml_file(sub_dir, "where_2.yaml")
    expect(results).to hash_equal(expected)
  end

  it "where, II" do
    results = []
    IsoManagedV2.where({text: "Baseline"}).each { |x| results << x.to_json }
  write_yaml_file(results, sub_dir, "where_3.yaml")
    expected = read_yaml_file(sub_dir, "where_3.yaml")
    expect(results).to hash_equal(expected)
  end

end