require 'rails_helper'

describe SdtmUserDomainsController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      Token.delete_all
      @lock_user = ua_add_user(email: "lock@example.com")
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("business_operational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_schema_file_into_triple_store("biomedical_concept.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_pe.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "lists all unique user domains, HTML" do
      get :index
      expect(assigns[:sdtm_user_domains].count).to eq(4)
      expect(response).to render_template("index")
    end
    
    it "lists all unique user domains, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "sdtm_user_domain_controller_index.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_controller_index.txt")
      expect(response.body).to eq(expected)
    end

    it "lists all released items"

    it "shows the history" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, params:{ :sdtm_user_domain => { :identifier => "DM Domain", :scope_id => ra.ra_namespace.id }}
      expect(response).to render_template("history")
    end

    it "shows the history, redirects when empty" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, params:{ :sdtm_user_domain => { :identifier => "DM Domainx", :scope_id => ra.ra_namespace.id }}
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "allows the domain to be viewed" do
      get :show, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to render_template("show")
    end

    it "initiates the cloning of an IG domain" do
      get :clone_ig, params:{ :sdtm_user_domain => { :sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3" }}
      expect(response).to render_template("clone_ig")
    end

    it "clones an IG domian" do
      post :clone_ig_create, params:{ :sdtm_user_domain => { :sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3",:label => "Clone EG",:prefix => "EG"}}
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "prevents the cloning of the same domain, duplicate identifier" do
      post :clone_ig_create, params:{:sdtm_user_domain => {:sdtm_ig_domain_id => "IG-CDISC_SDTMIGEG", :sdtm_ig_domain_namespace => "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3",:label => "Clone EG",:prefix => "EG"}}
      url = "http://test.host/sdtm_user_domains/clone_ig?" +
        "sdtm_user_domain%5Bsdtm_ig_domain_id%5D=IG-CDISC_SDTMIGEG&" +
        "sdtm_user_domain%5Bsdtm_ig_domain_namespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmIgD%2FCDISC%2FV3"
      expect(response).to redirect_to(url)
    end

    it "allows a domain to be created"
    
    it "allows a domain to be updated - WILL CURRENTLY FAIL (ordinal as integer)" do
      domain = SdtmUserDomain.find("D-ACME_DSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @user)
      data = domain.to_operation
      put :update, params:{ :id => "D-ACME_DSDomain", :data => data, :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}.merge(format: :json)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      new_domain = SdtmUserDomain.find("D-ACME_DSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      expected = { :data => new_domain.to_operation }
      expect(response.body).to eq(expected.to_json)
    end
    
    it "allows a domain to be updated, error - WILL CURRENTLY FAIL (ordinal as integer)" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      domain.notes = "@@@£±£±"
      token = Token.obtain(domain, @user)
      data = domain.to_operation
      put :update, params:{ :id => "D-ACME_DMDomain", :data => data, :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}.merge(format: :json)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
    #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_update_error.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_update_error.txt")
      expect(response.body).to eq(expected)
    end
    
    it "allows a domain to be updated, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      put :update, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
    #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_update_locked.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_update_locked.txt")
      expect(response.body).to eq(expected)
    end
    
    it "edit, no next version" do
      get :edit, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      result = assigns(:sdtm_user_domain)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain") # Note no new version, no copy.
      expect(result.identifier).to eq("DM Domain")
      expect(response).to render_template("edit")
    end

    it "edit domain, next version" do
      get :edit, params:{ id: "D-ACME_PEDomain", sdtm_user_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      result = assigns(:sdtm_user_domain)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V2#D-ACME_PEDomain") # Note new version, copy.
      expect(result.identifier).to eq("PE Domain")
      expect(response).to render_template("edit")
    end
    
    it "edits domain, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      get :edit, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "edits domain, copy, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      # Lock the new form
      new_form = SdtmUserDomain.new
      new_form.id = "D-ACME_PEDomain"
      new_form.namespace = "http://www.assero.co.uk/MDRSdtmUD/ACME/V2" # Note the V4, the expected new version.
      new_form.registrationState.registrationAuthority = IsoRegistrationAuthority.owner
      new_token = Token.obtain(new_form, @lock_user)
      get :edit, params:{ id: "D-ACME_PEDomain", sdtm_user_domain: { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    it "initiates the add operation" # do
    #   get :add, { :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
    #   result = assigns(:sdtm_user_domain)
    #   bcs = assigns(:bcs)
    #   token = assigns(:token)
    #   expect(token.user_id).to eq(@user.id)
    #   expect(token.item_uri).to eq("http://www.assero.co.uk/MDRSdtmUD/ACME/V1#D-ACME_DMDomain")
    #   expect(bcs.to_json).to eq(BiomedicalConcept.list.to_json)
    #   expected = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", false)
    #   expect(result.to_json).to eq(expected.to_json)
    # end

    it "only lists released BCs for the add operation, 1 or more tests as needed"

    it "initiates the add operation, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      get :add, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    # it "initiates the add update operation" do
    #   domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
    #   bc_count = domain.bc_refs.count
    #   @token = Token.obtain(domain, @user)
    #   post :update_add, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
    #     :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
    #   domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
    #   expect(domain.bc_refs.count).to eq(bc_count + 1)
    #   expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    # end
    
    it "initiates the add update operation, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      post :update_add, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end

    it "initiates the remove operation" do
      get :remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
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
      get :remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/sdtm_user_domains")
    end

    # it "initiates the remove update operation" do
    #   domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
    #   bc_count = domain.bc_refs.count
    #   @token = Token.obtain(domain, @user)
    #   post :update_remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
    #     :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
    #   domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
    #   expect(domain.bc_refs.count).to eq(bc_count - 1)
    #   expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    # end
    
    it "initiates the remove update operation, already locked" do
      domain = SdtmUserDomain.find("D-ACME_DMDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      token = Token.obtain(domain, @lock_user)
      post :update_remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1", 
        :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("http://test.host/sdtm_user_domains/D-ACME_DMDomain?sdtm_user_domain%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRSdtmUD%2FACME%2FV1")
    end

    it "allows a domain to be destroyed" do
      @request.env['HTTP_REFERER'] = 'http://test.host/sdtm_user_domains'
      audit_count = AuditTrail.count
      bc_count = SdtmUserDomain.all.count
      token_count = Token.all.count
      delete :destroy, params:{ :id => "D-ACME_EGDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(SdtmUserDomain.all.count).to eq(bc_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end

    it "allows the sub-classifications to be found, some found" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :sub_classifications, params:{ sdtm_user_domain: { classification_id: "M-CDISC_SDTMMODEL_C_QUALIFIER", classification_namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
      result = result.sort_by {|k| k["key"]}
    #write_yaml_file(result, sub_dir, "sdtm_user_domain_controller_sub_classifications_1.txt")
      expected = read_yaml_file(sub_dir, "sdtm_user_domain_controller_sub_classifications_1.txt")
      expect(result).to eq(expected)
    end
    
    it "allows the sub-classifications to be found, none found" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :sub_classifications, params:{ sdtm_user_domain: { classification_id: "M-CDISC_SDTMMODEL_C_IDENTIFIER", classification_namespace: "http://www.assero.co.uk/MDRSdtmM/CDISC/V3" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #write_text_file_2(response.body, sub_dir, "sdtm_user_domain_controller_sub_classifications_2.txt")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_controller_sub_classifications_2.txt")
      expect(response.body).to eq(expected)
    end
    
    it "exports TTL" do
      # @todo Needs improving
      get :export_ttl, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
    end
    
    it "exports JSON" do
      # @todo Needs improving
      get :export_json, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
    end
    
    it "exports XPT" do
      # @todo Needs improving
      get :export_xpt_metadata, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
    end
    
    it "full_report" do
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :full_report, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response.content_type).to eq("application/pdf")
      expect(response.header["Content-Disposition"]).to eq("inline; filename=\"ACME_DM Domain.pdf\"")
      expect(assigns(:render_args)).to eq({page_size: @user.paper_size, lowquality: true, basic_auth: nil})
    end

  end

  describe "Reader User" do
    
    login_reader

    def sub_dir
      return "controllers"
    end

    it "edits an domain" do
      get :edit, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end
    
    it "initiates the cloning of a domain" do
      get :clone_ig, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "clones a domain" do
      post :clone_ig_create, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "initiates adding a BC" do
      get :add, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "adding a BC" do
      post :update_add, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "initiates removing a BC" do
      get :remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "removing a BC" do
      post :update_remove, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

    it "create"
    
    it "update"

    it "destroy" do
      delete :destroy, params:{ :id => "D-ACME_DMDomain", :sdtm_user_domain => { :namespace => "http://www.assero.co.uk/MDRSdtmUD/ACME/V1" }}
      expect(response).to redirect_to("/")
    end

  end

end