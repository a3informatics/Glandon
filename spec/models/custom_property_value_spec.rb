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
    item = CustomPropertyValue.create(value: "step 1", 
      custom_property_defined_by: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"),
      applies_to: Uri.new(uri: "http://www.assero.co.uk/Test#Target1"),
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#A"),
      context: [c_1])
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

end