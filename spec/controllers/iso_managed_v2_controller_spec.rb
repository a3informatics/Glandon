require 'rails_helper'

describe IsoManagedV2Controller do

  include DataHelpers
  include PublicFileHelpers
  include DownloadHelpers

  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers/iso_managed_v2"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_managed_data.ttl", "iso_managed_data_2.ttl", 
        "iso_managed_data_3.ttl", "form_example_vs_baseline.ttl", "form_example_general.ttl", "form_example_dm1_branch.ttl", "BC.ttl", "BCT.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..10)
    end

    it "status" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      managed_item = IsoManagedV2.find_minimum(uri.to_id)
      get :status, {id: uri.to_id, iso_managed: { current_id: "test" }}
      expect(assigns(:managed_item).to_h).to eq(managed_item.to_h)
      expect(assigns(:current_id)).to eq("test")
      expect(assigns(:close_path)).to eq("/thesauri/history/?thesauri[identifier]=#{managed_item.scoped_identifier}&thesauri[scope_id]=#{managed_item.scope.id}")
      expect(response).to render_template("status")
    end

    it "make current" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      post :make_current, {id: uri_1.to_id, iso_managed: { current_id: "test" }}
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)      
      expect(mi_1.current?).to eq(true)
      expect(mi_2.current?).to eq(false)
      post :make_current, {id: uri_2.to_id, iso_managed: { current_id: uri_1.to_id }}
      mi_1 = IsoManagedV2.find_minimum(uri_1.to_id)
      mi_2 = IsoManagedV2.find_minimum(uri_2.to_id)      
      expect(mi_1.current?).to eq(false)
      expect(mi_2.current?).to eq(true)
    end

    it 'updates the status' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      post :update_status, { id: mi.id, iso_managed: { registration_status: "Retired", previous_state: "Standard", 
        administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(uri_1)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_1.yaml", equate_method: :hash_equal, write_file: true)
      expect(response).to redirect_to("/registration_states")
    end

    it 'prevents updates with invalid data (the state)' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      uri_1 = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      mi = IsoManagedV2.find_minimum(uri_1)
      post :update_status, { id: mi.id, iso_managed: { registration_status: "X", previous_state: "Standard", 
        administrative_note: "X1", unresolved_issue: "X2" }}
      actual = IsoManagedV2.find_minimum(uri_1)
      check_file_actual_expected(actual.to_h, sub_dir, "update_status_expected_2.yaml", equate_method: :hash_equal, write_file: true)
      expect(response).to redirect_to("/registration_states")
    end

  end

  describe "Unauthorized User" do
    
    it "status" do
      get :status, { id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "make current" do
      post :make_current, { id: "F-ACME_TEST", iso_managed: { current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "update_status" do
      post :update_status, { id: "F-ACME_TEST"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end