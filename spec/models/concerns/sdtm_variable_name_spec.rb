require 'rails_helper'

describe SdtmVariableName do
	
	it "checks if name prefixed I" do
		expect(SdtmVariableName.new("--XXXXXX").prefixed?).to eq(true)
	end

  it "checks if name prefixed II" do
    expect(SdtmVariableName.new("YYXXXXXX", "YY").prefixed?).to eq(true)
  end

  it "checks if name not prefixe, I" do
    expect(SdtmVariableName.new("YYXXXXXX").prefixed?).to eq(false)
  end

  it "checks if name not prefixed II" do
    expect(SdtmVariableName.new("XXXXXXXX").prefixed?).to eq(false)
  end

  it "replaces alpha prefix I" do
    expect(SdtmVariableName.new("--CC").alpha_prefix).to eq("xxCC")
  end

  it "replaces alpha prefix II" do
    expect(SdtmVariableName.new("CCCC").alpha_prefix).to eq("CCCC")
  end

  it "replaces generic prefix I" do
    expect(SdtmVariableName.new("--CC").generic_prefix).to eq("--CC")
  end

  it "replaces generic prefix II" do
    expect(SdtmVariableName.new("CCCC").generic_prefix).to eq("CCCC")
  end

  it "with prefix I" do
    expect(SdtmVariableName.new("--CC").with_prefix("ww")).to eq("wwCC")
  end

  it "with prefix II" do
    expect(SdtmVariableName.new("AACC", "AA").with_prefix("ww")).to eq("wwCC")
  end

  it "with prefix II" do
    expect(SdtmVariableName.new("AACC").with_prefix("ww")).to eq("AACC")
  end

end