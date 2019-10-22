require 'rails_helper'

describe ApplicationController, type: :controller do

  describe "tests" do
  	
    it "params to id, namespace and id, strong_key nil" do
      params = {namespace: "http://www.example.com/path1/path2", id: "fragment"}
      actual = @controller.params_to_id(params)
      expect(actual).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9wYXRoMS9wYXRoMiNmcmFnbWVudA==")
    end

    it "params to id, strong_key no nil" do
      params = { id: "F-ACME_TEST", iso_managed:{namespace:"http://www.assero.co.uk/MDRForms/ACME/V1", current_id:"test"} } 
      strong_key = {namespace:"http://www.assero.co.uk/MDRForms/ACME/V1", current_id:"test"}
      actual = @controller.params_to_id(params, strong_key)
      expect(actual).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTURSRm9ybXMvQUNNRS9WMSNGLUFDTUVfVEVTVA==")

    end

    it "params to id, no need to convert id, strong_key nil" do
      params = { id: "aHR0cDovL3d3d==" }
      actual = @controller.params_to_id(params)
      expect(actual).to eq("aHR0cDovL3d3d==")
    end

  end

end


