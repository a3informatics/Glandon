require 'rails_helper'

describe IsoManagedV2::Export do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include IsoManagedHelpers
  include PublicFileHelpers
  include SparqlHelpers

	def sub_dir
    return "models/iso_managed_v2/export"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do

      delete_all_public_test_files
    end

    it "basic export" do
      item = Thesaurus.create(identifier: "ITEM2", label: "Item 2")
      filename = item.to_ttl!
      copy_file_from_public_files_rename("test", filename, sub_dir, "temp.txt")
    #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "export_expected_1.txt")
      check_ttl_fix_v2("temp.txt", "export_expected_1.txt", {last_change_date: true, creation_date: true})
      delete_data_file(sub_dir, "temp.txt")
    end

  end

end
