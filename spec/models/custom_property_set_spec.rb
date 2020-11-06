require 'rails_helper'

describe CustomPropertySet do
	
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
      {:id=>nil,
       :label=>"1",
       :rdf_type=>"http://www.assero.co.uk/ISO11179Concepts#Concept",
       :uri=>{}
      },
      {:id=>nil,
       :label=>"1",
       :rdf_type=>"http://www.assero.co.uk/ISO11179Concepts#Concept",
       :uri=>{}},
      {:id=>nil,
       :label=>"1",
       :rdf_type=>"http://www.assero.co.uk/ISO11179Concepts#Concept",
       :uri=>{}
      }
    ]
    item = CustomPropertySet.new
    item << IsoConceptV2.new(label: "1")
    item << IsoConceptV2.new(label: "1")
    item << IsoConceptV2.new(label: "1")
    expect(item.to_h).to eq(expected)
	end

end