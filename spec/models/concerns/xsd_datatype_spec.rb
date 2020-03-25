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

end