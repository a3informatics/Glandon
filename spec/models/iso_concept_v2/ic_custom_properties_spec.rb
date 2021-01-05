require 'rails_helper'

describe IsoConceptV2::IcCustomProperties do

	include DataHelpers
  include PauseHelpers
  include SecureRandomHelpers

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

  def create_value(value, applies_to, context, definition)
    object = CustomPropertyValue.new(value: "#{value}", custom_property_defined_by: definition.uri, applies_to: applies_to.uri, context: [context.uri])
    object.uri = object.create_uri(object.class.base_uri)
    object.save
    object
  end

  def create_value_array(value, applies_to, context, definition)
    object = CustomPropertyValue.new(value: "#{value}", custom_property_defined_by: definition.uri, applies_to: applies_to.uri, context: context)
    object.uri = object.create_uri(object.class.base_uri)
    object.save
    object
  end

  describe "definitions" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "custom property definitons, class" do
      create_definition_1
      results = IsoConceptV2.find_custom_property_definitions
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_1.yaml")
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_2.yaml")
    end

    it "custom property definitons to h, class" do
      create_definition_1
      results = IsoConceptV2.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_1.yaml")
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_2.yaml")
      create_definition_3_and_4
      results = IsoConceptV2.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_to_h_expected_3.yaml")
    end

    it "custom property definitons, instance" do
      create_definition_1
      create_definition_2
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp_1 = create_value("Def 1 Value", object, object, @definition_1)
      results = object.find_custom_property_definitions
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_4.yaml")
      cp_2 = create_value("Def 2 Value", object, object, @definition_2)
      results = object.find_custom_property_definitions
      check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "find_custom_property_definitions_expected_5.yaml")
    end

    it "custom property definitons to h, instance" do
      create_definition_1
      create_definition_2
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp_1 = create_value("Def 1 Value", object, object, @definition_1)
      results = object.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_expected_6.yaml")
      cp_2 = create_value("Def 2 Value", object, object, @definition_2)
      results = object.find_custom_property_definitions_to_h
      check_file_actual_expected(results, sub_dir, "find_custom_property_definitions_expected_7.yaml")

    end

  end

  describe "values" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "custom property value" do
      create_definition_1
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp = create_value("Object 1 Value", object, object, @definition_1)
      results = object.load_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "load_custom_properties_expected_1.yaml")
    end

    it "custom property values" do
      create_definition_1
      create_definition_2
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp_1 = create_value("Def 1 Value", object, object, @definition_1)
      cp_2 = create_value(true, object, object, @definition_2)
      results = object.load_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "load_custom_properties_expected_2.yaml")
    end

  end

  describe "get, set, present and diff" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "custom property present" do
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      expect(object.custom_properties?).to eq(false)
      create_definition_1
      expect(object.custom_properties?).to eq(true)
    end

    it "custom property get" do
      create_definition_1
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp = create_value("Object 1 Value", object, object, @definition_1)
      object.load_custom_properties
      results = object.custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "get_custom_properties_expected_1.yaml")
    end

    it "custom properties get" do
      create_definition_1
      create_definition_2
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      cp_1 = create_value("Def 1 Value", object, object, @definition_1)
      cp_2 = create_value(true, object, object, @definition_2)
      object.load_custom_properties
      results = object.custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "get_custom_properties_expected_2.yaml")
    end

    it "custom properties set" do
      create_definition_1
      create_definition_2
      object_1 = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object_1.save
      cp_1_1 = create_value("Object 1 String", object_1, object_1, @definition_1)
      cp_1_2 = create_value(true, object_1, object_1, @definition_2)
      object_2 = IsoConceptV2.new(label: "Object 2", uri: Uri.new(uri: "http://www.example.com/A#object2"))
      object_2.save
      cp_2_1 = create_value("Object 2 String", object_2, object_2, @definition_1)
      cp_2_2 = create_value(false, object_2, object_2, @definition_2)
      object_1.load_custom_properties
      object_2.load_custom_properties
      expect(object_1.custom_properties_diff?(object_2)).to eq(true)
      results = object_1.custom_properties
      object_2.custom_properties = object_1.custom_properties
      expect(object_1.custom_properties_diff?(object_2)).to eq(false)
    end

  end

  describe "create default custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "simple case" do
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      results = object.create_default_custom_properties
      results = object.load_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "create_default_custom_properties_expected_1a.yaml")
      create_definition_1
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions
      results = object.create_default_custom_properties
      results = object.load_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "create_default_custom_properties_expected_1b.yaml")
    end

    it "with context case" do
      context = Uri.new(uri: "http://www.example.com/A#context1")
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      results = object.create_default_custom_properties(context)
      results = object.load_custom_properties(context)
      check_file_actual_expected(results.to_h, sub_dir, "create_default_custom_properties_expected_2.yaml")
    end

    it "with context and transaction case" do
      tx = Sparql::Transaction.new
      context = Uri.new(uri: "http://www.example.com/A#context1")
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      results = object.create_default_custom_properties(context, tx)
      check_file_actual_expected(results.to_h, sub_dir, "create_default_custom_properties_expected_3a.yaml")
      results = object.load_custom_properties(context)
      check_file_actual_expected(results.to_h, sub_dir, "create_default_custom_properties_expected_3b.yaml")
    end

  end

  describe "create custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "simple case, defaults" do
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      results = object.create_custom_properties
      results = object.load_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_1a.yaml")
      create_definition_1
      create_definition_2
      results = IsoConceptV2.find_custom_property_definitions
      results = object.create_default_custom_properties
      result = object.clone
      result.uri = Uri.new(uri: "http://www.example.com/A#object2")
      results = result.create_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_1b.yaml")
    end

    it "simple case" do
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      object.create_default_custom_properties
      results = object.load_custom_properties
      results.items.first.update(value: "DDD")
      results = object.load_custom_properties   
      result = object.clone
      result.uri = Uri.new(uri: "http://www.example.com/A#object2")
      results = result.create_custom_properties
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_2.yaml")
    end

    it "with context case, defaults" do
      context = Uri.new(uri: "http://www.example.com/A#context1")
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      object.create_default_custom_properties(context)
      object.load_custom_properties(context)
      result = object.clone(context)
      result.uri = Uri.new(uri: "http://www.example.com/A#object2")
      results = result.create_custom_properties(context)
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_3.yaml")
    end

    it "with context case" do
      context = Uri.new(uri: "http://www.example.com/A#context1")
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      object.create_default_custom_properties(context)
      results = object.load_custom_properties(context)
      results.items.first.update(value: "DDD")
      results = object.load_custom_properties   
      result = object.clone(context)
      result.uri = Uri.new(uri: "http://www.example.com/A#object2")
      results = result.create_custom_properties(context)
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_4.yaml", write_file: true)
    end

    it "with context and transaction case" do
      tx = Sparql::Transaction.new
      context = Uri.new(uri: "http://www.example.com/A#context1")
      object = IsoConceptV2.create(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      create_definition_1
      create_definition_2
      object.create_default_custom_properties(context)
      results = object.load_custom_properties(context)
      results.items.first.update(value: "TX TX TX")
      results = object.load_custom_properties   
      result = object.clone(context)
      result.uri = Uri.new(uri: "http://www.example.com/A#object2")
      results = result.create_custom_properties(context, tx)
      check_file_actual_expected(results.to_h, sub_dir, "create_custom_properties_expected_5.yaml", write_file: true)
    end

  end

  describe "clone custom properties" do

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    end

    after :each do
    end

    it "with context" do
      object = IsoConceptV2.new(label: "Object 1", uri: Uri.new(uri: "http://www.example.com/A#object1"))
      object.save
      new_object = IsoConceptV2.new(label: "Object 2", uri: Uri.new(uri: "http://www.example.com/A#object2"))
      new_object.save
      create_definition_1
      create_definition_2
      context_1 = Uri.new(uri: "http://www.example.com/A#context1")
      context_2 = Uri.new(uri: "http://www.example.com/A#context2")
      cp_1 = create_value_array("Object 1 String", object, [context_1, context_2], @definition_1)
      cp_2 = create_value_array(true, object, [context_1], @definition_2)
      cp_3 = create_value_array(false, object, [context_2], @definition_2)
      results = object.load_custom_properties(context_1)
      check_file_actual_expected(results.to_h, sub_dir, "clone_custom_properties_expected_1a.yaml")
      results = object.load_custom_properties(context_2)
      check_file_actual_expected(results.to_h, sub_dir, "clone_custom_properties_expected_1b.yaml")
      results = object.clone_custom_properties(new_object, context_2)
      check_file_actual_expected(results.to_h, sub_dir, "clone_custom_properties_expected_1c.yaml")
    end

  end

end
