require 'rails_helper'

describe IsoManagedV2::ImCustomProperties do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers
  include CustomPropertyHelpers
  
	def sub_dir
    return "models/iso_managed_v2/im_custom_properties"
  end


  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_definitions
      create_data
    end

    after :each do
    end

    it "custom property definitons" do
      results = @parent.find_custom_property_values 
      check_file_actual_expected(results, sub_dir, "find_custom_properties_values_expected_1.yaml")
    end

  end

  describe "add contexts" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_definitions
      create_data
    end

    after :each do
    end

    it "add context" do
      other_parent = TestParent.create(identifier: "XXX", label: "Parent")
      other_parent.narrower = [@child_1, @child_2, @child_3]
      other_parent.save
      other_parent.add_custom_property_context([@child_1.id, @child_2.uri, @child_3.id])
      results = other_parent.find_custom_property_values 
      check_file_actual_expected(results, sub_dir, "add_custom_property_context_expected_1.yaml")
    end

  end

end
