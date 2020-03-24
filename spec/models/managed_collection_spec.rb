require 'rails_helper'

describe ManagedCollection do

  include DataHelpers
  include SparqlHelpers
  include TimeHelpers
  include PublicFileHelpers
  include CdiscCtHelpers
  include IsoManagedHelpers
  include ThesauriHelpers
  include IsoManagedHelpers

  def sub_dir
    return "models/managed_collection"
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

    it "allows an object to be initialised" do
      item = ManagedCollection.new
      check_file_actual_expected(item.to_h, sub_dir, "new_expected_1.yaml", equate_method: :hash_equal)
    end

    it "allows validity of the object to be checked - error" do
      item = ManagedCollection.new
      valid = item.valid?
      expect(valid).to eq(false)
      expect(item.errors.count).to eq(3)
      expect(item.errors.full_messages.to_sentence).to eq("Uri can't be blank, Has identifier: Empty object, and Has state: Empty object")
    end

    it "allows validity of the object to be checked" do
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

    # it "allows a Thesaurus to be found" do
    #   item = ManagedCollection.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
    #   check_file_actual_expected(item.to_h, sub_dir, "find_expected_1.yaml", equate_method: :hash_equal)
    # end

  end

end
