require 'rails_helper'

describe IsoManaged do

	include DataHelpers
  include ValidationHelpers

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
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_managed_data.ttl")
    load_test_file_into_triple_store("iso_managed_data_2.ttl")
    load_test_file_into_triple_store("iso_managed_data_3.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("CT_V41.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

	it "validates a valid object, general" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.valid?).to eq(true)
  end

  it "validates a valid object, markdown" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.origin = vh_all_chars
    item.explanatoryComment  = vh_all_chars
    item.changeDescription = vh_all_chars
    expect(item.valid?).to eq(true)
  end

  it "does not validate an invalid object" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.origin = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Origin contains invalid markdown")
  end

  it "does not validate an invalid object" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.explanatoryComment  = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Explanatory comment contains invalid markdown")
  end

  it "does not validate an invalid object" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.changeDescription = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Change description contains invalid markdown")
  end

  it "does not validate an invalid object" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.label = "£"
    result = item.valid?
    expect(result).to eq(false)
    expect(item.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
  end

  it "allows a blank item to be created" do
		result =     
			{ 
      	:type => "",
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
    	}
		item = IsoManaged.new
    result[:creation_date] = date_check_now(item.creationDate).iso8601
    result[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.to_json).to eq(result)
	end

	it "allows an item to be found" do
		item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expected = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    expect(item.to_json).to eq(expected)   
	end

  it "allows an item to be found, II" do
    item = IsoManaged.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
  write_yaml_file(item.to_json, sub_dir, "iso_managed_th.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_th.yaml")
    expect(item.to_json).to eq(expected)   
  end

  it "allows the version, semantic_version, versionLabel and indentifier to be found" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.version).to eq(1)   
    expect(item.semantic_version.to_s).to eq("1.2.3")   
    expect(item.versionLabel).to eq("0.1")   
    expect(item.identifier).to eq("TEST")   
  end

  it "allows the latest, later, earlier and same version to be assessed" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.latest?).to eq(true)   
    expect(item.later_version?(0)).to eq(true)   
    expect(item.later_version?(1)).to eq(false)   
    expect(item.earlier_version?(1)).to eq(false)   
    expect(item.earlier_version?(2)).to eq(true)   
    expect(item.same_version?(1)).to eq(true)   
    expect(item.same_version?(2)).to eq(false)   
  end

  it "allows owner, owner_id and owned? to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.owner).to eq("BBB")   
    expect(item.owner_id).to eq("NS-BBB")   
    expect(item.owned?).to eq(true)
  end

  it "allows registration status and registered to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.registrationStatus).to eq("Incomplete")   
    expect(item.registered?).to eq(true)   
  end

  it "allows edit, state on edit and delete status to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.edit?).to eq(true)   
    expect(item.state_on_edit).to eq("Incomplete")
    expect(item.delete?).to eq(true)   
  end

  it "allows current and can be current status to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.current?).to eq(false)   
    expect(item.can_be_current?).to eq(false)   
  end

  it "allows new_version, next_version, next_semantic_version, and first_version to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.new_version?).to eq(false)   
    expect(item.next_version).to eq(2)   
    expect(item.next_semantic_version.to_s).to eq("1.3.0")   
    expect(item.first_version).to eq(1)   
  end

  it "allows existance to be determined with item" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.exists?).to eq(true)   
  end

  it "allows existance to be determined, identifer, version and RA" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.version_exists?).to eq(true)   
  end

  it "allows the type to be determined" do
    expect(IsoManaged.get_type("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1").to_s).to eq("http://www.assero.co.uk/BusinessForm#Form")   
  end

  it "handles not finding an item correctly" do
    expect{IsoManaged.find("F-ACME_TESTx", "http://www.assero.co.uk/MDRForms/ACME/V1")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows the item to be updated" do
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    result = item.to_json
    result [:explanatory_comment] = "New comment"
    result [:change_description] = "Description"
    result [:origin] = "Origin"
    item.update({:explanatoryComment => "New comment", :changeDescription => "Description", :origin => "Origin"})
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    result[:last_changed_date] = date_check_now(item.lastChangeDate).iso8601
    expect(item.to_json).to eq(result)
  end

  it "allows the item status to be updated, not standard" do
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    params = {}
    params[:registrationStatus] = "Qualified"
    params[:previousState] = "Recorded"
    params[:administrativeNote] = "New note"
    params[:unresolvedIssue] = "Unresolved issues"
    expected = item
    expected.registrationState.registrationStatus = "SomethingNew"
    expected.registrationState.previousState = "SomethingOld"
    expected.registrationState.administrativeNote = "New note"
    expected.registrationState.unresolvedIssue = "Unresolved issues"
    item.update_status(params)
    expect(item.errors.full_messages.to_sentence).to eq("")
    expect(item.errors.count).to eq(0)
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    expect(item.to_json).to eq(expected.to_json)
  end

  it "allows the item status to be updated, error" do
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    params = {}
    params[:registrationStatus] = "SomethingNew"
    params[:previousState] = "SomethingOld"
    params[:administrativeNote] = "New note"
    params[:unresolvedIssue] = "Unresolved issues"
    item.update_status(params)
    expect(item.errors.full_messages.to_sentence).to eq("Registration State: Registrationstatus is invalid")
    expect(item.errors.count).to eq(1)
  end

  it "allows the item status to be updated, standard" do
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    params = {}
    params[:registrationStatus] = "Standard"
    params[:previousState] = "Qualified"
    params[:administrativeNote] = "New note"
    params[:unresolvedIssue] = "Unresolved issues"
    expected = IsoManaged.from_json(item.to_json)
    expected.registrationState.registrationStatus = "Standard"
    expected.registrationState.previousState = "Qualified"
    expected.registrationState.administrativeNote = "New note"
    expected.registrationState.unresolvedIssue = "Unresolved issues"
    expected.scopedIdentifier.semantic_version = SemanticVersion.from_s("1.0.0")
    item.update_status(params)
    item = IsoManaged.find("F-BBB_VSW", "http://www.assero.co.uk/X/V1")
    expect(item.to_json).to eq(expected.to_json)
  end

  it "finds all unique entries" do
    result = 
      [
        {
          :identifier=>"VSB",
          :label=>"Vital Signs Baseline",
          :owner_id=>"NS-BBB",
          :owner=>"BBB"
        },
        {
          :identifier=>"TEST",
          :label=>"Iso Concept Test Form",
          :owner_id=>"NS-BBB",
          :owner=>"BBB"
        },
        {
          :identifier=>"VSW",
          :label=>"Vital Signs Weekly",
          :owner_id=>"NS-BBB",
          :owner=>"BBB"
        }
      ]
    expect(IsoManaged.unique("Form", "http://www.assero.co.uk/BusinessForm")).to eq (result)
  end

  it "finds all entries by type" do
    results = []
    results[0] = {:id => "F-ACME_TEST"}
    results[1] = {:id => "F-BBB_VSB2"}
    results[2] = {:id => "F-BBB_VSB1"}
    results[3] = {:id => "F-BBB_VSW"}
    items = IsoManaged.all_by_type("Form", "http://www.assero.co.uk/BusinessForm")
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
    end
  end

  it "finds all entries" do
    results = []
    results[0] = {:id => "F-ACME_TEST"}
    results[1] = {:id => "F-BBB_VSB2"}
    results[2] = {:id => "F-BBB_VSB1"}
    results[3] = {:id => "F-BBB_VSW"}
    items = IsoManaged.all
  #write_yaml_file(items, sub_dir, "iso_managed_all.yaml")
  	expected = read_yaml_file(sub_dir, "iso_managed_all.yaml")
    expect(items).to match_array(expected)
  end

  it "finds history of an item entries" do
    results = []
    results[0] = {:id => "F-BBB_VSB2", :scoped_identifier_version => 2}
    results[1] = {:id => "F-BBB_VSB1", :scoped_identifier_version => 1}
    items = IsoManaged.history("Form", "http://www.assero.co.uk/BusinessForm", {:identifier => "VSB", :scope_id => "NS-BBB"})
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end
  end

  it "finds list of all released entries" do
    results = []
    items = IsoManaged.list("Form", "http://www.assero.co.uk/BusinessForm")
    items.each { |x| results << x.to_json }
  #write_yaml_file(results, sub_dir, "iso_managed_list.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_list.yaml")
    i = items.find { |x| x.id == "F-BBB_VSW" } # We know this got edited in an above test, modify time
    e = expected.find { |x| x[:id] == "F-BBB_VSW" }
    e[:last_changed_date] = date_check_now(i.lastChangeDate).iso8601
    expect(results).to eq(expected)
  end

  it "allows the current item to be found" do
    item = IsoManaged.current("Form", "http://www.assero.co.uk/BusinessForm", {:identifier => "VSW", :scope_id => IsoRegistrationAuthority.owner.namespace.id})
    expect(item.scopedIdentifier.identifier).to eq("VSW")    
    expect(item.scopedIdentifier.version).to eq(1)    
  end

  it "allows the current set to be found, terminology" do
    items = IsoManaged.current_set("Thesaurus", "http://www.assero.co.uk/ISO25964")
    #write_yaml_file(items.to_json, sub_dir, "iso_managed_current_set_term.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_current_set_term.yaml")
    expect(items.to_json).to eq(expected)
  end

  it "allows the current set to be found, Forms" do
    items = IsoManaged.current_set("Form", "http://www.assero.co.uk/BusinessForm")
    #write_yaml_file(items.to_json, sub_dir, "iso_managed_current_set_form.yaml")
    expected = read_yaml_file(sub_dir, "iso_managed_current_set_form.yaml")
    expect(items.to_json).to eq(expected)
  end

  it "allows a tag to be added" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.add_tag("TAG1", "http://www.assero.co.uk/tags")
    item = IsoManaged.find_by_tag("TAG1", "http://www.assero.co.uk/tags")
    expect(item[0].scopedIdentifier.identifier).to eq("TEST")
  end

  it "allows a tag to be added, fail" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{item.add_tag("TAG1", "http://www.assero.co.uk/tags")}.to raise_error(Exceptions::UpdateError)
  end

  it "allows a tag to be deleted" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.add_tag("TAG2", "http://www.assero.co.uk/tags")
    item.delete_tag("TAG1", "http://www.assero.co.uk/tags")
    item = IsoManaged.find_by_tag("TAG2", "http://www.assero.co.uk/tags")
    expect(item[0].scopedIdentifier.identifier).to eq("TEST")
  end
  
  it "allows a tag to be deleted, fail" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{item.delete_tag("TAG1", "http://www.assero.co.uk/tags")}.to raise_error(Exceptions::UpdateError)
  end
  
  it "checks if an item cannot be created, existing identifier and version" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.create_permitted?).to eq(false)
  end

  it "checks if an item can be created, new version" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.scopedIdentifier.version = 2
    expect(item.create_permitted?).to eq(true)
  end

  it "checks if an item can be created, new identifier" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.scopedIdentifier.identifier = "TEST NEW"
    expect(item.create_permitted?).to eq(true)
  end

  it "allows an item to be created from JSON" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    new_item = IsoManaged.from_json(item.to_json)
    expect(item.to_json).to eq(new_item.to_json)
  end

  it "allows an item to be created from Operation JSON" do
    old_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    new_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
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
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    sparql = SparqlUpdateV2.new
    result_uri = item.to_sparql_v2(sparql, "bf")
    expect(sparql.to_s).to eq(result)
    expect(result_uri.to_s).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
  end

  it "permits the item to be exported as JSON" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expected = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "permits the item to be exported as Operation JSON" do
    form = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    result = 
      { 
        :operation => { :action => "UPDATE", :new_version => 1, :new_semantic_version=>"1.2.3", :new_state => "Incomplete", :identifier_edit => false }, 
        :managed_item => form
      }
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.to_operation).to eq(result)
  end

  it "permits the item to be cloned" do
    form = read_yaml_file(sub_dir, "iso_managed_form.yaml")
    result = 
      { 
        :operation => { :action => "CREATE", :new_version => 1, :new_semantic_version=>"0.1.0", :new_state => "Incomplete", :identifier_edit => true }, 
        :managed_item => form
      }
    result[:managed_item][:scoped_identifier] = IsoScopedIdentifier.new.to_json
    result[:managed_item][:registration_state] = IsoRegistrationState.new.to_json
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item_json = item.to_clone
    result[:managed_item][:creation_date] = date_check_now(Time.parse(item_json[:managed_item][:creation_date])).iso8601
    expect(item_json).to eq(result)
  end

  it "allows the item to be deleted" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.destroy
  end

  it "finds the parent managed item" do
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    mi = IsoManaged.find_managed("CLI-C100144_C103608", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology"}), rdf_type: "http://www.assero.co.uk/ISO25964#Thesaurus" }
    expect(mi.to_json).to eq(result.to_json)
    mi = IsoManaged.find_managed("BC-ACME_BC_C25347_DefinedObservation_targetAnatomicSiteCode_CD", "http://www.assero.co.uk/MDRBCs/V1")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347"}), rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance" }
    expect(mi.to_json).to eq(result.to_json)
    mi = IsoManaged.find_managed("F-ACME_VSBASELINE1_G1_G2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}), rdf_type: "http://www.assero.co.uk/BusinessForm#Form" }
    expect(mi.to_json).to eq(result.to_json)
    mi = IsoManaged.find_managed( "F-ACME_VSBASELINE1_G1_G1_I2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}), rdf_type: "http://www.assero.co.uk/BusinessForm#Form" }
    expect(mi.to_json).to eq(result.to_json)
    mi = IsoManaged.find_managed( "F-ACME_VSBASELINE1_G1_G1_I2_I1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}), rdf_type: "http://www.assero.co.uk/BusinessForm#Form" }
    mi = IsoManaged.find_managed( "F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}), rdf_type: "http://www.assero.co.uk/BusinessForm#Form" }
    expect(mi.to_json).to eq(result.to_json)
  end

  it "finds the links to and from the managed object" do
    # Assumes data load from previous test
    mi = IsoManaged.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    expected = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"}), rdf_type: "http://www.assero.co.uk/BusinessForm#Form" }
    results = mi.find_links_from_to(from=false)
    expect(results.count).to eq(1)
    expect(results[0].to_json).to eq(expected.to_json)
    expected = []
    expected[0] = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347"}), rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance" }
    expected[1] = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25299"}), rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance" }
    expected[2] = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25208"}), rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance" }
    expected[3] = { uri: UriV2.new({uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298"}), rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance" }
    mi = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    results = mi.find_links_from_to()
    expect(results.count).to eq(4)
    expect(results[0].to_json).to eq(expected[0].to_json)
    expect(results[1].to_json).to eq(expected[1].to_json)
    expect(results[2].to_json).to eq(expected[2].to_json)
    expect(results[3].to_json).to eq(expected[3].to_json)
  end

end