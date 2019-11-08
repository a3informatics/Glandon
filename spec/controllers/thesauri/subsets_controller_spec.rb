require 'rails_helper'

describe Thesauri::SubsetsController do

  include DataHelpers
  include PublicFileHelpers


  def sub_dir
    return "controllers/thesauri/subsets"
  end

  # Prepares a link between the subset, a managed concept, and a test terminology
  def init_subset(subset)
    ct = Thesaurus.create({label: "Test Terminology", identifier: "TT"})
    mc = ct.add_child({})
    mc = Thesaurus::ManagedConcept.find_minimum(mc.id)
    mc.add_link(:is_ordered, subset.uri)
    mc.save
    @token = Token.obtain(mc, @user)
    subset
  end

  before :all do
    schema_files =["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl",
      "ISO11179Concepts.ttl", "thesaurus.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "CT_SUBSETS.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..20)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "123")
    NameValue.create(name: "thesaurus_child_identifier", value: "456")
  end

  describe "Authorized User - manipulate subset" do

    login_curator

    before :each do
      load_local_file_into_triple_store(sub_dir, "subsets_input_3.ttl")
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
    end

    after :each do
      Token.delete_all
    end

    it "add" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = init_subset(Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79")))
      uc_uri = Uri.new(uri:"http://www.cdisc.org/C66768/V2#C66768_C48275")
      post :add, {id: subset.uri.to_id, subset:{member_id: uc_uri.to_id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      expect(subset.last.item.to_id).to eq("aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzY4L1YyI0M2Njc2OF9DNDgyNzU=")
    end

    it "remove" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = init_subset(Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79")))
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
      subset = init_subset(Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79")))
      member_uri = Uri.new(uri:"http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1eee")
      put :move_after, {id: subset.uri.to_id, subset:{member_id: member_uri.to_id}}
      subset = Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(subset.members.to_id).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFNNI2EyMzBlZWNiLTE1ODAtNGNjOS1hMWFmLTVlMThhNmViMWVlZQ==")
    end

    it "rejects without token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset = init_subset(Thesaurus::Subset.find(Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cb563c79")))
      member_uri = Uri.new(uri:"http://www.assero.co.uk/TSM#a230eecb-1580-4cc9-a1af-5e18a6eb1eee")
      @token.release
      put :move_after, {id: subset.uri.to_id, subset:{member_id: member_uri.to_id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body)["errors"]).to eq(["The edit lock has timed out."])
    end

  end

  describe "Authorized User - read subset" do

    login_curator

    before :each do
      load_local_file_into_triple_store(sub_dir, "subsets_input_3.ttl")
      load_local_file_into_triple_store(sub_dir, "subsets_input_4.ttl")
    end

    it "list_children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      subset_uri_1 = Uri.new(uri: "http://www.assero.co.uk/TS#54176c59-b800-43f5-99c3-d129cbaaaaa1")
      subset = init_subset(Thesaurus::Subset.find(subset_uri_1))
      expected = [{ identifier: "C25529",
                    notation: "HOURS",
                    preferred_term: "Hour",
                    synonym: "HOURS",
                    extensible: false,
                    definition: "A unit measure of time equal to 3,600 seconds or 60 minutes. It is approximately 1/24 of a median day. (NCI)",
                    delete: false,
                    uri: "http://www.cdisc.org/C66781/V2#C66781_C25529",
                    id: "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgxL1YyI0M2Njc4MV9DMjU1Mjk=",
                    ordinal: 2,
                    member_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFNNI2EyMzBlZWNiLTE1ODAtNGNjOS1hMWFmLTVlMThhNmFhYWFhMw=="},
                  { identifier: "C29846",
                    notation: "MONTHS",
                    preferred_term: "Month",
                    synonym: "MONTHS",
                    extensible: false,
                    definition: "One of the 12 divisions of a year as determined by a calendar.  It corresponds to the unit of time of approximately to one cycle of the moon's phases, about 30 days or 4 weeks. (NCI)",
                    delete: false,
                    uri: "http://www.cdisc.org/C66781/V2#C66781_C29846",
                    id: "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgxL1YyI0M2Njc4MV9DMjk4NDY=",
                    ordinal: 3,
                    member_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvVFNNI2MyYzcwN2IxLWM3YTItNGVlNS1hOWFlLWJkNjNhNWFhYWFhNA=="}]
      get :list_children, {id: subset.uri.to_id, offset: "1" , count: "2" }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

  end
end
