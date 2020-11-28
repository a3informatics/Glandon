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
    item = CustomPropertyValue.new(value: "", custom_property_defined_by: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"))
    item.uri = item.create_uri(item.class.base_uri)
    item.valid?
    expect(item.errors.count).to eq(1)
    expect(item.errors.full_messages.to_sentence).to eq("Value can't be blank")
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
    check_file_actual_expected(result.to_h, sub_dir, "update_and_clone_expected_1a.yaml", write_file: true)
    check_file_actual_expected(item.to_h, sub_dir, "update_and_clone_expected_1b.yaml", write_file: true)
  end

end