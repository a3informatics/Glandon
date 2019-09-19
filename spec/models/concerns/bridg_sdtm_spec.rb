require 'rails_helper'

describe BridgSdtm do
	
	it "finds entry that exists I" do
byebug
		expect(BridgSdtm.get("DefinedObservation.nameCode.CD.code")).to eq("--TESTCD")
	end

  it "finds entry that exists II" do
    expect(BridgSdtm.get("PerformedObservationResult.value.CD.code")).to eq("--ORRES")
  end

  it "finds entry that exists III" do
    expect(BridgSdtm.get("PerformedObservationResult5.value.CD.code")).to eq("--REL")
  end

  it "finds entry that exists IV" do
    expect(BridgSdtm.get("AdverseEventActionTaken2.typeCode.CD.code")).to eq("--ACNOTH")
  end

  it "finds entry that exists V" do
    expect(BridgSdtm.get("AdverseEvent.value.ST.value")).to eq("--TERM")
  end

  it "finds entry that exists VI" do
    expect(BridgSdtm.get("PerformedObservationResult4.value.CD.code")).to eq("--SDTH")
  end

  it "finds entry that exists, deprecated" do
    expect(BridgSdtm.get("DefinedObservation.targetAnatomicSiteCode.CD.code")).to eq("--LOC")
    expect(BridgSdtm.get("DefinedObservation.methodCode.CD.code")).to eq("--METHOD")
    expect(BridgSdtm.get("DefinedActivity.categoryCode.CD")).to eq("--CAT")
    expect(BridgSdtm.get("DefinedActivity.subcategoryCode.CD")).to eq("--SCAT")
    expect(BridgSdtm.get("PerformedObservation.targetAnatomicSiteLateralityCode.CD.code")).to eq("--LAT")
  end

  it "does not find entry that is missing I" do
    expect(BridgSdtm.get("DefinedObservation.nameCode.CD.code.xxx")).to eq("")
  end

  it "does not find entry that is missing II" do
    expect(BridgSdtm.get("AdverseEvent.value.ST.x")).to eq("")
  end

  it "does not find entry that is missing III" do
    expect(BridgSdtm.get("PerformedActivity.dateRange.IVL(TS.DATETIME)")).to eq("")
  end

end