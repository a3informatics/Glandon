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
      create_data
    end

    after :each do
    end

    it "add context" do
      other_parent = CustomPropertyHelpers::TestParent.create(identifier: "XXX", label: "Parent")
      other_parent.narrower = [@child_1, @child_2, @child_3]
      other_parent.save
      other_parent.add_custom_property_context([@child_1.id, @child_2.uri, @child_3.id])
      results = other_parent.find_custom_property_values 
      check_file_actual_expected(results, sub_dir, "add_custom_property_context_expected_1.yaml")
    end

  end

  describe "populate custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_data
    end

    after :each do
    end

    it "populate and load" do
      item = CustomPropertyHelpers::TestParent.find_full(@parent.uri)
      item.populate_custom_properties
      expect(@parent.custom_properties.items).to eq([])
      check_file_actual_expected(item.narrower.map{|x| x.custom_properties.to_h}, sub_dir, "populate_custom_properties_expected_1.yaml")
    end

  end

  describe "missing custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_missing_data
    end

    after :each do
    end

    it "definitions" do
      defs = @parent.class.find_custom_property_definitions
    end

    it "missing" do
      items = @parent.missing_custom_properties([@child_1.id, @child_2.uri, @child_3.id], CustomPropertyHelpers::TestChild)
      check_file_actual_expected(items.map{|x| {subject: x[:subject].to_s, definition: x[:definition].to_s}}, sub_dir, "missing_custom_properties_expected_1.yaml")
    end

    it "add missing" do
      items = @parent.missing_custom_properties([@child_1.id, @child_2.uri, @child_3.id], CustomPropertyHelpers::TestChild)
      check_file_actual_expected(items.map{|x| {subject: x[:subject].to_s, definition: x[:definition].to_s}}, sub_dir, "missing_custom_properties_expected_1.yaml")
      tx = @parent.transaction_begin
      @parent.add_missing_custom_properties([@child_1.id, @child_2.uri, @child_3.id], CustomPropertyHelpers::TestChild, tx)
      tx.execute
      items = @parent.missing_custom_properties([@child_1.id, @child_2.uri, @child_3.id], CustomPropertyHelpers::TestChild)
      check_file_actual_expected(items.map{|x| {subject: x[:subject].to_s, definition: x[:definition].to_s}}, sub_dir, "add_missing_custom_properties_expected_1a.yaml")
      results = @parent.find_custom_property_values 
      check_file_actual_expected(results, sub_dir, "add_missing_custom_properties_expected_1b.yaml")
    end

  end

  describe "missing custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "existing custom property set" do
      object = IsoManagedV2.new
      expect(object.existing_custom_property_set).to eq([])
    end

  end

  describe "custom properties definitions" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      create_data
    end

    after :each do
    end

    it "existing custom property set" do
      results = @parent.find_custom_property_definitions
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "custom_property_definitions_expected_1a.yaml", write_file: true)
      results = @parent.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "custom_property_definitions_expected_1b.yaml", write_file: true)
    end

  end

end
