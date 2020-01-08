require 'rails_helper'

describe "IsoManagedV2" do

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
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_managed_data_4.ttl"]
      load_files(schema_files, data_files)
    end

  	it "validates a valid object, general" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
      expect(item.valid?).to eq(true)
    end

    it "validates a valid object, markdown" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
      item.origin = vh_all_chars
      item.explanatory_comment  = vh_all_chars
      item.change_description = vh_all_chars
      expect(item.valid?).to eq(true)
    end

    it "does not validate an invalid object" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
      item.origin = "£"
      result = item.valid?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Origin contains invalid markdown")
    end

    it "does not validate an invalid object" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
      item.explanatory_comment  = "£"
      result = item.valid?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Explanatory comment contains invalid markdown")
    end

    it "does not validate an invalid object" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
      item.change_description = "£"
      result = item.valid?
      expect(result).to eq(false)
      expect(item.errors.full_messages.to_sentence).to eq("Change description contains invalid markdown")
    end

    it "does not validate an invalid object" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_with_properties(uri)
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
          :id => nil, 
          tagged: []
      	}
  		item = IsoManagedV2.new
      expect(item.to_h).to eq(result)
  	end

    it "allows the version, semantic_version, version_label and indentifier to be found" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.version).to eq(1)   
      expect(item.semantic_version.to_s).to eq("1.2.3")   
      expect(item.version_label).to eq("0.1")   
      expect(item.scoped_identifier).to eq("TEST")   
    end

    it "allows the latest, later, earlier and same version to be assessed" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.latest?).to eq(false)   
      expect(item.later_version?(0)).to eq(true)   
      expect(item.later_version?(1)).to eq(false)   
      expect(item.earlier_version?(1)).to eq(false)   
      expect(item.earlier_version?(2)).to eq(true)   
      expect(item.same_version?(1)).to eq(true)   
      expect(item.same_version?(2)).to eq(false)   
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.latest?).to eq(true)   
    end

    it "allows owner and owned? to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.owner.organization_identifier).to eq("123456789")   
      expect(item.owned?).to eq(true)
    end

    it "allows registration status and registered to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.registration_status).to eq("Standard")   
      expect(item.registered?).to eq(true)   
    end

    it "allows edit, state on edit and delete status to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.edit?).to eq(true)   
      expect(item.state_on_edit).to eq("Incomplete")
      expect(item.delete?).to eq(true)   
    end

    it "allows current and can be current status to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find_full(uri)
      expect(item.current?).to eq(false)   
      expect(item.can_be_current?).to eq(false)   
    end

    it "allows new_version, next_version, next_semantic_version, and first_version to be determined" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
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
      expect{IsoManagedV2.find_with_properties(Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#XXX"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/MDRForms/ACME/V1#XXX in IsoManagedV2.")
    end

    it "allows the item to be updated" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_full(uri)
      result = item.to_h
      result[:explanatory_comment] = "New comment"
      result[:change_description] = "Description"
      result[:origin] = "Origin"
      item.update({:explanatory_comment => "New comment", :change_description => "Description", :origin => "Origin"})
      item = IsoManagedV2.find_with_properties(uri)
      result[:last_change_date] = item.last_change_date.iso8601
      expect(item.to_h).to eq(result)
    end

    it "finds latest" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      result = IsoManagedV2.latest({:identifier => "TEST", :scope => IsoRegistrationAuthority.owner.ra_namespace})
      expect(result.version).to eq(3)
      result = IsoManagedV2.latest({:identifier => "TESTx", :scope => IsoRegistrationAuthority.owner.ra_namespace}) # Invalid identifier
      expect(result).to be_nil
    end

    it "check is latest" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V3#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.latest?).to eq(true)
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V2#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      expect(item.latest?).to eq(false)
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
      item = IsoManagedV2.find_minimum(uri)
      new_item = IsoManagedV2.from_h(item.to_h)
      expect(item.to_h).to eq(new_item.to_h)
    end

    it "permits the item to be exported as JSON" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = IsoManagedV2.find_minimum(uri)
      check_file_actual_expected(item.to_h, sub_dir, "to_json_1.yaml", equate_method: :hash_equal)
    end

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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_managed_data_4.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    end

    it "find full, I" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = IsoManagedV2.find_full(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_full_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find full, II" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = CdiscTerm.find_full(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_full_expected_2.yaml", equate_method: :hash_equal)
    end

    it "find full, III, speed" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      timer_start
      (1..100).each {|x| results = CdiscTerm.find_full(uri)}
      timer_stop("Find Full 100 times [8.29s -> 6.48s]")
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
      timer_stop("Find Minimum 100 times [1.65s -> 1.25s]")
    end

    it "find properties I" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      results = IsoManagedV2.find_with_properties(uri)
      check_file_actual_expected(results.to_h, sub_dir, "find_properties_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find properties II, speed" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      timer_start
      (1..100).each {|x| results = CdiscTerm.find_with_properties(uri)}
      timer_stop("Find Properties 100 times [1.65s]")
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

    it "where full, I" do
      uri = Uri.new(uri: "http://www.cdisc.org/C64388/V1#C64388")
      th = Thesaurus::ManagedConcept.find_minimum(uri)
      results = th.where_full({"<http://www.assero.co.uk/Thesaurus#identifier>" => "C49399"})
      check_file_actual_expected(results, sub_dir, "where_full_expected_1.yaml", equate_method: :hash_equal)
      results = th.where_full({"<http://www.assero.co.uk/Thesaurus#identifier>" => "C49399", "<http://www.assero.co.uk/Thesaurus#notation>" => "CONGENITAL, FAMILIAL AND GENETIC DISORDERS"})
      check_file_actual_expected(results, sub_dir, "where_full_expected_2.yaml", equate_method: :hash_equal)
      results = th.where_full({"<http://www.assero.co.uk/Thesaurus#identifier>" => "C49399", "<http://www.assero.co.uk/Thesaurus#notation>" => "CONGENITAL, xxx FAMILIAL AND GENETIC DISORDERS"})
      check_file_actual_expected(results, sub_dir, "where_full_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "History Pagination" do

    before :all do
      IsoHelpers.clear_cache
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
      results = []
      actual = CdiscTerm.history_pagination(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope, count: 10, offset: 20)
      expect(actual.count).to eq(10)
      actual.each {|x| results << x.to_h}
      check_file_actual_expected(results, sub_dir, "history_pagination_expected_2.yaml", equate_method: :hash_equal)
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

    it "history previous next" do
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_n = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      item = CdiscTerm.find_minimum(uri)
      expect(item.history_previous).to eq(nil)
      expect(item.history_next.uri).to eq(uri_n)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      uri_p = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_n = Uri.new(uri: "http://www.cdisc.org/CT/V3#TH")
      item = CdiscTerm.find_minimum(uri)
      expect(item.history_previous.uri).to eq(uri_p)
      expect(item.history_next.uri).to eq(uri_n)
    end

  end

  describe "Unique" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
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
      index = CdiscTerm.unique.map{|x| {label: x[:label], identifier: x[:identifier]}}
      check_file_actual_expected(index, sub_dir, "unique_expected_1.yaml", equate_method: :hash_equal)
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

    it "unique speed - WILL CURRENTLY FAIL - fails when run as set." do
      (1..500).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/ITEM#{index}/V1")
        item.label = "Item"
        item.set_import(identifier: "ITEM #{index}", version_label: "#{index}", semantic_version: "#{index}.0.0", version: "#{index}", date: "2019-01-01", ordinal: index)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
      end 
      timer_start
      index = CdiscTerm.unique
      timer_stop("Unique")
    puts colourize("***** ISO Managed count: #{index.count} *****", "red")
      expect(index.count).to eq(500)
    end

  end

  describe "Create" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
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
      object = Thesaurus.find_full(object.uri)
      check_dates(object, sub_dir, "create_expected_1b.yaml", :last_change_date, :creation_date)
      check_file_actual_expected(object.to_h, sub_dir, "create_expected_1b.yaml", equate_method: :hash_equal)
    end

    it "create, not valid, label" do
      object = Thesaurus.create({label: "A new item±±", identifier: "XXXXX"})
      expect(object.errors.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Label contains invalid characters")
    end

    it "create, not valid, identifier" do
      object = Thesaurus.create({label: "A new item", identifier: "XXXXX$"})
      expect(object.errors.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Has identifier: Identifier contains invalid characters")
    end

    it "create, not permitted" do
      expect(IsoScopedIdentifierV2).to receive(:exists?).and_return(true)
      object = Thesaurus.create({label: "A new item", identifier: "XXXXX"})
      expect(object.errors.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("The item cannot be created. The identifier is already in use.")
    end

    it "create next version" do
      actual = Thesaurus.create({label: "A new item", identifier: "NEW1"})
      expect(actual.errors.count).to eq(0)
      file = "create_next_version_1.yaml"
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)
      
      object = Thesaurus.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/NEW1/V1#TH"))
      object.has_state.registration_status = IsoRegistrationStateV2.released_state
      object.explanatory_comment = "A comment"
      object.change_description = "A description"
      object.origin = "A ref"
      actual = object.create_next_version
      expect(object.uri).to_not eq(actual.uri) # New item
      file = "create_next_version_2.yaml"
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)
      
      object = Thesaurus.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/NEW1/V2#TH"))
      object.has_state.registration_status = "Qualified"
      object.explanatory_comment = "Another comment"
      actual = object.create_next_version
      expect(object.uri).to_not eq(actual.uri) # New item
      file = "create_next_version_3.yaml"
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)

      object = Thesaurus.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/NEW1/V3#TH"))
      object.has_state.multiple_edit = true
      actual = object.create_next_version
      expect(object.uri).to eq(actual.uri) # Same item, multiple edit
      file = "create_next_version_4.yaml"
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)

      object = Thesaurus.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/NEW1/V3#TH"))
      object.has_state.multiple_edit = false
      actual = object.create_next_version
      expect(object.uri).to_not eq(actual.uri) # New item, no multiple edit
      file = "create_next_version_5.yaml"
      check_dates(actual, sub_dir, file, :creation_date, :last_change_date)
      check_file_actual_expected(actual.to_h, sub_dir, file, equate_method: :hash_equal)
    end

  end

  describe "Create Permitted" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
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

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
    end

    it "next ordinal" do
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V5#TH"))
      expect(ct.next_ordinal(:is_top_concept_reference)).to eq(35)
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(ct.next_ordinal(:is_top_concept_reference)).to eq(1)
    end

    it "allows the current set to be found" do
      (1..10).each do |index|
        item = CdiscTerm.new
        #item.uri = Uri.new(uri: "http://www.assero.co.uk/X#{index}/V1")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM#{index}", version_label: "1", semantic_version: "1.0.0", version: "1", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
      end 
      item = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/ITEM1/V1#TH"))
      item.has_state.make_current
      expect(CdiscTerm.current_set.count).to eq(2)
      item = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/ITEM2/V1#TH"))
      item.has_state.make_current
      expect(CdiscTerm.current_set.count).to eq(3)
      item = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/ITEM3/V1#TH"))
      item.has_state.make_current
      expect(CdiscTerm.current_set.count).to eq(4)
    end

    it "finds lastest and current parent" do
      uri_v7 = Uri.new(uri: "http://www.cdisc.org/CT/V7#TH")
      uri_v10 = Uri.new(uri: "http://www.cdisc.org/CT/V10#TH")
      tc = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66789/V4#C66789"))
      results = tc.current_and_latest_parent 
      check_file_actual_expected(results, sub_dir, "current_and_latest_parent_expected_1.yaml", equate_method: :hash_equal)
      item = CdiscTerm.find_minimum(uri_v7)
      item.has_state.make_current
      results = tc.current_and_latest_parent 
      check_file_actual_expected(results, sub_dir, "current_and_latest_parent_expected_2.yaml", equate_method: :hash_equal)
    end

    it "sets latest and current set" do
      results = CdiscTerm.current_and_latest_set
      check_file_actual_expected(results, sub_dir, "current_and_latest_set_expected_1.yaml", equate_method: :hash_equal)
      item = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V7#TH"))
      item.has_state.make_current
      results = CdiscTerm.current_and_latest_set
      check_file_actual_expected(results, sub_dir, "current_and_latest_set_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Delete" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..3)
    end

    it "delete" do
      results = Thesaurus.all
      expect(results.count).to eq(4)
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(ct.delete).to eq(1)
      results = Thesaurus.all
      expect(results.count).to eq(3)
    end

    it "delete minimum" do
      results = Thesaurus.all
      expect(results.count).to eq(4)
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1#TH-SPONSOR_CT-1"))
      expect(ct.delete_minimum).to eq(1)
      results = Thesaurus.all
      expect(results.count).to eq(3)
    end

  end

  describe "Status" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
    end

    it "allows the item status to be updated, not standard" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      item = IsoManagedV2.find_minimum(uri)
      params = {}
      params[:registration_status] = "Qualified"
      params[:previous_state] = "Recorded"
      params[:administrative_note] = "New note"
      params[:unresolved_issue] = "Unresolved issues"
      item.update_status(params)
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(item.errors.count).to eq(0)
      actual = IsoManagedV2.find_minimum(uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows the item status to be updated, error" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      item = IsoManagedV2.find_minimum(uri)
      params = {}
      params[:registration_status] = "SomethingNew"
      params[:previous_state] = "SomethingOld"
      params[:administrative_note] = "New note"
      params[:unresolved_issue] = "Unresolved issues"
      item.update_status(params)
      expect(item.errors.full_messages.to_sentence).to eq("Registration Status: Registration status is invalid and Registration Status: Previous state is invalid")
      expect(item.errors.count).to eq(2)
      actual = IsoManagedV2.find_minimum(uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_2.yaml", equate_method: :hash_equal)
    end

    it "allows the item status to be updated, standard" do
      uri = Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH")
      item = IsoManagedV2.find_minimum(uri)
      params = {}
      params[:registration_status] = "Standard"
      params[:previous_state] = "Qualified"
      params[:administrative_note] = "New note"
      params[:unresolved_issue] = "Unresolved issues"
      item.update_status(params)
      actual = IsoManagedV2.find_minimum(uri)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Release" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
      load_files(schema_files, data_files)
    end

    def set_state(object, state)
      object.has_state.registration_status = state
      object.has_state.save
    end

    def set_semantic_version(object, semantic_version)
      object.has_identifier.semantic_version = semantic_version
      object.has_identifier.save
    end

    def set_semantic_version_and_state(object, semantic_version, state)
      set_semantic_version(object, semantic_version)
      set_state(object, state)
    end

    # it "find the previous release at standard" do
    #   uris = []
    #   (1..10).each do |index|
    #     item = CdiscTerm.new
    #     item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
    #     item.label = "Item #{index}"
    #     item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
    #     sparql = Sparql::Update.new  
    #     item.to_sparql(sparql, true)
    #     sparql.upload
    #     uris[index-1] = item.uri
    #   end 
    #   last_item = Thesaurus.find_minimum(uris[9])
    #   uris.each_with_index do |x, index| 
    #     item = Thesaurus.find_minimum(x)
    #     set_state(item, "Qualified" )
    #     set_semantic_version(item, "#{index + 1}.0.0" )
    #   end
    #   result = last_item.previous_release
    #   expect(result).to eq("1.0.0")

    #   item = Thesaurus.find_minimum(uris[0])
    #   set_semantic_version_and_state(item, "0.1.0", "Incomplete")
    #   result = item.previous_release
    #   expect(result).to eq("0.1.0")

    #   item = Thesaurus.find_minimum(uris[4])
    #   set_semantic_version_and_state(item, "5.1.0", "Standard")
    #   result = item.previous_release
    #   expect(result).to eq("5.1.0")
    # end

    it "find the previous release at standard" do
      uris = []
      (1..10).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
        uris[index-1] = item.uri
      end 
      last_item = Thesaurus.find_minimum(uris[9])
      uris.each_with_index do |x, index| 
        item = Thesaurus.find_minimum(x)
        set_state(item, "Qualified" )
        set_semantic_version(item, "#{index + 1}.0.0" )
      end
      result = last_item.previous_release
      expect(result).to eq("1.0.0")
   
      item = Thesaurus.find_minimum(uris[0])
      set_semantic_version_and_state(item, "0.1.0", "Incomplete")
      result = item.previous_release
      expect(result).to eq("0.1.0")
     
      item = Thesaurus.find_minimum(uris[4])
      set_semantic_version_and_state(item, "5.1.0", "Standard")
      result = item.previous_release
      expect(result).to eq("5.1.0")
  
      item = Thesaurus.find_minimum(uris[9])
      result = item.previous_release
      expect(result).to eq("5.1.0")
    end

    it "find the previous_release, only one item" do
      uris = []
      (1..1).each do |index|
        item = CdiscTerm.new
        item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
        uris[index-1] = item.uri
      end 
      item = Thesaurus.find_minimum(uris[0])
      set_state(item,"Incomplete")
      result = item.previous_release
      expect(result).to eq("0.1.0")
    end

    it "allows the item release to be incremented, one version, state Incomplete" do
      load_cdisc_term_versions(1..1)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Incomplete"
      expect(item.semantic_version).to eq("1.0.0")
      item.release(:major)
      expect(item.errors.full_messages.to_sentence).to eq("The release cannot be updated in the current state")
      expect(item.errors.count).to eq(1)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.0")
    end

    it "not allows the item release to be incremented, two versions, no latest release" do
      load_cdisc_term_versions(1..2)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      expect(item.semantic_version).to eq("1.0.0")
      item.release(:major)
      expect(item.errors.full_messages.to_sentence).to eq("Can only modify the latest release")
      expect(item.errors.count).to eq(1)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.0")
    end

    it "allows the item release to be incremented, one version, no changes" do
      load_cdisc_term_versions(1..1)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      expect(item.semantic_version).to eq("1.0.0")
      item.release(:major)
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(item.errors.count).to eq(0)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.0")
    end

    it "allows the item release to be incremented, two versions, increment major" do
      load_cdisc_term_versions(1..2)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      item.has_state.save
      item = Thesaurus.find_minimum(uri)
      expect(item.semantic_version).to eq("2.0.0")
      item.release(:major)
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(item.errors.count).to eq(0)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("2.0.0")
    end

    it "allows the item release to be incremented, two versions, increment minor" do
      load_cdisc_term_versions(1..2)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      item.has_state.save
      item = Thesaurus.find_minimum(uri)
      expect(item.semantic_version).to eq("2.0.0")
      item.release(:minor)
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(item.errors.count).to eq(0)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.0")
    end

    it "allows the item release to be incremented, two versions, increment patch" do
      load_cdisc_term_versions(1..2)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      item.has_state.save
      item = Thesaurus.find_minimum(uri)
      expect(item.semantic_version).to eq("2.0.0")
      item.release(:patch)
      expect(item.errors.full_messages.to_sentence).to eq("")
      expect(item.errors.count).to eq(0)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.1")
    end

    it "allows the item release to be incremented, two versions, increment request type invalid" do
      load_cdisc_term_versions(1..2)
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      item = Thesaurus.find_minimum(uri)
      item.has_state.registration_status = "Qualified"
      expect(item.semantic_version).to eq("2.0.0")
      item.release(:asd)
      expect(item.errors.count).to eq(1)
      expect(item.errors.full_messages.to_sentence).to eq("The release request type was invalid")
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("2.0.0")
    end

    it "allows the item release to be incremented, five versions, increment major" do
      uris = []
      (1..5).each do |index|
        item = CdiscTerm.new
        #item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
        uris[index-1] = item.uri
      end 
      uris.each_with_index do |x, index| 
        item = Thesaurus.find_minimum(x)
        set_state(item, "Qualified" )
        set_semantic_version(item, "#{index + 1}.0.0" )
      end
      item5 = Thesaurus.find_minimum(uris[4])
      item5.release(:major)
      actual5 = Thesaurus.find_minimum(uris[4])
      actual4 = Thesaurus.find_minimum(uris[3])
      actual3 = Thesaurus.find_minimum(uris[2])
      actual2 = Thesaurus.find_minimum(uris[1])
      actual1 = Thesaurus.find_minimum(uris[0])
      expect(actual5.semantic_version).to eq("2.0.0")
      expect(actual4.semantic_version).to eq("2.0.0")
      expect(actual3.semantic_version).to eq("2.0.0")
      expect(actual2.semantic_version).to eq("2.0.0")
      expect(actual1.semantic_version).to eq("1.0.0")
    end

    it "allows the item release to be incremented, eight versions, increment major" do
      uris = []
      (1..8).each do |index|
        item = CdiscTerm.new
        #item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
        item.label = "Item #{index}"
        item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
        sparql = Sparql::Update.new  
        item.to_sparql(sparql, true)
        sparql.upload
        uris[index-1] = item.uri
      end 
      uris.each_with_index do |x, index| 
        item = Thesaurus.find_minimum(x)
        set_state(item, "Qualified" )
        set_semantic_version(item, "#{index + 1}.0.0" )
      end
      item4 = Thesaurus.find_minimum(uris[3])
      set_semantic_version_and_state(item4, "4.0.0", "Standard")
      item8 = Thesaurus.find_minimum(uris[7])
      item8.release(:major)
      actual8 = Thesaurus.find_minimum(uris[7])
      actual7 = Thesaurus.find_minimum(uris[6])
      actual6 = Thesaurus.find_minimum(uris[5])
      actual5 = Thesaurus.find_minimum(uris[4])
      actual4 = Thesaurus.find_minimum(uris[3])
      expect(actual8.semantic_version).to eq("5.0.0")
      expect(actual7.semantic_version).to eq("5.0.0")
      expect(actual6.semantic_version).to eq("5.0.0")
      expect(actual5.semantic_version).to eq("5.0.0")
      expect(actual4.semantic_version).to eq("4.0.0")
    end

    it "allows the item release to be incremented, five versions, increment minor" do
      load_cdisc_term_versions(1..5)
      (1..5).each do |ver|
        uri = Uri.new(uri: "http://www.cdisc.org/CT/V#{ver}#TH")
        item = Thesaurus.find_minimum(uri)
        item.has_state.registration_status = "Qualified"
        item.has_state.save
      end
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V5#TH")
      item = Thesaurus.find_minimum(uri)
      item.release(:minor)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.0")
    end

    it "allows the item release to be incremented, five versions, increment patch" do
      load_cdisc_term_versions(1..5)
      (1..5).each do |ver|
        uri = Uri.new(uri: "http://www.cdisc.org/CT/V#{ver}#TH")
        item = Thesaurus.find_minimum(uri)
        item.has_state.registration_status = "Qualified"
        item.has_state.save
      end
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V5#TH")
      item = Thesaurus.find_minimum(uri)
      item.release(:patch)
      actual = Thesaurus.find_minimum(uri)
      expect(actual.semantic_version).to eq("1.0.1")
    end
    
  end

  describe "Tag Methods" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :all do
      IsoHelpers.clear_cache
      data_files = []
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_cdisc_term_versions(1..10)
    end

    it "items for tag" do
      tag = IsoConceptSystem.path(["CDISC", "SDTM"])
      result = IsoManagedV2.find_by_tag(tag.id)
      check_file_actual_expected(result, sub_dir, "find_by_tag_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Current Methods" do

    before :all  do
      IsoHelpers.clear_cache
    end

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
    end

    def change_current(uri)
      item = CdiscTerm.find_minimum(uri)
    puts colourize("+++++ Set +++++\nSet: #{uri}", "blue")
      item.make_current
      current_uri = CdiscTerm.current(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
    puts colourize("Current: #{current_uri}\n+++++", "blue")
      expect(current_uri).to eq(item.uri)
    end
      
    it "allows the current item to be found and to be made current" do
      current_uri = CdiscTerm.current(identifier: "CT", scope: IsoRegistrationAuthority.cdisc_scope)
      expect(current_uri).to eq(nil)
      change_current(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      change_current(Uri.new(uri: "http://www.cdisc.org/CT/V5#TH"))
      change_current(Uri.new(uri: "http://www.cdisc.org/CT/V7#TH"))
      change_current(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    end

  end

end