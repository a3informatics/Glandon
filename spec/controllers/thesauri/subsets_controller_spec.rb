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
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    load_local_file_into_triple_store(sub_dir, "subsets_input_3.ttl")
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
    end

    after :each do
    end

    it "add" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      unmanaged_concept = Thesaurus::UnmanagedConcept.find()
      expect(Thesaurus::Subset).to receive(:find).and_return(Thesaurus::Subset.new)
      uri_2 = Uri.new(uri: "http://www.assero.co.uk/TSM#67871de3-5e13-42da-9814-e9fc3ce7b2f3")
    byebug
      post :add, {id: subset.uri.to_id, subset:{member_id: uri_2}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

  end
end
