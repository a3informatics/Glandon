require 'rails_helper'

describe XSDDatatype do
	
	include DataHelpers

  def sub_dir
    return "models/concerns/xsd_datatype"
  end

  it "create datatype" do
		item = XSDDatatype.new("boolean")
    expect(item.fragment).to eq("boolean")
    expect(item.string?).to eq(false)
	end

  it "string?" do
    item = XSDDatatype.new("string")
    expect(item.string?).to eq(true)
  end

  it "to literal" do
    item = XSDDatatype.new("boolean")
    expect(item.to_literal(true)).to eq("true")
  end

  it "to literal, error" do
    item = XSDDatatype.new("booleanX")
    expect{item.to_literal(true)}.to raise_error(Errors::ApplicationLogicError, "Unable to access configuration for type http://www.w3.org/2001/XMLSchema#booleanX.")
  end

  it "to typed" do
    item = XSDDatatype.new("boolean")
    expect(item.to_typed("false")).to eq(false)
  end

  it "default" do
    item = XSDDatatype.new("boolean")
    expect(item.default).to eq(true)
    item = XSDDatatype.new("dateTime")
    expect(item.default.to_s).to eq("2016-01-01 00:00:00 +0000")
  end

  it "default_format" do
    item = XSDDatatype.new("string")
    expect(item.default_format).to eq("20")
    item = XSDDatatype.new("integer")
    expect(item.default_format).to eq("3")
    item = XSDDatatype.new("positiveInteger")
    expect(item.default_format).to eq("3")
    item = XSDDatatype.new("float")
    expect(item.default_format).to eq("5.2")
    item = XSDDatatype.new("boolean")
    expect(item.default_format).to eq("")
  end

  it "returns as a hash" do
    item = XSDDatatype.new("boolean")
    expect(item.to_h).to eq({:datatype=>"http://www.w3.org/2001/XMLSchema#boolean", :fragment=>"boolean"})
  end

  it "returns as a string" do
    item = XSDDatatype.new("string")
    expect(item.to_s).to eq("http://www.w3.org/2001/XMLSchema#string")
  end

end