require 'rails_helper'

describe SdtmUtility do
	
	it "checks if name prefixed" do
		expect(SdtmUtility.prefixed?("--XXXXXX")).to eq(true)
	end

  it "checks if name not prefixed" do
    expect(SdtmUtility.prefixed?("XXXXXXXX")).to eq(false)
  end

  it "replaces prefix I" do
    expect(SdtmUtility.replace_prefix("--CC")).to eq("xxCC")
  end

  it "replaces prefix II" do
    expect(SdtmUtility.replace_prefix("CCCC")).to eq("CCCC")
  end

  it "overwrites prefix" do
    expect(SdtmUtility.overwrite_prefix("--CCCC", "ZZ")).to eq("ZZCCCC")
  end

  it "adds prefix" do
    expect(SdtmUtility.add_prefix("CCCC")).to eq("--CCCC")
  end

  it "sets prefix I" do
    expect(SdtmUtility.set_prefix(true, "xxCCCC")).to eq("--CCCC")
  end

  it "sets prefix II" do
    expect(SdtmUtility.set_prefix(false, "xxCCCC")).to eq("xxCCCC")
  end

end