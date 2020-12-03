require 'rails_helper'

describe CustomPropertyValue do
	
	include DataHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/custom_property_value"
  end

  before :each do
    data_files = []
    load_files(schema_files, data_files)
    allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
  end

  it "valid property" do
		item = CustomPropertyValue.new(value: "true", custom_property_defined_by: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid property, errors I" do
    item = CustomPropertyValue.new(value: "", custom_property_defined_by: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Value contains invalid characters")
  end

  it "valid property, errors II" do
    item = CustomPropertyValue.new(value: "1")
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Custom property defined by empty object")
  end

  it "create property" do
    item = CustomPropertyValue.create(value: "true", 
      custom_property_defined_by: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"),
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#A"))
    expect(item.errors.count).to eq(0)
  end

  it "updates and clones" do
    c_1 = Uri.new(uri: "http://www.assero.co.uk/Test#Context1")
    c_2 = Uri.new(uri: "http://www.assero.co.uk/Test#Context2")
    definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    item = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: definition_1.uri,
      applies_to: Uri.new(uri: "http://www.assero.co.uk/Test#Target1"),
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#A"),
      context: [c_1])
    item = CustomPropertyValue.find_full(item.uri) # Make sure definition read
    result = item.update_and_clone({value: "step 2"}, c_1)
    expect(item.value).to eq("step 2")
    expect(item.context).to match_array([c_1])
    item.context = [c_1, c_2]
    item.save
    result = item.update_and_clone({value: "step 3"}, c_2)
    expect(item.value).to eq("step 2")
    expect(item.context).to match_array([c_1])
    expect(result.value).to eq("step 3")
    check_file_actual_expected(result.to_h, sub_dir, "update_and_clone_expected_1a.yaml")
    check_file_actual_expected(item.to_h, sub_dir, "update_and_clone_expected_1b.yaml")
  end

  it "updates and clones, errors" do
    c_1 = Uri.new(uri: "http://www.assero.co.uk/Test#Context1")
    c_2 = Uri.new(uri: "http://www.assero.co.uk/Test#Context2")
    definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    item = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: definition_1.uri,
      applies_to: Uri.new(uri: "http://www.assero.co.uk/Test#Target1"),
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#A"),
      context: [c_1])
    item = CustomPropertyValue.find_full(item.uri) # Make sure definition read
    result = item.update_and_clone({value: "§§§§§§§"}, c_1)
    expect(result.errors.full_messages.to_sentence).to eq("Name [\"contains invalid characters\"]")
    item = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: definition_1.uri,
      applies_to: Uri.new(uri: "http://www.assero.co.uk/Test#Target1"),
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#B"),
      context: [c_1, c_2])
    item = CustomPropertyValue.find_full(item.uri) # Make sure definition read
    result = item.update_and_clone({value: "§§§§§§§"}, c_1)
    expect(result.errors.full_messages.to_sentence).to eq("Name [\"contains invalid characters\"]")
  end

  it "updates and clone II" do
    c_1 = Uri.new(uri: "http://www.assero.co.uk/Test#Context1")
    c_2 = Uri.new(uri: "http://www.assero.co.uk/Test#Context2")
    definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    definition_2 = CustomPropertyDefinition.create(datatype: "integer", label: "Other", 
      description: "A description integer", default: "1",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
    definition_3 = CustomPropertyDefinition.create(datatype: "boolean", label: "Switch", 
      description: "A description of switch", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD3"))
    value_1 = CustomPropertyValue.create(value: "value", custom_property_defined_by: definition_1, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#1"), context: [c_1])
    value_2 = CustomPropertyValue.create(value: "12", custom_property_defined_by: definition_2, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#2"), context: [c_1])
    value_3 = CustomPropertyValue.create(value: "true", custom_property_defined_by: definition_3, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#3"), context: [c_1])
    result = value_1.update_and_clone({value: "xxx"}, c_1)
    result = CustomPropertyValue.find_children(value_1.uri)
    expect(result.to_typed).to eq("xxx")
    result = value_2.update_and_clone({value: 999}, c_1)
    result = CustomPropertyValue.find_children(value_2.uri)
    expect(result.to_typed).to eq(999)
    result = value_3.update_and_clone({value: false}, c_1)
    result = CustomPropertyValue.find_children(value_3.uri)
    expect(result.to_typed).to eq(false)
    value_4 = CustomPropertyValue.create(value: "true", custom_property_defined_by: definition_3, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#4"), context: [c_1, c_2])
    result = value_4.update_and_clone({value: false}, c_1)
    result = CustomPropertyValue.find_children(result.uri)
    expect(result.to_typed).to eq(false)
    result = CustomPropertyValue.find_children(value_4.uri)
    expect(result.to_typed).to eq(true)
  end

  it "where unique" do
    definition = CustomPropertyDefinition.create(datatype: "boolean", label: "A definition", 
      description: "A description", default: "true",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CPD1"))
    applies_to = Uri.new(uri: "http://www.assero.co.uk/Test#Target1")
    context_1 = Uri.new(uri: "http://www.assero.co.uk/Test#Context1")
    item_1 = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: definition.uri,
      applies_to: applies_to,
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CPV1"),
      context: [context_1])
    result = CustomPropertyValue.where_unique(applies_to, context_1, definition.label.to_variable_style)
    expect(result).to eq(item_1.uri)
    context_2 = Uri.new(uri: "http://www.assero.co.uk/Test#Context2")
    item_2 = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: definition.uri,
      applies_to: applies_to,
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CPV2"),
      context: [context_2])
    result = CustomPropertyValue.where_unique(applies_to, context_2, definition.label.to_variable_style)
    expect(result).to eq(item_2.uri)
    context_3 = Uri.new(uri: "http://www.assero.co.uk/Test#Context3")
    expect{CustomPropertyValue.where_unique(applies_to, context_3, definition.label.to_variable_style)}.to raise_error(Errors::ApplicationLogicError, "Cannot find property a_definition for http://www.assero.co.uk/Test#Target1 in context http://www.assero.co.uk/Test#Context3.")
    item_3 = CustomPropertyValue.create(value: "Second Value", 
      custom_property_defined_by: definition.uri,
      applies_to: applies_to,
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CPV3"),
      context: [context_2])
    expect{CustomPropertyValue.where_unique(applies_to, context_2, definition.label.to_variable_style)}.to raise_error(Errors::ApplicationLogicError, "Found multiple properties for a_definition for http://www.assero.co.uk/Test#Target1 in context http://www.assero.co.uk/Test#Context2.")
  end

  it "to typed" do
    definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    definition_2 = CustomPropertyDefinition.create(datatype: "integer", label: "Other", 
      description: "A description integer", default: "1",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
    definition_3 = CustomPropertyDefinition.create(datatype: "boolean", label: "Switch", 
      description: "A description of switch", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD3"))
    value_1 = CustomPropertyValue.create(value: "value", custom_property_defined_by: definition_1, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#1"))
    value_2 = CustomPropertyValue.create(value: "12", custom_property_defined_by: definition_2, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#2"))
    value_3 = CustomPropertyValue.create(value: "true", custom_property_defined_by: definition_3, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#3"))
    expect(value_1.to_typed).to eq("value")
    expect(value_2.to_typed).to eq(12)
    expect(value_3.to_typed).to eq(true)
  end

  it "fix errors" do
    definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name This", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
    value_1 = CustomPropertyValue.create(value: "value", custom_property_defined_by: definition_1, uri: Uri.new(uri: "http://www.assero.co.uk/CPV#1"))
    value_1.errors.add(:base, "single")
    expected = value_1.errors.full_messages
    value_1.fix_errors
    expect(value_1.errors.full_messages).to eq(expected)
    value_1.errors.add(:value, "big error")
    value_1.fix_errors
    expect(value_1.errors.full_messages).to eq(expected + ["Name this [\"big error\"]"])
    expect(value_1.errors.key?(:name_this)).to eq(true)
  end

end