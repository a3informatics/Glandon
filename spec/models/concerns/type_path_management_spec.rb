require 'rails_helper'

describe TypePathManagement do
	
	it "returns a valid path, SDTM Model" do
		expect(TypePathManagement.history_path(SdtmModel::C_RDF_TYPE_URI.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_models_path)
	end

  it "returns a valid path, SDTM User Domain" do
    expect(TypePathManagement.history_path(SdtmUserDomain::C_RDF_TYPE_URI.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_user_domains_path)
  end

  it "returns a empty string for an invalid type" do
    expect(TypePathManagement.history_path("XXX")).to eq("")
  end

end