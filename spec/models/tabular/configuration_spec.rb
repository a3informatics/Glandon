require 'rails_helper'

describe IsoManagedItem::Configuration do
  
  it "allows for the class to be initialized" do  
    config = 
      { 
        identifier: "AAAAA", 
        type_uri: "http://www.a3informatics.com/type/A#fragment", 
        cid_prefix: "A" 
      }
    object = IsoManagedItem::Configuration.new(config)
    expect(object.identifier).to eq(config[:identifier])
    expect(object.type_uri.to_s).to eq(config[:type_uri])
    expect(object.cid_prefix).to eq(config[:cid_prefix])
  end

  it "allows for the class to be initialized, error CID Prefix" do  
    config = 
      { 
        identifier: "AAAAA", 
        type_uri: "http://www.a3informatics.com/type/A#fragment"
      }
    expect{IsoManagedItem::Configuration.new(config)}.to raise_error(Errors::ApplicationLogicError, "Missing CID prefix detected.")
  end

  it "allows for the class to be initialized, error type URI" do  
    config = 
      { 
        identifier: "AAAAA", 
        cid_prefix: "A" 
      }
    expect{IsoManagedItem::Configuration.new(config)}.to raise_error(Errors::ApplicationLogicError, "Missing type URI detected.")
  end

  it "allows for the class to be initialized, error identifier" do  
    config = 
      { 
        type_uri: "http://www.a3informatics.com/type/A#fragment", 
        cid_prefix: "A" 
      }
    expect{IsoManagedItem::Configuration.new(config)}.to raise_error(Errors::ApplicationLogicError, "Missing identifier detected.")
  end

  it "allows for the schema namespace to be obtained" do
    config = 
      { 
        identifier: "AAAAA", 
        type_uri: "http://www.a3informatics.com/type/A#fragment", 
        cid_prefix: "A" 
      }
    object = IsoManagedItem::Configuration.new(config)
    expect(object.schema_namespace).to eq("http://www.a3informatics.com/type/A")
  end

  it "allows for the schema prefix to be obtained" do
    config = 
      { 
        identifier: "AAAAA", 
        type_uri: "http://www.a3informatics.com/type/A#fragment", 
        cid_prefix: "A" 
      }
    expect(UriManagement).to receive(:getPrefix).with("http://www.a3informatics.com/type/A").and_return("XX")
    object = IsoManagedItem::Configuration.new(config)
    expect(object.schema_prefix).to eq("XX")
  end
  
  it "allows for the schema RDF type to be obtained" do
    config = 
      { 
        identifier: "AAAAA", 
        type_uri: "http://www.a3informatics.com/type/A#fragment", 
        cid_prefix: "A" 
      }
    object = IsoManagedItem::Configuration.new(config)
    expect(object.rdf_type).to eq("fragment")
  end

end