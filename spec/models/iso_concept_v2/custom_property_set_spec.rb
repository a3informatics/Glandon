require 'rails_helper'

describe IsoConceptV2::CustomPropertySet do
	
	include DataHelpers
  include SecureRandomHelpers

  def sub_dir
    return "models/custom_property_set"
  end

  before :each do
    data_files = []
    load_files(schema_files, data_files)
  end

  it "<<" do
    expected = [
      {id: nil,
       label: "1",
       rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
       uri: {}
      },
      {id: nil,
       label: "1",
       rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
       uri: {}
      },
      {id: nil,
       label: "1",
       rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Concept",
       uri: {}
      }
    ]
    item = IsoConceptV2::CustomPropertySet.new
    item << IsoConceptV2.new(label: "1")
    item << IsoConceptV2.new(label: "1")
    item << IsoConceptV2.new(label: "1")
    expect(item.to_h).to eq(expected)
	end

  def create_definition_1
    @definition_1 = CustomPropertyDefinition.create(datatype: "string", label: "Name", 
      description: "A description", default: "Default String",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD1"))
  end

  def create_definition_2
    @definition_2 = CustomPropertyDefinition.create(datatype: "string", label: "Other", 
      description: "A description other", default: "Default Other",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD2"))
  end

  def create_definition_3
    @definition_3 = CustomPropertyDefinition.create(datatype: "boolean", label: "Switch", 
      description: "A description of switch", default: "false",
      custom_property_of: Uri.new(uri: "http://www.assero.co.uk/Test#UnmanagedConcept"), 
      uri: Uri.new(uri: "http://www.assero.co.uk/Test#CVD3"))
  end

  def create_value(value, index, definition=@definition_1)
    CustomPropertyValue.create(value: value, custom_property_defined_by: definition, uri: Uri.new(uri: "http://www.assero.co.uk/CPV##{index}"))
  end

  it "name_values_pairs" do
    create_definition_1
    expected = [
      {name: "Name", :value=>"String 1"},
      {name: "Name", :value=>"String 2"},
      {name: "Name", :value=>"String 3"}
    ]
    custom_set = IsoConceptV2::CustomPropertySet.new
    custom_set << create_value("String 1", 1)
    custom_set << create_value("String 2", 2)
    custom_set << create_value("String 3", 3)
    expect(custom_set.name_value_pairs).to eq(expected)
  end

  it "name_values_pairs II" do
    create_definition_3
    expected = [{:name=>"Switch", :value=>true}, {:name=>"Switch", :value=>false}]
    custom_set = IsoConceptV2::CustomPropertySet.new
    custom_set << create_value("true", 1, @definition_3)
    custom_set << create_value("false", 2, @definition_3)
    expect(custom_set.name_value_pairs).to eq(expected)
  end

  it "return_values" do
    create_definition_1
    create_definition_2
    expected = 
    {
      name: {:id=>"aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvQ1BWIzE=", :value=>"String 1"},
      other: {:id=>"aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvQ1BWIzI=", :value=>"String 2"}
    }
    custom_set = IsoConceptV2::CustomPropertySet.new
    custom_set << create_value("String 1", 1)
    custom_set << create_value("String 2", 2, @definition_2)
    expect(custom_set.return_values).to eq(expected)
  end

  it "clear" do
    create_definition_1
    expected = [
      {name: "Name", :value=>"String 1"},
      {name: "Name", :value=>"String 2"},
      {name: "Name", :value=>"String 3"}
    ]
    custom_set = IsoConceptV2::CustomPropertySet.new
    custom_set << create_value("String 1", 1)
    custom_set << create_value("String 2", 2)
    custom_set << create_value("String 3", 3)
    expect(custom_set.name_value_pairs).to eq(expected)
    custom_set.clear
    expect(custom_set.name_value_pairs).to eq([])
  end

  it "diff? same" do
    create_definition_1
    create_definition_2
    custom_set_1 = IsoConceptV2::CustomPropertySet.new
    custom_set_1 << create_value("First", 1, @definition_1)
    custom_set_1 << create_value("Second", 2, @definition_2)
    custom_set_2 = IsoConceptV2::CustomPropertySet.new
    custom_set_2 << create_value("First", 1, @definition_1)
    custom_set_2 << create_value("Second", 2, @definition_2)
    expect(custom_set_1.diff?(custom_set_2)).to eq(false)
  end

  it "diff? different I" do
    create_definition_1
    create_definition_2
    custom_set_1 = IsoConceptV2::CustomPropertySet.new
    custom_set_1 << create_value("First", 1, @definition_1)
    custom_set_1 << create_value("Second Diff", 2, @definition_2)
    custom_set_2 = IsoConceptV2::CustomPropertySet.new
    custom_set_2 << create_value("First", 1, @definition_1)
    custom_set_2 << create_value("Second", 2, @definition_2)
    expect(custom_set_1.diff?(custom_set_2)).to eq(true)
  end

  it "diff? different II" do
    create_definition_1
    create_definition_2
    custom_set_1 = IsoConceptV2::CustomPropertySet.new
    custom_set_1 << create_value("First", 1, @definition_1)
    custom_set_1 << create_value("Second", 2, @definition_2)
    custom_set_1 << create_value("Third", 2, @definition_2)
    custom_set_2 = IsoConceptV2::CustomPropertySet.new
    custom_set_2 << create_value("First", 1, @definition_1)
    custom_set_2 << create_value("Second", 2, @definition_2)
    expect(custom_set_1.diff?(custom_set_2)).to eq(true)
  end

end