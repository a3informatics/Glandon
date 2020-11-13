require 'rails_helper'

describe IsoManagedV2::UriManagement do

	include DataHelpers

	def sub_dir
    return "models/iso_managed_v2/uri_management"
  end

  describe "basic tests" do

    before :each do
      load_files(schema_files, [])
      @uris = []
      (1..4).each do |x|
        @uris << {old: Uri.new(uri: "http://www.assero.co.uk/A#old#{x}"), new: Uri.new(uri: "http://www.assero.co.uk/A#new#{x}")}
      end
    end

    it "modified uris as ids" do
      item = IsoManagedV2.new
      expect(item.modified_uris_as_ids).to eq({})
      item.add_modified_uri(@uris[0][:old], @uris[0][:new])
      item.add_modified_uri(@uris[1][:old], @uris[1][:new])
      check_file_actual_expected(item.modified_uris_as_ids, sub_dir, "modified_ids_expected_1.yaml", equate_method: :hash_equal)
      item.add_modified_uri(@uris[2][:old], @uris[2][:new])
      item.add_modified_uri(@uris[3][:old], @uris[3][:new])
      check_file_actual_expected(item.modified_uris_as_ids, sub_dir, "modified_ids_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end