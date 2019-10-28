require 'rails_helper'

describe Thesauri::SubsetsController do

  include DataHelpers
  include PublicFileHelpers


  def sub_dir
    return "controllers/thesauri/subsets"
  end

  describe "Authorized User" do

    login_curator

    before :each do
      schema_files =["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl",
        "ISO11179Concepts.ttl", "thesaurus.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "CT_SUBSETS.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store(sub_dir, "subsets_input_3.ttl")

    end

    it "add" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      uc_uri = Uri.new(uri:"http://www.cdisc.org/C66768/V2#C66768_C48275")
      post :add, {id: subset.uri.to_id, subset:{member_id: uc_uri.to_id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      expect(subset.last.item.to_id).to eq("aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzY4L1YyI0M2Njc2OF9DNDgyNzU=")
    end

    it "remove" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      sm_uri = Uri.new(uri:"http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7baaa")
      delete :remove, {id: subset.uri.to_id, subset:{member_id: sm_uri.to_id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFMjNTQxNzZjNTktYjgwMC00M2Y1LTk5YzMtZDEyOWNiNTYzYzc5")
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      expect(subset.members.to_id).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFNNIzY3ODcxZGUzLTVlMTMtNDJkYS05ODE0LWU5ZmMzY2U3YmNjYw==")

    end

    it "move after" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      member_uri = Uri.new(uri:"http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1eee")
      put :move_after, {id: subset.uri.to_id, subset:{member_id: member_uri.to_id}}
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(subset.members.to_id).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFNNI2EyMzBlZWNiLTE1ODAtNGNjOS1hMWFmLTVlMThhNmViMWVlZQ==")
    end

  end
end
