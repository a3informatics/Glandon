require 'rails_helper'

describe TypePathManagement do
	
	it "returns a valid path, SDTM Model" do
		expect(TypePathManagement.history_path(SdtmModel::C_RDF_TYPE_URI.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_models_path)
	end

  it "returns a valid path, SDTM User Domain" do
    expect(TypePathManagement.history_path(SdtmUserDomain::C_RDF_TYPE_URI.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_user_domains_path)
  end

  it "returns a empty path for an invalid type" do
    expect(TypePathManagement.history_path("XXX")).to eq("")
  end

  it "returns a valid url, Biomedical Concept" do
    result = Rails.application.routes.url_helpers.history_biomedical_concepts_path + "/?biomedical_concept[identifier]=XXX&biomedical_concept[scope_id]=YYY"
    expect(TypePathManagement.history_url(BiomedicalConcept::C_RDF_TYPE_URI.to_s, "XXX", "YYY" )).to eq(result)
  end

  it "returns a valid url, SDTM Model" do
    result = Rails.application.routes.url_helpers.history_sdtm_models_path + "/?sdtm_model[identifier]=XXX&sdtm_model[scope_id]=YYY"
    expect(TypePathManagement.history_url(SdtmModel::C_RDF_TYPE_URI.to_s, "XXX", "YYY" )).to eq(result)
  end

  it "returns a valid url, SDTM IG" do
    result = Rails.application.routes.url_helpers.history_sdtm_igs_path + "/?sdtm_ig[identifier]=XXX&sdtm_ig[scope_id]=YYY"
    expect(TypePathManagement.history_url(SdtmIg::C_RDF_TYPE_URI.to_s, "XXX", "YYY" )).to eq(result)
  end

  it "returns a valid url, ADaM IG" do
    result = Rails.application.routes.url_helpers.history_adam_igs_path + "/?adam_ig[identifier]=XXX&adam_ig[scope_id]=YYY"
    expect(TypePathManagement.history_url(AdamIg::C_RDF_TYPE_URI.to_s, "XXX", "YYY" )).to eq(result)
  end

  it "returns a valid url, Form" do
    result = Rails.application.routes.url_helpers.history_forms_path + "/?identifier=XXX&scope_id=YYY"
    expect(TypePathManagement.history_url(Form::C_RDF_TYPE_URI.to_s, "XXX", "YYY" )).to eq(result)
  end

  it "returns a empty url for an invalid type" do
    expect(TypePathManagement.history_url("XXX", "AAA", "BBB")).to eq("")
  end

end