require 'rails_helper'

describe ApplicationController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

  describe "tests" do
    login_curator
    before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = 
    [
      "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
    ]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
  end
  	
    it "params to id, strong_key nil" do
      params = {namespace: "aaa" , id: "id1" }
      strong_key = nil
      actual = params_to_id(params, strong_key)
      expect(actual).to eq("aaa#id1")
    end

    it "params to id, strong_key no nil" do
      # params = {id: "id2", iso_managed:{namespace:"http://www.assero.co.uk/MDRForms/ACME/V1", id:"test"}}
      # strong_key = "iso_managed"
    end

  end

end


