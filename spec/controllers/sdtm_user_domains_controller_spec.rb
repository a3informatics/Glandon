require 'rails_helper'

describe SdtmUserDomainsController do

  include DataHelpers
  include PauseHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      Token.delete_all
      @lock_user = User.create :email => "lock@example.com", :password => "changeme" 
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    after :all do
      user = User.where(:email => "lock@example.com").first
      user.destroy
    end

    it "lists all unique user domains, HTML" do
      get :index
      expect(assigns[:sdtm_user_domains].count).to eq(3)
      expect(response).to render_template("index")
    end
    
    it "lists all unique user domains, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_controller_index.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_controller_index.txt")
      expect(response.body).to eq(expected)
    end

    it "lists all released items"

    it "shows the history" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, { :sdtm_user_domain => { :identifier => "DM Domain", :scope_id => ra.namespace.id }}
      expect(response).to render_template("history")
    end

    it "shows the history, redirects when empty" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, { :sdtm_user_domain => { :identifier => "DM Domainx", :scope_id => ra.namespace.id }}
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "allows the domain to be viewed" do
      get :show, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to render_template("show")
    end

    it "initiates the cloning of an IG domain" do
      get :clone_ig, { :sdtm_user_domain => { :sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3" }}
      expect(response).to render_template("clone_ig")
    end

    it "clones an IG domian" do
      params = 
      { 
        :sdtm_user_domain => 
        { 
          :sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", 
          :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3",
          :label => "Clone EG",
          :prefix => "EG"
        }
      }
      post :clone_ig_create, params
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "prevents the cloning of the same domain, duplicate identifier" do
      params = 
      { 
        :sdtm_user_domain => 
        { 
          :sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", 
          :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3",
          :label => "Clone EG",
          :prefix => "EG"
        }
      }
      post :clone_ig_create, params
      url = "http://test.host/sdtm_user_domains/clone_ig?" +
        "sdtm_user_domain%5Bsdtm_ig_domain_id%5D=IG-CDISC_SDTMIGEG&" +
        "sdtm_user_domain%5Bsdtm_ig_domain_namespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmIgD%2FCDISC%2FV3"
      expect(response).to redirect_to(url)
    end

    it "allows a domain to be created"
    
    it "allows a domain to be updated" do
      domain = SdtmUserDomain.find("D-ACME_DSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @user)
      data = domain.to_operation
      params = { :id => "D-ACME_DSDomain", :data => data, :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      put :update, params.merge(format: :json)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      new_domain = SdtmUserDomain.find("D-ACME_DSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      expected = { :data => new_domain.to_operation }
      expect(response.body).to eq(expected.to_json)
    end
    
    it "allows a domain to be updated, error" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      domain.notes = "@@@@@@@@"
      token = Token.obtain(domain, @user)
      data = domain.to_operation
      params = { :id => "D-ACME_DMDomain", :data => data, :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      put :update, params.merge(format: :json)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_update_error.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_update_error.txt")
      expect(response.body).to eq(expected)
    end
    
    it "allows a domain to be updated, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      put :update, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_update_locked.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_update_locked.txt")
      expect(response.body).to eq(expected)
    end
    
    it "edit, no next version" do
      get :edit, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      result = assigns(:sdtm_user_domain)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain") # Note no new version, no copy.
      expect(result.identifier).to eq("DM Domain")
      expect(response).to render_template("edit")
    end

    it "edit domain, next version" #do
      #get :edit, { "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      #result = assigns(:bc)
      #token = assigns(:token)
      #expect(token.user_id).to eq(@user.id)
      #expect(token.item_uri).to eq("http://www.assero.co.uk/MDRBCs/ACME/V2#BC-ACME_BCC25347") # Note no new version, no copy.
      #expect(result.identifier).to eq("BC C25347")
      #expect(response).to render_template("edit")
    #end
    
    it "edits domain, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      get :edit, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "initiates the add operation" do
      get :add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      result = assigns(:sdtm_user_domain)
      bcs = assigns(:bcs)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      expect(bcs.to_json).to eq(BiomedicalConcept.all.to_json)
      expected = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", false)
      expect(result.to_json).to eq(expected.to_json)
    end

    it "initiates the add operation, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      get :add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "initiates the add update operation" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      bc_count = domain.bc_refs.count
      @token = Token.obtain(domain, @user)
      post :update_add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      expect(domain.bc_refs.count).to eq(bc_count + 1)
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end
    
    it "initiates the add update operation, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      post :update_add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end

    it "initiates the remove operation" do
      get :remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      result = assigns(:sdtm_user_domain)
      bcs = assigns(:bcs)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
      expected = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      expect(result.to_json).to eq(expected.to_json)
    end

    it "initiates the remove operation, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      get :remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "initiates the remove update operation" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      bc_count = domain.bc_refs.count
      @token = Token.obtain(domain, @user)
      post :update_remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      expect(domain.bc_refs.count).to eq(bc_count - 1)
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end
    
    it "initiates the remove update operation, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      post :update_remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end

    it "allows a domain to be destroyed" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      audit_count = AuditTrail.count
      bc_count = SdtmUserDomain.all.count
      token_count = Token.all.count
      delete :destroy, { :id => "D-ACME_EGDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(SdtmUserDomain.all.count).to eq(bc_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end

    it "allows the sub-classifications to be found, some found" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :sub_classifications, { sdtm_user_domain: { classification_id: "M-CDISC_SDTMMODEL_C_QUALIFIER", classification_namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_controller_sub_classifications_1.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_controller_sub_classifications_1.txt")
      expect(response.body).to eq(expected)
    end
    
    it "allows the sub-classifications to be found, none found" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :sub_classifications, { sdtm_user_domain: { classification_id: "M-CDISC_SDTMMODEL_C_IDENTIFIER", classification_namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_controller_sub_classifications_2.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_controller_sub_classifications_2.txt")
      expect(response.body).to eq(expected)
    end
    
    it "export_ttl"
    
    it "export_json"
    
    it "full_report"

  end

  describe "Reader User" do
    
    login_reader

    def sub_dir
      return "controllers"
    end

    it "edits an domain" do
      get :edit, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end
    
    it "initiates the cloning of a domain" do
      get :clone_ig, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "clones a domain" do
      post :clone_ig_create, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "initiates adding a BC" do
      get :add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "adding a BC" do
      post :update_add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "initiates removing a BC" do
      get :remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "removing a BC" do
      post :update_remove, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "create"
    
    it "update"

    it "destroy" do
      delete :destroy, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

  end

end