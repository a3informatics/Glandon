require 'rails_helper'
require 'tabulation'

describe TypePathManagement do

  describe "original version" do

  	it "returns a valid path, SDTM Model" do
  		expect(TypePathManagement.history_path(SdtmModel.rdf_type.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_models_path)
  	end

    it "returns a valid path, SDTM IG Domain" do
      expect(TypePathManagement.history_path(SdtmIgDomain.rdf_type.to_s)).to eq(Rails.application.routes.url_helpers.history_sdtm_ig_domains_path)
    end

    it "returns a empty path for an invalid type" do
      expect(TypePathManagement.history_path("XXX")).to eq("")
    end

    it "returns a valid url, SDTM Model" do
      result = Rails.application.routes.url_helpers.history_sdtm_models_path + "/?sdtm_model[identifier]=XXX&sdtm_model[scope_id]=YYY"
      expect(TypePathManagement.history_url(SdtmModel.rdf_type.to_s, "XXX", "YYY" )).to eq(result)
    end

    it "returns a valid url, SDTM IG" do
      result = Rails.application.routes.url_helpers.history_sdtm_igs_path + "/?sdtm_ig[identifier]=XXX&sdtm_ig[scope_id]=YYY"
      expect(TypePathManagement.history_url(SdtmIg.rdf_type.to_s, "XXX", "YYY" )).to eq(result)
    end

    it "returns a valid url, ADaM IG" do
      result = Rails.application.routes.url_helpers.history_adam_igs_path + "/?adam_ig[identifier]=XXX&adam_ig[scope_id]=YYY"
      expect(TypePathManagement.history_url(AdamIg.rdf_type.to_s, "XXX", "YYY" )).to eq(result)
    end

    it "returns a valid url, Form" do
      result = Rails.application.routes.url_helpers.history_forms_path + "/?form[identifier]=XXX&form[scope_id]=YYY"
      expect(TypePathManagement.history_url(Form.rdf_type.to_s, "XXX", "YYY" )).to eq(result)
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

    it "returns a valid path, Thesaurus::ManagedConcept Model" do
      model = Thesaurus::ManagedConcept.new
      model.set_initial("XXX")
      expect(TypePathManagement.history_url_v2(model)).to eq("/thesauri/managed_concepts/history/?managed_concept[identifier]=XXX&managed_concept[scope_id]=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ==")
    end

    it "returns a valid path, AdamIgDataset Model" do
      model = AdamIgDataset.new
      model.set_initial("XXX")
      expect(TypePathManagement.history_url_v2(model)).to eq("/adam_ig_datasets/history/?adam_ig_dataset[identifier]=XXX&adam_ig_dataset[scope_id]=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ==")
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