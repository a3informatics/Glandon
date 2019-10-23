require 'rails_helper'

describe IsoManagedV2Controller do

  include DataHelpers
  include PublicFileHelpers
  include DownloadHelpers

  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers"
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

  end

  describe "Unauthorized User" do
    
    it "status" do
      get :status, { id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1", current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end