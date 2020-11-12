require 'rails_helper'

describe CustomPropertyDefinition do
	
	include DataHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/custom_property_definition"
  end

  before :each do
    data_files = []
    load_files(schema_files, data_files)
    allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
  end

  it "valid property" do
		item = CustomPropertyDefinition.new(datatype: "boolean", label: "A definition", description: "A description", default: "true",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(0)
	end

  it "valid property, errors I" do
    item = CustomPropertyDefinition.new(datatype: "boolean", label: "A definition", description: "A description", 
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Default can't be blank")
  end

  it "valid property, errors II" do
    item = CustomPropertyDefinition.new(datatype: "integer", label: "", description: "A description", default: "something",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Label can't be blank")
  end

  it "valid property, errors III" do
    item = CustomPropertyDefinition.new(datatype: "integer", label: "Ed", description: "", default: "something",
      custom_property_of: nil)
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(2)
    expect(item.errors.full_messages.to_sentence).to eq("Description can't be blank and Custom property of empty object")
  end

  it "create property" do
    item = CustomPropertyDefinition.create(datatype: "boolean", label: "A definition", 
      description: "A description", default: "true",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#A"))
    expect(item.errors.count).to eq(0)
  end

end