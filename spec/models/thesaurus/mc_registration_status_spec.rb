require 'rails_helper'

describe Thesaurus::McRegistrationStatus do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include CustomPropertyHelpers
  include ThesaurusManagedConceptFactory
  include NameValueHelpers

	def sub_dir
    return "models/thesaurus/mc_registration_status"
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      nv_destroy
      nv_create(parent: '10', child: '999')
    end

    after :each do
    end

    it "finds dependent items" do
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      extension = create_managed_concept("Extension")
      subset.add_link(:subsets, master.uri)
      extension.add_link(:extends, master.uri)
      results = master.update_status_dependent_items(action: :fast_forward, with_dependencies: "true")
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "update_status_dependent_items_expected_1.yaml", equate_method: :hash_equal)
    end

    it "finds dependent items, none" do
      master = create_managed_concept("Master")
      results = master.update_status_dependent_items(action: :fast_forward, with_dependencies: "true")
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "update_status_dependent_items_expected_2.yaml", equate_method: :hash_equal)
    end

    it "finds dependent items, dont do" do
      master = create_managed_concept("Master")
      subset = create_managed_concept("Subset")
      extension = create_managed_concept("Extension")
      subset.add_link(:subsets, master.uri)
      extension.add_link(:extends, master.uri)
      results = master.update_status_dependent_items(action: :fast_forward, with_dependencies: false)
      check_file_actual_expected(results.map{|x| x.to_s}, sub_dir, "update_status_dependent_items_expected_3.yaml", equate_method: :hash_equal)
    end

  end

end
