require 'rails_helper'

describe IsoManaged do

	include DataHelpers

  def date_check_now(item)
    expect(item).to be_within(1.second).of Time.now
    return item
  end

  def form_json
    result =     
      { 
        :type => "http://www.assero.co.uk/BusinessForm#Form",
        :id => "F-ACME_TEST", 
        :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1", 
        :label => "Iso Concept Test Form",
        :extension_properties => [],
        :origin => "",
        :change_description => "Creation",
        :creation_date => "2016-06-15T21:06:10+01:00",
        :last_changed_date => "2016-06-16T13:14:24+01:00",
        :explanatory_comment => "",
        :registration_state => 
          {
            :namespace => "http://www.assero.co.uk/MDRItems", 
            :id => "RS-ACME_TEST-1", 
            :registration_authority => 
              {
                :id => "RA-123456789", 
                :number => "123456789", 
                :scheme => "DUNS", 
                :owner => true, 
                :namespace => 
                  {
                    :namespace => "http://www.assero.co.uk/MDRItems", 
                    :id => "NS-BBB", 
                    :name => "BBB Pharma", 
                    :shortName => "BBB"}
                  }, 
                :registration_status => "Incomplete",
                :administrative_note => "", 
                :effective_date => "2016-01-01T00:00:00+00:00",
                :until_date => "2016-01-01T00:00:00+00:00",
                :current => false, 
                :unresolved_issue => "", 
                :administrative_status => "", 
                :previous_state => "Incomplete"
              },
        :scoped_identifier => 
          { 
            :id => "SI-ACME_TEST-1", :identifier => "TEST", :version_label => "0.1", :version => 1, 
            :namespace => 
              {
                :namespace => "http://www.assero.co.uk/MDRItems", 
                :id => "NS-BBB", 
                :name => "BBB Pharma", 
                :shortName => "BBB"
              } 
          },
      }
      return result
    end
	it "clears triple store and loads test data" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("IsoNamespace.ttl")
    load_test_file_into_triple_store("iso_managed_data.ttl")
    load_test_file_into_triple_store("iso_managed_data_2.ttl")
    load_test_file_into_triple_store("iso_managed_data_3.ttl")
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
    expect(item.to_json).to eq(form_json)   
	end

  it "allows the version, versionLabel and indentifier to be found" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.version).to eq(1)   
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

  it "allows new_version, next_version and first_version to be determined" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.new_version?).to eq(false)   
    expect(item.next_version).to eq(2)   
    expect(item.first_version).to eq(1)   
  end

  it "allows existance to be determined, no item" do
    expect(IsoManaged.exists?("TEST", IsoRegistrationAuthority.owner)).to eq(true)   
  end

  it "allows existance to be determined with item" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.exists?(IsoRegistrationAuthority.owner)).to eq(true)   
  end

  it "allows existance to be determined, identifer, version and RA" do
    expect(IsoManaged.versionExists?("TEST", 1, IsoRegistrationAuthority.owner.namespace)).to eq(true)   
  end

  it "allows the type to be determined" do
    expect(IsoManaged.get_type("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1").to_s).to eq("http://www.assero.co.uk/BusinessForm#Form")   
  end

  it "handles not finding an item correctly" do
    item = IsoManaged.find("F-ACME_TESTx", "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = IsoManaged.new
    expect(item.to_json).to eq(result.to_json)
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

  it "finds all entries" do
    results = []
    results[0] = {:id => "F-ACME_TEST"}
    results[1] = {:id => "F-BBB_VSB2"}
    results[2] = {:id => "F-BBB_VSB1"}
    results[3] = {:id => "F-BBB_VSW"}
    items = IsoManaged.all("Form", "http://www.assero.co.uk/BusinessForm")
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
    end
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
    results[0] = {:id => "F-BBB_VSB1", :scoped_identifier_version => 1}
    results[1] = {:id => "F-BBB_VSW", :scoped_identifier_version => 1}
    items = IsoManaged.list("Form", "http://www.assero.co.uk/BusinessForm")
    items.each_with_index do |item, index|
      expect(results[index][:id]).to eq(items[index].id)
      expect(results[index][:scoped_identifier_version]).to eq(items[index].scopedIdentifier.version)
    end
  end

  it "allows the current item to be found" do
    item = IsoManaged.current("Form", "http://www.assero.co.uk/BusinessForm", {:identifier => "VSW", :scope_id => IsoRegistrationAuthority.owner.namespace.id})
    expect(item.scopedIdentifier.identifier).to eq("VSW")    
    expect(item.scopedIdentifier.version).to eq(1)    
  end

  it "allows a tag to be added" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.add_tag("TAG1", "http://www.assero.co.uk/tags")
    item = IsoManaged.find_by_tag("TAG1", "http://www.assero.co.uk/tags")
    expect(item[0].scopedIdentifier.identifier).to eq("TEST")
  end

  it "allows a tag to be deleted" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.add_tag("TAG2", "http://www.assero.co.uk/tags")
    item.delete_tag("TAG1", "http://www.assero.co.uk/tags")
    item = IsoManaged.find_by_tag("TAG2", "http://www.assero.co.uk/tags")
    expect(item[0].scopedIdentifier.identifier).to eq("TEST")
  end
  
  #def self.graph_to(id, namespace)
  #def self.graph_from(id, namespace)

  it "allows an item to be created from JSON" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    new_item = IsoManaged.from_json(item.to_json)
    expect(item.to_json).to eq(new_item.to_json)
  end

  it "allows an item to be created from Operation JSON" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    new_item = IsoManaged.from_operation(item.to_operation, "F", "http://www.assero.co.uk/MDRForms", IsoRegistrationAuthority.owner)
    item.id = "F-BBB_TEST"
    item.namespace = "http://www.assero.co.uk/MDRForms/BBB/V1"
    item.lastChangeDate = date_check_now(new_item.lastChangeDate)
    expect(new_item.to_json).to eq(item.to_json)
  end

  it "allows an item to be created from data" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    item.scopedIdentifier.identifier = "ZZZ"
    new_item = IsoManaged.from_data(item.to_operation, "F", "http://www.assero.co.uk/MDRForms", "http://www.assero.co.uk/BusinessForm", "Form", IsoRegistrationAuthority.owner)
    item.id = "F-BBB_ZZZ"
    item.namespace = "http://www.assero.co.uk/MDRForms/BBB/V1"
    item.lastChangeDate = date_check_now(new_item.lastChangeDate)
    item.registrationState.id = "RS-BBB_ZZZ-1"
    item.scopedIdentifier.id = "SI-BBB_ZZZ-1"
    expect(new_item.to_json).to eq(item.to_json)
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
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:effectiveDate \"2016-01-01T00:00:00+00:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:untilDate \"2016-01-01T00:00:00+00:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:unresolvedIssue \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:administrativeStatus \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> isoR:previousState \"Incomplete\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:identifier \"TEST\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> rdf:type isoI:ScopedIdentifier . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:version \"1\"^^xsd:positiveInteger . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:versionLabel \"0.1\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> isoI:hasScope mdrItems:NS-BBB . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoI:hasIdentifier <http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1> . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoR:hasState <http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1> . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:creationDate \"2016-06-15T21:06:10+01:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:lastChangeDate \"2016-06-16T13:14:24+01:00\"^^xsd:dateTime . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:changeDescription \"Creation\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:explanatoryComment \"\"^^xsd:string . \n" +
       "<http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST> isoT:origin \"\"^^xsd:string . \n" +
       "}"
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    sparql = SparqlUpdateV2.new
    item.to_sparql_v2(sparql, "bf")
    expect(sparql.to_s).to eq(result)
  end

  it "permits the item to be exported as JSON" do
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.to_json).to eq(form_json)
  end

  it "permits the item to be exported as Operation JSON" do
    result = 
      { 
        :operation => { :action => "UPDATE", :new_version => 1, :new_state => "Incomplete", :identifier_edit => false }, 
        :managed_item => form_json
      }
    item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    expect(item.to_operation).to eq(result)
  end

  it "permits the item to be cloned" do
    result = 
      { 
        :operation => { :action => "CREATE", :new_version => 1, :new_state => "Incomplete", :identifier_edit => true }, 
        :managed_item => form_json 
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

	it "clears triple store" do
    clear_triple_store
  end

end