require 'rails_helper'

describe IsoRegistrationStatesV2Controller do

  include DataHelpers

  describe "Curator" do
    
    login_curator

    before :each do
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_schema_file_into_triple_store("BusinessOperational.ttl")
      # load_schema_file_into_triple_store("BusinessForm.ttl")
      # load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
      # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      # load_test_file_into_triple_store("iso_namespace_real.ttl")
      # load_test_file_into_triple_store("form_example_general.ttl")
      # load_test_file_into_triple_store("BC.ttl")
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_general.ttl", "BC.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it 'updates an item' do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      # uri_1 = Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_T2")
      mi = IsoManagedV2.find_minimum(uri_1)
    byebug
      put :update, { id: mi.id, iso_registration_state: { multiple_edit: true }}  
      mi = IsoManagedV2.find_minimum(uri_1)
      expect(mi.has_state.multiple_edit).to eq(true)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end


    it 'prevents updates with invalid data' do
      
    end


  end


end