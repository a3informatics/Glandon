require 'rails_helper'

describe Fuseki::Persistence do
  
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/concerns/fuseki/persistence"
  end

  describe Fuseki::Persistence do

    before :all do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_managed_data_6.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "creates an object, default uri" do
      result = FusekiBaseHelpers::TestAdministeredItem.create(organization_identifier: "CCC", international_code_designator: "123")
      expect(result.errors.count).to eq(0)
      expect(result.uri.to_s).to eq("http://www.assero.co.uk/RA")
    end

    it "creates an object, parent uri" do
      uri = Uri.new(uri: "http://www.exampel.com/a#1")
      result = FusekiBaseHelpers::TestAdministeredItem.create(organization_identifier: "CCC", international_code_designator: "123", parent_uri: uri)
      expect(result.errors.count).to eq(0)
      expect(result.uri.to_s).to eq(uri.to_s)
    end

    it "creates an object, uri not set" do
      expect{FusekiBaseHelpers::TestScopedIdentifier.create}.to raise_error(Errors::ApplicationLogicError, "Exception setting URI.")
    end

    it "check validation, uri" do
      uri = Uri.new(uri: "http://www.assero.co.uk/XXX/V1#A")
      result = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri)
      expect(result.errors.count).to eq(0)
      result = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri)
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("http://www.assero.co.uk/XXX/V1#A already exists in the database")
    end

    it "find, simple case" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      result = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(result.change_description).to eq("Creation")
      expect(result.has_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
      expect(result.has_state.to_s).to eq("http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1")
    end

    it "find with cache" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#BBB")
      expect(Fuseki::Base.cache_has_key?(uri)).to eq(false)
      result = IsoNamespace.find(uri)
      expect(result.name).to eq("BBB Pharma")
      expect(Fuseki::Base.cache_has_key?(uri)).to eq(true)
      result = IsoNamespace.find(uri)
      expect(result.name).to eq("BBB Pharma")
    end

    it "find children" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      result = FusekiBaseHelpers::TestAdministeredItem.find_children(uri)
      check_file_actual_expected(result.to_h, sub_dir, "find_children_expected_1.yaml", equate_method: :hash_equal)
    end

    it "finds objects and links, single" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      result = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(result.change_description).to eq("Creation")
      expect(result.has_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
      expect(result.has_identifier_links?).to eq(true)
      expect(result.has_identifier_objects?).to eq(false)
      result.has_identifier_objects
      expect(result.has_identifier_links?).to eq(true)
      expect(result.has_identifier_objects?).to eq(true)
      expect(result.has_identifier.first.identifier).to eq("TEST")
    end

    it "finds objects and links, array" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      result = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(result.change_description).to eq("Creation")
      expect(result.has_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
      expect(result.has_identifier_links?).to eq(true)
      expect(result.has_identifier_objects?).to eq(false)
      result.has_identifier_objects
      expect(result.has_identifier_links?).to eq(true)
      expect(result.has_identifier_objects?).to eq(true)
      expect(result.has_identifier.first.identifier).to eq("TEST")
    end

    it "clones an object" do
      uri = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      item = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      result = item.clone
      expect(result.change_description).to eq("Creation")
      expect(result.has_identifier.first.to_s).to eq("http://www.assero.co.uk/MDRItems#SI-ACME_TEST-1")
      expect(result.has_state.to_s).to eq("http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1")
    end

    it "returns the true type" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      expect(item.true_type.to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
      expect(item.my_type.to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
      expect(Fuseki::Base.the_type(uri).to_s).to eq("http://www.assero.co.uk/ISO11179Identification#Namespace")
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAAxxx")
      expect{Fuseki::Base.the_type(uri)}.to raise_error(Errors::ApplicationLogicError, "Unable to find the RDF type for http://www.assero.co.uk/NS#AAAxxx.")
      expect_any_instance_of(Sparql::Query).to receive(:query).and_return([])
      expect{item.true_type}.to raise_error(Errors::ApplicationLogicError, "Unable to find true type for http://www.assero.co.uk/NS#AAA.")
    end

    it "same type" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_TEST")
      expect(Fuseki::Base.same_type([uri_1, uri_1], IsoNamespace.rdf_type)).to eq(true)
      expect(Fuseki::Base.same_type([uri_1, uri_2], IsoNamespace.rdf_type)).to eq(false)
      expect_any_instance_of(Sparql::Query).to receive(:query).and_return([])
      expect{Fuseki::Base.same_type([uri_1, uri_1], IsoNamespace.rdf_type)}.to raise_error(Errors::ApplicationLogicError, "Unable to find the RDF type for the set of URIs.")
    end

    it "generates selective update sparql" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      item.name = "Updated Name Property"
      sparql = Sparql::Update.new
      actual = item.to_selective_sparql(sparql)
      expect(sparql.to_triples).to eq("<http://www.assero.co.uk/NS#AAA> isoI:name \"Updated Name Property\"^^xsd:string . \n")
      expect(actual).to match_array([Uri.new(uri: "http://www.assero.co.uk/ISO11179Identification#name")])
    end

    it "performs selective update" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      item.name = "Updated Name Property"
      item.selective_update
      result = IsoNamespace.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "selective_update_expected_1.yaml", equate_method: :hash_equal)
      item.name = "Updated Name Property, a further update"
      item.short_name = "Modified Short Name"
      item.selective_update
      result = IsoNamespace.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "selective_update_expected_2.yaml", equate_method: :hash_equal)
    end

    it "performs update" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      item.name = "Updated Name Property"
      result = item.update
      expect(result.errors.count).to eq(0)
      result = IsoNamespace.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
      item.name = "Updated Name Property, a further update±±±±±"
      result = item.update
      expect(result.errors.count).to eq(1)
      item.name = "Updated Name Property, a further update"
      item.short_name = "ShortName"
      result = item.update
      expect(result.errors.count).to eq(0)
    end

    it "performs update" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      item.name = "Updated Name Property, a further update±±±±±"
      result = item.update
      expect(result.errors.count).to eq(1)
      item.name = "Updated Name Property, a further update"
      item.short_name = "ShortName"
      result = item.update
      expect(result.errors.count).to eq(0)
      item.name = "Updated Name Property, a further update±±±±±"
      result = item.update
      expect(result.errors.count).to eq(1)
    end

    it "performs save I" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      item.name = "Updated Name Property"
      result = item.save
      expect(result.errors.count).to eq(0)
      result = IsoNamespace.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "save_expected_1.yaml", equate_method: :hash_equal)
      item.name = "Updated Name Property, a further update±±±±±"
      result = item.save
      expect(result.errors.count).to eq(1)
      item.name = "Updated Name Property, a further update"
      item.short_name = "ShortName"
      result = item.save
      expect(result.errors.count).to eq(0)
      item = IsoNamespace.new
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#SaveTest")
      item.uri = uri
      item.name = "Save Test"
      item.short_name = "SaveTest"
      item.authority = "www.a3.com"
      item.save
      result = IsoNamespace.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "save_expected_2.yaml", equate_method: :hash_equal)
      item = IsoNamespace.new
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#SaveTest2")
      item.uri = uri
      item.name = "Save Test"
      item.short_name = "SaveTest±±±±±±±"
      item.authority = "www.a3.com"
      result = item.save
      expect(result.errors.count).to eq(1)
      expect(result.errors.full_messages.to_sentence).to eq("Short name contains invalid characters")
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item.errors.clear
      item = IsoNamespace.new(uri: uri, name: "A name", short_name: "SaveTest", authority: "www.a3.com") # Try to create same short_name, should fail.
      result = item.save
      expect(result.errors.count).to eq(2)
      expect(result.errors.full_messages.to_sentence).to eq("http://www.assero.co.uk/NS#AAA already exists in the database and an existing record (short_name: SaveTest) exisits in the database")
    end

    it "performs save II" do
      uri = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789")
      item = IsoRegistrationAuthority.find(uri)
      item.owner = false
      result = item.save
      expect(result.errors.count).to eq(0)
      item = IsoRegistrationAuthority.find(uri)
      check_file_actual_expected(result.to_h, sub_dir, "save_expected_3.yaml", equate_method: :hash_equal)
      item.ra_namespace = Uri.new(uri: "http://www.assero.co.uk/RA#DUNS33333333")
      result = item.save
      expect(result.errors.count).to eq(0)
    end

    it "id and uuid" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
      item = IsoNamespace.find(uri)
      expect(item.id).to eq(uri.to_id)
      expect(item.uuid).to eq(uri.to_id)
    end

    it "persisted" do
      item = IsoNamespace.new
      expect(item.inspect_persistence).to eq({new: true, destroyed: false})
      expect(item.persisted?).to eq(false)
      expect(item.new_record?).to eq(true)
      expect(item.destroyed?).to eq(false)
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAAPer")
      item = IsoNamespace.new(uri: uri, name: "A name", short_name: "SaveTest", authority: "www.a3.com") # Try to create same short_name, should fail.
      item = item.save
      expect(item.inspect_persistence).to eq({new: false, destroyed: false})
      expect(item.persisted?).to eq(true)
      expect(item.new_record?).to eq(false)
      expect(item.destroyed?).to eq(false)
      item.delete
      expect(item.inspect_persistence).to eq({new: false, destroyed: true})
      expect(item.persisted?).to eq(false)
      expect(item.new_record?).to eq(false)
      expect(item.destroyed?).to eq(true)
    end

    it "deletes object with reference links" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/FP3#1")
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/FP3#2")
      item_1 = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri_1)
      item_2 = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri_2)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      item_2_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_2)    
      expect(item_1_c.has_identifier.count).to eq(0)
      expect(item_2_c.has_identifier.count).to eq(0)
      item_1.add_link(:has_identifier, item_2.uri)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      expect(item_1_c.has_identifier.count).to eq(1)
      expect(item_2.delete_with_links).to eq(1)
      expect{FusekiBaseHelpers::TestAdministeredItem.find(uri_2)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/FP3#2 in FusekiBaseHelpers::TestAdministeredItem.")
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      expect(item_1_c.has_identifier.count).to eq(0)
    end

    it "add, remove and replace link" do
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/FP3#1")
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/FP3#2")
      uri_3 = Uri.new(uri: "http://www.assero.co.uk/FP3#2")
      item_1 = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri_1)
      item_2 = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri_2)
      item_3 = FusekiBaseHelpers::TestAdministeredItem.create(uri: uri_3)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      item_2_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_2)    
      item_3_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_3)    
      expect(item_1_c.has_identifier.count).to eq(0)
      expect(item_2_c.has_identifier.count).to eq(0)
      item_1.add_link(:has_identifier, uri_2)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      expect(item_1_c.has_identifier.count).to eq(1)
      expect(item_1_c.has_identifier).to eq([uri_2])
      item_1.replace_link(:has_identifier, uri_2, uri_3)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      expect(item_1_c.has_identifier.count).to eq(1)
      expect(item_1_c.has_identifier).to eq([uri_3])
      item_1.delete_link(:has_identifier, uri_3)
      item_1_c = FusekiBaseHelpers::TestAdministeredItem.find(uri_1)
      expect(item_1_c.has_identifier.count).to eq(0)
    end

  end      

  describe "save tests" do
    
    it "save aray of objects" do
      uri = Uri.new(uri: "http://www.assero.co.uk/NS#111")
      item = FusekiBaseHelpers::TestAdministeredItem.create(change_description: "xxx", uri: uri)
      item.save
      item = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(item.has_identifier.count).to eq(0)
      item.has_identifier_push Uri.new(uri: "http://www.assero.co.uk/NS#AAA111")
      item.save
      item = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(item.has_identifier.count).to eq(1)
      item.has_identifier_push Uri.new(uri: "http://www.assero.co.uk/NS#AAA222")
      item.has_identifier_push Uri.new(uri: "http://www.assero.co.uk/NS#AAA333")
      item.save
      item = FusekiBaseHelpers::TestAdministeredItem.find(uri)
      expect(item.has_identifier.count).to eq(3)      
      expect(item.has_identifier.map{|x| x.to_s}).to match_array(["http://www.assero.co.uk/NS#AAA111", "http://www.assero.co.uk/NS#AAA222", "http://www.assero.co.uk/NS#AAA333"])
    end

  end

  describe "transaction tests" do
    
    it "begin and active?" do
      item = FusekiBaseHelpers::TestAdministeredItem.new
      expect(item.transaction_active?).to eq(false)
      expect(item.transaction_not_active?).to eq(true)
      expect_any_instance_of(Sparql::Transaction).to receive(:register).with(item)
      result = item.transaction_begin
      expect(item.transaction_active?).to eq(true)
      expect(item.transaction_not_active?).to eq(false)
      expect(result).to_not be(nil)
      expect_any_instance_of(Sparql::Transaction).to receive(:register).with(item)
      expect(item.transaction_begin).to eq(result)
    end

    it "set" do
      item_1 = FusekiBaseHelpers::TestAdministeredItem.new
      expect_any_instance_of(Sparql::Transaction).to receive(:register).with(item_1)
      result = item_1.transaction_begin
      item_2 = FusekiBaseHelpers::TestAdministeredItem.new
      expect_any_instance_of(Sparql::Transaction).to receive(:register).with(item_2)
      expect(item_2.transaction_set(result)).to eq(result)
    end

    it "execute" do
      item = FusekiBaseHelpers::TestAdministeredItem.new
      result = item.transaction_begin
      expect_any_instance_of(Sparql::Transaction).to receive(:execute)
      expect(item.transaction_execute).to eq(result)
      expect(item.transaction_execute(false)).to eq(result)
    end

    it "clears" do
      item = FusekiBaseHelpers::TestAdministeredItem.new
      expect(item.transaction_clear).to be(nil)
      expect(item.new_record?).to be(false)
      expect(item.properties.saved?).to be(true)
    end

  end

end