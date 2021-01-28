require 'rails_helper'

describe ManagedCollection do

  include DataHelpers
  include SparqlHelpers
  include PublicFileHelpers
  include IsoManagedHelpers
  include IsoManagedHelpers
  include SdtmSponsorDomainFactory
  include BiomedicalConceptInstanceFactory

  def sub_dir
    return "models/managed_collection"
  end

  describe "Basic Tests" do

    before :all do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "initialised" do
      item = ManagedCollection.new
      check_file_actual_expected(item.to_h, sub_dir, "new_expected_1.yaml", equate_method: :hash_equal)
    end

    it "validity - error" do
      item = ManagedCollection.new
      valid = item.valid?
      expect(valid).to eq(false)
      expect(item.errors.count).to eq(3)
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier empty object, and Has state empty object")
    end

    it "validity" do
      item = ManagedCollection.new
      ra = IsoRegistrationAuthority.find(Uri.new(uri:"http://www.assero.co.uk/RA#DUNS123456789"))
      item.has_state = IsoRegistrationStateV2.new
      item.has_state.uri = "na"
      item.has_state.by_authority = ra
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.uri = "na"
      item.has_identifier.identifier = "HELLO WORLD"
      item.has_identifier.semantic_version = "0.1.0"
      item.uri = "xxx"
      valid = item.valid?
      expect(item.errors.count).to eq(0)
      expect(valid).to eq(true)
    end

    it "collection" do
      item_1 = ManagedCollection.create(label: "Item 1", identifier: "ITEM1")
      item_2 = ManagedCollection.create(label: "Item 2", identifier: "ITEM2")
      item_3 = ManagedCollection.create(label: "Item 3", identifier: "ITEM3")
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      parent.has_managed << item_2
      parent.has_managed << item_3
      check_file_actual_expected(parent.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add item Tests" do

    before :all do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "add items" do
      item_1 = ManagedCollection.create(label: "Item 1", identifier: "ITEM1")
      item_2 = ManagedCollection.create(label: "Item 2", identifier: "ITEM2")
      item_3 = ManagedCollection.create(label: "Item 3", identifier: "ITEM3")
      item_4 = ManagedCollection.create(label: "Item 4", identifier: "ITEM4")
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      parent.add_item([item_2.id, item_3.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.to_h, sub_dir, "add_item_expected_1a.yaml", equate_method: :hash_equal)
      parent.add_item([item_4.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.to_h, sub_dir, "add_item_expected_1b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Remove item Tests" do

    before :all do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "remove items" do
      item_1 = ManagedCollection.create(label: "Item 1", identifier: "ITEM1")
      item_2 = ManagedCollection.create(label: "Item 2", identifier: "ITEM2")
      item_3 = ManagedCollection.create(label: "Item 3", identifier: "ITEM3")
      item_4 = ManagedCollection.create(label: "Item 4", identifier: "ITEM4")
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      parent.add_item([item_2.id, item_3.id, item_4.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      parent.remove_item([item_3.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.to_h, sub_dir, "remove_item_expected_1a.yaml", equate_method: :hash_equal)
      parent.remove_item([item_2.id, item_4.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.to_h, sub_dir, "remove_item_expected_1b.yaml", equate_method: :hash_equal)
    end

  end

  describe "Managed Tests" do

    before :all do
      IsoHelpers.clear_cache
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
      delete_all_public_test_files
    end

    it "managed" do
      item_1 = ManagedCollection.create(label: "Item 1", identifier: "ITEM1")
      item_2 = ManagedCollection.create(label: "Item 2", identifier: "ITEM2")
      item_3 = ManagedCollection.create(label: "Item 3", identifier: "ITEM3")
      item_4 = ManagedCollection.create(label: "Item 4", identifier: "ITEM4")
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      parent.add_item([item_2.id, item_3.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.managed, sub_dir, "managed_expected_1a.yaml", equate_method: :hash_equal)
      parent.add_item([item_4.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/ITEM1/V1#MC"))
      check_file_actual_expected(parent.managed, sub_dir, "managed_expected_1b.yaml", equate_method: :hash_equal)
    end

    it "managed" do
      item_1 = ManagedCollection.create(label: "MC 2", identifier: "MC1")
      domain = create_sdtm_sponsor_domain("AAA", "SDTM Sponsor Domain", "AA")
      bc_1 = create_biomedical_concept_instance("BMI", "BMI")
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/MC1/V1#MC"))
      parent.add_item([domain.id, bc_1.id])
      parent = ManagedCollection.find_full(Uri.new(uri: "http://www.s-cubed.dk/MC1/V1#MC"))
      check_file_actual_expected(parent.managed, sub_dir, "managed_expected_2.yaml", equate_method: :hash_equal, write_file: true)
    end

    

  end

end