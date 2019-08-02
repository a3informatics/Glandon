require 'rails_helper'

describe IsoManagedV2 do

	include DataHelpers
  include PublicFileHelpers
  include ValidationHelpers
  include SparqlHelpers
  include IsoHelpers
  include TimeHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/iso_managed_v2"
  end
    
  describe "General" do

  	before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_managed_data_4.ttl"]
      load_files(schema_files, data_files)
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
          :has_identifier => nil,
          :has_state => nil,
          :rdf_type => "http://www.assero.co.uk/ISO11179Types#AdministeredItem",
        	:label => "",
        	:origin => "",
        	:change_description => "",
        	:creation_date => "2016-01-01T00:00:00+00:00",
        	:last_change_date => "2016-01-01T00:00:00+00:00",
        	:explanatory_comment => "",
          :uuid => nil
      	}
  		item = IsoManagedV2.new
      expect(item.to_h).to eq(result)
  	end

    it "allows the version, semantic_version, version_label and indentifier to be found" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find(uri, false)
      expect(item.version).to eq(1)   
      expect(item.semantic_version.to_s).to eq("1.2.3")   
      expect(item.version_label).to eq("0.1")   
      expect(item.scoped_identifier).to eq("TEST")   
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
      expect(item.registration_status).to eq("Standard")   
      expect(item.registered?).to eq(true)   
    end

    it "allows edit, state on edit and delete status to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find(uri, false)
      expect(item.edit?).to eq(true)   
      expect(item.state_on_edit).to eq("Incomplete")
      expect(item.delete?).to eq(true)   
    end

    it "allows current and can be current status to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find(uri, false)
      expect(item.current?).to eq(false)   
      expect(item.can_be_current?).to eq(false)   
    end

    it "allows new_version, next_version, next_semantic_version, and first_version to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find(uri, false)
      expect(item.new_version?).to eq(false)   
      expect(item.next_version).to eq(4)   
      expect(item.next_semantic_version.to_s).to eq("1.5.0")   
      expect(item.first_version).to eq(1)   
    end

    it "allows next version for an indentifier to be determned" do
    	next_version = IsoManagedV2.next_version("TEST", IsoRegistrationAuthority.owner.ra_namespace)
    	expect(next_version).to eq(4)
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

    it "finds latest" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      result = IsoManagedV2.latest({:identifier => "TEST", :scope => IsoRegistrationAuthority.owner.ra_namespace})
      expect(result.version).to eq(3)
      result = IsoManagedV2.latest({:identifier => "TESTx", :scope => IsoRegistrationAuthority.owner.ra_namespace}) # Invalid identifier
      expect(result).to be_nil
    end

    it "returns forwards and backwards, I" do
      item_history = []
      items = []
      (1..20).each do |index|
        item = IsoManagedV2.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        items << item
        item_history << item.uri
      end
      current = items[10]
      expect(current).to receive(:scope).and_return(IsoNamespace.new)
      expect(current).to receive(:scoped_identifier).and_return("CT")
      expect(IsoManagedV2).to receive(:history_uris).and_return(item_history)
      results = {}
      current.forward_backward(1, 4).each{|k,v| results[k] = v.nil? ? "nil" : v.to_s}
      check_file_actual_expected(results, sub_dir, "forward_backward_expected_1.yaml")
    end

    it "returns forwards and backwards, II" do
      item_history = []
      items = []
      (1..3).each do |index|
        item = IsoManagedV2.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        items << item
        item_history << item.uri
      end
      current = items[1]
      expect(current).to receive(:scope).and_return(IsoNamespace.new)
      expect(current).to receive(:scoped_identifier).and_return("CT")
      expect(IsoManagedV2).to receive(:history_uris).and_return(item_history)
      results = {}
      current.forward_backward(1, 4).map{|k,v| results[k] = v.nil? ? "nil" : v.to_s}
      check_file_actual_expected(results, sub_dir, "forward_backward_expected_2.yaml")
    end

    it "returns forwards and backwards, III" do
      item_history = []
      items = []
      (1..5).each do |index|
        item = IsoManagedV2.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        item.label = "Number #{index}"
        items << item
        item_history << item.uri
      end
      current = items[1]
      expect(current).to receive(:scope).and_return(IsoNamespace.new)
      expect(current).to receive(:scoped_identifier).and_return("CT")
      expect(IsoManagedV2).to receive(:history_uris).and_return(item_history)
      results = {}
      current.forward_backward(1, 4).map{|k,v| results[k] = v.nil? ? "nil" : v.to_s}
      check_file_actual_expected(results, sub_dir, "forward_backward_expected_3.yaml")

      current = items[2]
      expect(current).to receive(:scope).and_return(IsoNamespace.new)
      expect(current).to receive(:scoped_identifier).and_return("CT")
      expect(IsoManagedV2).to receive(:history_uris).and_return(item_history)
      results = {}
      current.forward_backward(2, 4).map{|k,v| results[k] = v.nil? ? "nil" : v.to_s}
      check_file_actual_expected(results, sub_dir, "forward_backward_expected_4.yaml")
    end

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

    #it "allows the next version of an object to be adjusted" do
    #  uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
    #  item = IsoManagedV2.find(uri, false)
    #  expected = item.version + 1
    #  item.adjust_next_version
    #  expect(item.version).to eq(expected)
    #end

=begin
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
=end

    it "permits the item to be exported as JSON" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find(uri, false)
      check_file_actual_expected(item.to_h, sub_dir, "to_json_1.yaml", equate_method: :hash_equal)
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

    it "gets all" do
      all = IsoManagedV2.all # Empty search will find all items
      expect(all.count).to eq(3)
    end

    it "sets up the initial version" do
      item = IsoManagedV2.new
      item.set_initial("AAA")
      expect(item.version).to eq(1)
      expect(item.scoped_identifier).to eq("AAA")
      expect(item.owner_short_name).to eq("BBB")
      expect(item.uri.to_s).to eq("http://www.bbb.com/AAA/V1")
    end

    it "sets up the import version" do
    
      class IMV2Klass < IsoManagedV2
        
        def self.owner
          IsoRegistrationAuthority.find_by_short_name("BBB")
        end

      end
    
      item = IMV2Klass.new
      params = {label: "Label", identifier: "XXX", version_label: "v l", semantic_version: "1.1.1", version: 5, date: "1989-07-07", ordinal: 1}
      item.set_import(params)
      expected_date = "1989-07-07".to_time_with_default
      expect(item.version).to eq(5)
      expect(item.scoped_identifier).to eq("XXX")
      expect(item.owner_short_name).to eq("BBB")
      expect(item.creation_date.iso8601).to eq("#{expected_date.iso8601}")
      expect(item.last_change_date.iso8601).to eq("#{expected_date.iso8601}")
      expect(item.uri.to_s).to eq("http://www.bbb.com/XXX/V5")
      expect(item.registration_status).to eq("Standard")
    end

  end

  describe "Find Tests" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
        "BusinessOperational.ttl", "thesaurus.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_managed_data_4.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    end

    it "find, I" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = IsoManagedV2.find(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find, II" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = CdiscTerm.find(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_expected_2.yaml", equate_method: :hash_equal)
    end

    it "find, III, speed" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      timer_start
      (1..100).each {|x| results = CdiscTerm.find(uri)}
      timer_stop("Find 100 times [8.29s -> 6.48s]")
    end

    it "find minimum I" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = IsoManagedV2.find_minimum(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_minimum_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find minimum II, speed" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      timer_start
      (1..100).each {|x| results = CdiscTerm.find_minimum(uri)}
      timer_stop("Find 100 times [1.65s -> 1.25s]")
    end

    it "where, I" do
      results = []
      IsoManagedV2.where({label: "VSB"}).each { |x| results << x.to_json }
      check_file_actual_expected(results, sub_dir, "where_expected_1.yaml", equate_method: :hash_equal)
    end

    it "where, II" do
      results = []
      IsoManagedV2.where({label: "Iso Concept Test Form"}).each { |x| results << x.to_h }
      check_file_actual_expected(results, sub_dir, "where_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "History Pagination" do

    before :all do
      IsoHelpers.clear_cache
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..50)
    end

    after :all do
      delete_all_public_test_files
    end

    it "history" do
      results = []
      actual = CdiscTerm.history(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      actual.each {|x| results << x.to_h}
      check_file_actual_expected(results, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history, pagination" do
      results = []
      actual = CdiscTerm.history_pagination(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope, count: 10, offset: 10)
      expect(actual.count).to eq(10)
      actual.each {|x| results << x.to_h}
      check_file_actual_expected(results, sub_dir, "history_pagination_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history uris" do
      results = []
      actual = CdiscTerm.history_uris(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      actual.each {|x| results << x.to_s}
      check_file_actual_expected(results, sub_dir, "history_uris_expected_1.yaml", equate_method: :hash_equal)
    end

    it "history speed" do
      timer_start
      current = CdiscTerm.history_pagination(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope, count: "10", offset: "10")
      timer_stop("Pagination 10 entries [??? -> 0.12s]")
      expect(current.count).to eq(10)
      expect(current[0].version).to eq(40)

      timer_start
      current = CdiscTerm.history_pagination(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope, count: "50", offset: "0")
      timer_stop("Pagination 50 entries [??? -> 0.4s]")
      expect(current.count).to eq(50)
      expect(current[0].version).to eq(50)

      timer_start
      current = CdiscTerm.history(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      timer_stop("No Pagination 50 entries [0.44s -> 0.36s]")
      expect(current.count).to eq(50)
      expect(current.first.version).to eq(50)
      expect(current.last.version).to eq(1)
    end

  end

  describe "Unique" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "unique, empty" do
      index = Thesaurus.unique
      expect(index.count).to eq(0)
    end

    it "unique, items many" do
      (1..10).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM#{index}", version_label: "1", semantic_version: "1.0.0", version: "1", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
      end 
      index = CdiscTerm.unique
      expect(index.count).to eq(10)
      expect(index.first[:label]).to eq("Item 1")
      expect(index.first[:identifier]).to eq("ITEM1")
      expect(index.last[:label]).to eq("Item 10")
      expect(index.last[:identifier]).to eq("ITEM10")
    end

    it "unique, items one" do
      (1..10).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        item.label = "Item"
        item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "#{index}.0.0", version: "#{index}", date: "2019-01-01", ordinal: index)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
      end 
      index = CdiscTerm.unique
      expect(index.count).to eq(1)
      expect(index.first[:label]).to eq("Item")
      expect(index.first[:identifier]).to eq("ITEM")
    end

    it "unique speed" do
      (1..500).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM#{index}", version_label: "1", semantic_version: "1.0.0", version: "1", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
      end 
      timer_start
      index = CdiscTerm.unique
      expect(index.count).to eq(500)
      timer_stop("Unique")
    end

  end

  describe "Create" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "create" do
      object = Thesaurus.create({label: "A new item", identifier: "XXXXX"})
      expect(object.errors.count).to eq(0)
      check_dates(object, sub_dir, "create_expected_1a.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(object.to_h, sub_dir, "create_expected_1a.yaml", equate_method: :hash_equal)
      object = Thesaurus.find(object.uri)
      check_dates(object, sub_dir, "create_expected_1b.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(object.to_h, sub_dir, "create_expected_1b.yaml", equate_method: :hash_equal)
    end

    it "create, not valid" do
      object = Thesaurus.create({label: "A new item±±", identifier: "XXXXX"})
      expect(object.errors.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
    end

    it "create, not permitted" do
      expect(IsoScopedIdentifierV2).to receive(:exists?).and_return(true)
      object = Thesaurus.create({label: "A new item", identifier: "XXXXX"})
      expect(object.errors.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("The item cannot be created. The identifier is already in use.")
    end

  end

  describe "Create Permitted" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "checks if an item cannot be created, existing identifier and version" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.new
      item.has_identifier.version = 1
      expect(IsoScopedIdentifierV2).to receive(:exists?).with("XXX", instance_of(IsoNamespace)).and_return(true)
      expect(IsoScopedIdentifierV2).to receive(:latest_version).with("XXX", instance_of(IsoNamespace)).and_return(4)
      expect(item.create_permitted?).to eq(false)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("The item cannot be created. The identifier is already in use.")
    end

    it "checks if an item cannot be created, existing identifier and version" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.new
      item.has_identifier.version = 2
      expect(IsoScopedIdentifierV2).to receive(:exists?).with("XXX", instance_of(IsoNamespace)).and_return(false)
      expect(IsoScopedIdentifierV2).to receive(:latest_version).with("XXX", instance_of(IsoNamespace)).and_return(0)
      expect(item.create_permitted?).to eq(false)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("The item cannot be created. Identifier does not exist but version [2] error.")
    end

    it "checks if an item can be created, new version" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.new
      item.has_identifier.version = 2
      expect(IsoScopedIdentifierV2).to receive(:exists?).with("XXX", instance_of(IsoNamespace)).and_return(true)
      expect(IsoScopedIdentifierV2).to receive(:latest_version).with("XXX", instance_of(IsoNamespace)).and_return(1)
      expect(item.create_permitted?).to eq(true)
      expect(item.errors.count).to eq(0)
    end

    it "checks if an item can be created, new version" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.new
      item.has_identifier.version = 5
      expect(IsoScopedIdentifierV2).to receive(:exists?).with("XXX", instance_of(IsoNamespace)).and_return(true)
      expect(IsoScopedIdentifierV2).to receive(:latest_version).with("XXX", instance_of(IsoNamespace)).and_return(4)
      expect(item.create_permitted?).to eq(true)
      expect(item.errors.count).to eq(0)
    end

    it "checks if an item can be created, new version" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.new
      item.has_identifier.version = 3
      expect(IsoScopedIdentifierV2).to receive(:exists?).with("XXX", instance_of(IsoNamespace)).and_return(true)
      expect(IsoScopedIdentifierV2).to receive(:latest_version).with("XXX", instance_of(IsoNamespace)).and_return(4)
      expect(item.create_permitted?).to eq(false)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("The item cannot be created. The identifier is already in use.")
    end

  end

  describe "Comments" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_managed_data_5.ttl"]
      load_files(schema_files, data_files)
    end

    it "find, I" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = IsoManagedV2.comments(identifier: "TEST", scope: IsoNamespace.find(Uri.new(uri: "http://www.assero.co.uk/NS#BBB")))
      check_file_actual_expected(results, sub_dir, "comments_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Utility Methods" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      IsoHelpers.clear_cache
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
    end

    it "next ordinal" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V5#TH"))
      expect(ct.next_ordinal(:is_top_concept_reference)).to eq(35)
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(ct.next_ordinal(:is_top_concept_reference)).to eq(1)
    end

    it "add link" do
      item = Thesaurus::ManagedConcept.new
      item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX")
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      ct.add_link(:is_top_concept, item)
      query_string = %Q{
        SELECT ?o
        {
          #{ct.uri.to_ref} <http://www.assero.co.uk/Thesaurus#isTopConcept> ?o .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [])
      expect(query_results.by_object(:o).count).to eq(1)
      expect(query_results.by_object(:o).first.to_s).to eq("http://www.assero.co.uk/XXX")
    end

  end

end