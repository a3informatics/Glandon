require 'rails_helper'

describe IsoManagedV2::UriManager do

	include DataHelpers

	def sub_dir
    return "models/iso_managed_v2/uri_manager"
  end

  describe "basic tests" do

    before :each do
      load_files(schema_files, [])
    end

    it "create a class, empty hash" do
      uri_manager = IsoManagedV2::UriManager.new
      check_file_actual_expected(uri_manager.to_ids, sub_dir, "new_expected_1.yaml")
    end

    it "adds uris and converts to hash" do
      uris = IsoManagedV2::UriManager.new
      old_uri_1 = Uri.new(uri: "http://www.assero.co.uk/A#old1")
      new_uri_1 = Uri.new(uri: "http://www.assero.co.uk/A#new1")
      old_uri_2 = Uri.new(uri: "http://www.assero.co.uk/A#old2")
      new_uri_2 = Uri.new(uri: "http://www.assero.co.uk/A#new2")
      uris.add(old_uri_1, new_uri_1)
      uris.add(old_uri_2, new_uri_2)
      check_file_actual_expected(uris.to_ids, sub_dir, "to_ids_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end