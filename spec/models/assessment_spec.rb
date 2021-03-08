require 'rails_helper'

describe Assessment do

  include DataHelpers
  include SparqlHelpers
  include TimeHelpers
  include PublicFileHelpers
  include CdiscCtHelpers
  include IsoManagedHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/assessment"
  end

  describe "Main Tests" do

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    after :all do
      delete_all_public_test_files
    end

    it "initialised" do
      item = Assessment.new
      check_file_actual_expected(item.to_h, sub_dir, "new_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "validity - error" do
      item = Assessment.new
      valid = item.valid?
      expect(valid).to eq(false)
      expect(item.errors.count).to eq(3)
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier: Empty object, and Has state: Empty object")
    end

    it "validity" do
      item = Assessment.new
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
      item_1 = Assessment.create(label: "Item 1", identifier: "ITEM1")
      item_2 = Assessment.create(label: "Item 2", identifier: "ITEM2")
      item_3 = Assessment.create(label: "Item 3", identifier: "ITEM3")
      parent = Assessment.find_full(Uri.new(uri: "http://www.acme-pharma.com/ITEM1/V1#ASS"))
      parent.has_managed << item_2
      parent.has_managed << item_3
      check_file_actual_expected(parent.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end
