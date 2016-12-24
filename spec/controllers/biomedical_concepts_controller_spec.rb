require 'rails_helper'

describe BiomedicalConceptsController do

  include DataHelpers
  include PauseHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "lists all unique templates, HTML" do
      get :index
      expect(assigns[:bcs].count).to eq(13)
      expect(response).to render_template("index")
    end
    
    it "lists all unique templates, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      write_text_file_2(response.body, sub_dir, "bc_controller_index.txt")
      expected = read_text_file_2(sub_dir, "bc_controller_index.txt")
      expect(response.body).to eq(expected)
    end

    it "lists all released items"

    it "shows the history" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, { :biomedical_concept => { :identifier => "BC_C49677", :scope_id => ra.namespace.id }}
      expect(response).to render_template("history")
    end

    it "shows the history, redirects when empty" do
      ra = IsoRegistrationAuthority.find_by_short_name("ACME")
      get :history, { :biomedical_concept => { :identifier => "BC_C49678x", :scope_id => ra.namespace.id }}
      expect(response).to redirect_to("/biomedical_concepts")
    end

    it "initiates the creation of a new BC" do
      item = BiomedicalConceptTemplate.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
      get :new_from_template, { :biomedical_concept => { :uri => item.uri.to_s }}
      expect(assigns[:bct].to_json).to eq(item.to_json)
      expect(response).to render_template("new_from_template")
    end

    it "creates the new BC" do
      item = BiomedicalConceptTemplate.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
      audit_count = AuditTrail.count
      bc_count = BiomedicalConcept.all.count
      post :create, { :biomedical_concept => { :bct_id => item.id, :bct_namespace => item.namespace, :identifier => "NEW BC", :label => "New BC" }}
      bc = assigns(:bc)
      puts bc.errors.full_messages.to_sentence
      expect(bc.errors.count).to eq(0)
      expect(BiomedicalConcept.unique.count).to eq(bc_count + 1) 
      expect(flash[:success]).to be_present
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("/biomedical_concepts")
    end

    it "edit, no next version" do
      get :edit, { :id => "F-ACME_NEWTH", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      result = assigns(:bc)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_NEWTH") # Note no new version, no copy.
      expect(result.identifier).to eq("NEW TH")
      expect(response).to render_template("edit")
    end
    
    it "edit form, next version" do
      get :edit, { :id => "F-ACME_VSBASELINE1", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      result = assigns(:bc)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V2#F-ACME_VSBASELINE") # Note no new version, no copy.
      expect(result.identifier).to eq("VS BASELINE")
      expect(response).to render_template("edit")
    end
    
    it "edits form, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/biomedical_concepts'
      bc = BiomedicalConcept.find("F-ACME_NEWTH", "http://www.assero.co.uk/MDRForms/ACME/V1") 
      token = Token.obtain(bc, @lock_user)
      get :edit, { :id => "F-ACME_NEWTH", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/biomedical_concepts")
    end

    it "initiates the cloning of a BC" do
      get :clone, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      bc = assigns(:bc)
      expect(bc.id).to eq("F-ACME_DM101")
      expect(response).to render_template("clone")
    end

    it "clones a BC" do
      audit_count = AuditTrail.count
      bc_count = BiomedicalConcept.unique.count
      post :clone_create,  { bc: { :identifier => "CLONE", :label => "New Clone" }, :bc_id => "F-ACME_DM101", :bc_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      bc = assigns(:bc)
      expect(bc.errors.count).to eq(0)
      expect(BiomedicalConcept.unique.count).to eq(bc_count + 1) 
      expect(flash[:success]).to be_present
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("/biomedical_concepts")
    end

    it "clones a BC, error duplicate" do
      audit_count = AuditTrail.count
      bc_count = BiomedicalConcept.all.count
      post :clone_create,  { bc: { :identifier => "CLONE", :label => "New Clone" }, :bc_id => "F-ACME_DM101", :bc_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      bc = assigns(:bc)
      expect(form.errors.count).to eq(1)
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/biomedical_concepts/clone?id=F-ACME_DM101&namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRForms%2FACME%2FV1")
    end

    it "create"
    it "update"

    it "destroy" do
      @request.env['HTTP_REFERER'] = 'http://test.host/biomedical_concepts'
      audit_count = AuditTrail.count
      bc_count = BiomedicalConcept.all.count
      token_count = Token.all.count
      delete :destroy, { :id => "F-ACME_CLONE", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
      expect(BiomedicalConcept.all.count).to eq(bc_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end
    
    it "upgrade"

    it "allows the BC to be viewed" do
      get :show, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to render_template("show")
    end

    it "export_ttl"
    it "export_json"
    it "upgrade"

  end

  describe "Reader User" do
    
    login_reader

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "initiates the creation of a new BC" do
      get :new_from_template, { :biomedical_concept => { :uri => "http://wwww.example.com" }}
      expect(response).to redirect_to("/")
    end

    it "creates the new BC" do
      post :create, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to redirect_to("/")
    end

    it "edits an BC" do
      get :edit, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to redirect_to("/")
    end
    
    it "initiates the cloning of a BC" do
      get :clone, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to redirect_to("/")
    end

    it "clones a BC" do
      post :clone_create, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to redirect_to("/")
    end

    it "create"
    it "update"

    it "destroy" do
      delete :destroy, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response).to redirect_to("/")
    end
    
  end

end