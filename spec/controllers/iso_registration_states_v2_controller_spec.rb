require 'rails_helper'

describe IsoRegistrationStatesV2Controller do

  include DataHelpers

  describe "Curator" do
    
    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_general.ttl", "BC.ttl"]
      load_files(schema_files, data_files)
    end

    it 'updates multiple_edit flag' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_T2")
      mi = IsoManagedV2.find_minimum(uri_1)
      expect(mi.has_state.multiple_edit).to eq(false)
      put :update, { id: mi.id, iso_registration_state: { multiple_edit: true }}  
      mi = IsoManagedV2.find_minimum(uri_1)
      expect(mi.has_state.multiple_edit).to eq(true)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

  end


end