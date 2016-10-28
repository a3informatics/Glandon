require 'rails_helper'

describe BridgSdtm do
	
	it "finds entry that exists I" do
		expect(BridgSdtm.get("DefinedObservation.nameCode.CD.code")).to eq("--TESTCD")
	end

  it "finds entry that exists II" do
    expect(BridgSdtm.get("PerformedActivity.dateRange.IVL(TS.DATETIME)")).to eq("--RFTDTC")
  end

  it "does not find entry that is missing" do
    expect(BridgSdtm.get("DefinedObservation.nameCode.CD.code.xxx")).to eq("")
  end

end