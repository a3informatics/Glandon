require 'rails_helper'

describe IsoConceptV2::IcCustomProperties do

	include DataHelpers
  include PauseHelpers

	def sub_dir
    return "models/iso_concept_v2/ic_custom_properties"
  end

  def create_definition_1
    @definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Some String", 
      description: "A description XXX", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
  end

  def create_definition_2
    @definition_2 = CustomPropertyDefinition.create(datatype: "boolean", label: "A Flag", 
      description: "A description YYY", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
  end

  def create_definition_3_and_4
    @definition_3 = CustomPropertyDefinition.create(datatype: "string", label: "Z Flag", 
      description: "A description YYY", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD3"))
    @definition_4 = CustomPropertyDefinition.create(datatype: "boolean", label: "X Something", 
      description: "A description YYY", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/ISO11179Concepts#Concept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD4"))
  end

  describe "basic tests" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "custom property definitons" do
      create_definition_1
      results = IsoConceptV2.find_custom_property_definitions(IsoConceptV2)
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_1.yaml")
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions(IsoConceptV2)
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_2.yaml")
    end

    it "custom property definitons to h" do
      create_definition_1
      results = IsoConceptV2.find_custom_property_definitions_to_h(IsoConceptV2)
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_1.yaml")
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions_to_h(IsoConceptV2)
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_2.yaml")
      create_definition_3_and_4
      results = IsoConceptV2.find_custom_property_definitions_to_h(IsoConceptV2)
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_3.yaml")
    end

  end

end
