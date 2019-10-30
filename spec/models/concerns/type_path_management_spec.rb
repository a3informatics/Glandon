require 'rails_helper'

describe TypePathManagement do

  describe "original version" do

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

  describe "new version" do

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "returns a valid path, Thesaurus Model" do
      model = Thesaurus.new
      model.set_initial("XXX")
      expect(TypePathManagement.history_url_v2(model)).to eq("/thesauri/history/?thesauri[identifier]=XXX&thesauri[scope_id]=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ==")
    end

    it "returns valid path with checking of type" do
      ct = IsoManagedV2.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")) # Read as IsoManaged, should still get right path
      expect(TypePathManagement.history_url_v2(ct, true)).to eq("/thesauri/history/?thesauri[identifier]=CT&thesauri[scope_id]=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQ0RJU0M=")
    end

    it "raise exception invalid type" do
      object = IsoNamespace.new
      expect{TypePathManagement.history_url_v2(object)}.to raise_error(Errors::ApplicationLogicError, "Unknown object type http://www.assero.co.uk/ISO11179Identification#Namespace detected.")
    end

  end

end