require 'rails_helper'

describe FormsController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers/forms"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000150_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "show" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
      get :show, params: { :id => form.id}
      expect(response).to render_template("show")
    end

    # it "show results" do
    #   form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   expect(Form).to receive(:find_minimum).and_return(form)
    #   get :show_data, params:{id: form.id}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "history_results_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    # end

    it "shows the history, page" do
      form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/Height__Pilot_/V1#F"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Form).to receive(:history_pagination).with({identifier: form.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([form])
      get :history, params:{form: {identifier: form.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it "shows the history, initial view" do
      params = {}
      expect(Form).to receive(:latest).and_return(Form.new)
      get :history, params:{form: {identifier: "Height (Pilot)", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("Height (Pilot)")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

    # it "provides a new object" do
    #   get :new
    #   result = assigns[:form]
    #   expected = Form.new
    #   expected.creationDate = result.creationDate
    #   expected.lastChangeDate = result.lastChangeDate
    #   expect(result.to_json).to eq(expected.to_json)
    #   expect(response).to render_template("new")
    # end

    # it "lists all unique forms, HTML" do
    #   get :index
    #   expect(assigns[:forms].count).to eq(4)
    #   expect(response).to render_template("index")
    # end
    
    # it "lists all unique forms, JSON" do  
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :index
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    # #Xwrite_text_file_2(response.body, sub_dir, "forms_controller_index.txt")
    #   expected = read_text_file_2(sub_dir, "forms_controller_index.txt")
    #   expect(response.body).to eq(expected)

    # end

    # it "shows the history" do
    #   get :history, { :identifier => "DM1 01", :scope_id => IsoRegistrationAuthority.owner.ra_namespace.id }
    #   expect(response).to render_template("history")
    # end

    # it "shows the history, redirects when empty" do
    #   get :history, { :identifier => "DM1 01X", :scope_id => IsoRegistrationAuthority.owner.ra_namespace.id }
    #   expect(response).to redirect_to("/forms")
    # end

    # it "initiates the creation of a new placeholder form" do
    #   get :placeholder_new
    #   expect(assigns[:form].to_json).to eq(Form.new.to_json)
    #   expect(response).to render_template("placeholder_new")
    # end

    # it "creates the placeholder form" do
    #   audit_count = AuditTrail.count
    #   form_count = Form.all.count
    #   post :placeholder_create, form: { :identifier => "NEW TH", :label => "New TH Form", :freeText => "* List Item 1\n* List Item 2\n\nThis form is required to do the following:\n\n* Collect the date" }
    #   form = assigns(:form)
    #   expect(form.errors.count).to eq(0)
    #   expect(Form.unique.count).to eq(form_count + 1) 
    #   expect(flash[:success]).to be_present
    #   expect(AuditTrail.count).to eq(audit_count + 1)
    #   expect(response).to redirect_to("/forms")
    # end

    # it "edit, no next version" do
    #   get :edit, { :id => "F-ACME_NEWTH", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   result = assigns(:form)
    #   token = assigns(:token)
    #   expect(token.user_id).to eq(@user.id)
    #   expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_NEWTH") # Note no new version, no copy.
    #   expect(result.identifier).to eq("NEW TH")
    #   expect(response).to render_template("edit")
    # end
    
    # it "edit form, next version" do
    #   get :edit, { :id => "F-ACME_VSBASELINE1", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   result = assigns(:form)
    #   token = assigns(:token)
    #   expect(token.user_id).to eq(@user.id)
    #   expect(token.item_uri).to eq("http://www.assero.co.uk/MDRForms/ACME/V2#F-ACME_VSBASELINE") # Note new version, copy.
    #   expect(result.identifier).to eq("VS BASELINE")
    #   expect(response).to render_template("edit")
    # end
    
    # it "edits form, already locked" do
    #   @request.env['HTTP_REFERER'] = 'http://test.host/forms'
    #   form = Form.find("F-ACME_NEWTH", "http://www.assero.co.uk/MDRForms/ACME/V1") 
    #   token = Token.obtain(form, @lock_user)
    #   get :edit, { :id => "F-ACME_NEWTH", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/forms")
    # end

    # it "edits form, copy, already locked" do
    #   @request.env['HTTP_REFERER'] = 'http://test.host/forms'
    #   # Lock the new form
    #   new_form = Form.new
    #   new_form.id = "F-ACME_VSBASELINE"
    #   new_form.namespace = "http://www.assero.co.uk/MDRForms/ACME/V2" # Note the V2, the expected new version.
    #   new_form.registrationState.registrationAuthority = IsoRegistrationAuthority.owner
    #   new_token = Token.obtain(new_form, @lock_user)
    #   # Attempt to edit
    #   get :edit, { :id => "F-ACME_VSBASELINE1", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/forms")
    # end

    # it "initiates the cloning of a form" do
    #   get :clone, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.id).to eq("F-ACME_DM101")
    #   expect(response).to render_template("clone")
    # end

    # it "clones a form" do
    #   audit_count = AuditTrail.count
    #   form_count = Form.unique.count
    #   post :clone_create,  { form: { :identifier => "CLONE", :label => "New Clone" }, :form_id => "F-ACME_DM101", :form_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.errors.count).to eq(0)
    #   expect(Form.unique.count).to eq(form_count + 1) 
    #   expect(flash[:success]).to be_present
    #   expect(AuditTrail.count).to eq(audit_count + 1)
    #   expect(response).to redirect_to("/forms")
    # end

    # it "clones a form, error duplicate" do
    #   audit_count = AuditTrail.count
    #   form_count = Form.all.count
    #   post :clone_create,  { form: { :identifier => "CLONE", :label => "New Clone" }, :form_id => "F-ACME_DM101", :form_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.errors.count).to eq(1)
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/forms/clone?id=F-ACME_DM101&namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRForms%2FACME%2FV1")
    # end

    # it "initiates the branching of a form" do
    #   get :branch, { :id => "F-ACME_DM1BRANCH", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.id).to eq("F-ACME_DM1BRANCH")
    #   expect(response).to render_template("branch")
    # end

    # it "branches a form" do
    #   audit_count = AuditTrail.count
    #   form_count = Form.unique.count
    #   post :branch_create,  { form: { :identifier => "BRANCH", :label => "New Branch" }, :form_id => "F-ACME_DM1BRANCH", :form_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.errors.count).to eq(0)
    #   expect(Form.unique.count).to eq(form_count + 1) 
    #   expect(flash[:success]).to be_present
    #   expect(AuditTrail.count).to eq(audit_count + 1)
    #   expect(response).to redirect_to("/forms")
    #   item = Form.find("F-ACME_BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #   expect(item.is_a_branch?).to eq(true)
    # end

    # it "branches a form, error duplicate" do
    #   audit_count = AuditTrail.count
    #   form_count = Form.all.count
    #   post :branch_create,  { form: { :identifier => "BRANCH", :label => "New Branch" }, :form_id => "F-ACME_DM1BRANCH", :form_namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   form = assigns(:form)
    #   expect(form.errors.count).to eq(1)
    #   expect(flash[:error]).to be_present
    #   expect(response).to redirect_to("/forms/branch?id=F-ACME_DM1BRANCH&namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRForms%2FACME%2FV1")
    # end

    # it "creates"
    
    # it "updates"

    # it "destroy" do
    #   @request.env['HTTP_REFERER'] = 'http://test.host/forms'
    #   audit_count = AuditTrail.count
    #   form_count = Form.all.count
    #   token_count = Token.all.count
    #   delete :destroy, { :id => "F-ACME_CLONE", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(Form.all.count).to eq(form_count - 1)
    #   expect(AuditTrail.count).to eq(audit_count + 1)
    #   expect(Token.count).to eq(token_count)
    # end

    # it "show" do
    #   get :show, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response).to render_template("show")
    # end

    # it "view " do
    #   get :view, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response).to render_template("view")
    # end

    # it "export_ttl" do
    #   get :export_ttl, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    # end

    # it "export_json" do
    #   get :export_json, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    # end

    # it "export_odm" do
    #   get :export_odm, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    # end
    
    # it "presents acrf as pdf" do
    #   request.env['HTTP_ACCEPT'] = "application/pdf"
    #   get :acrf, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response.content_type).to eq("application/pdf")
    #   expect(response.header["Content-Disposition"]).to eq("inline; filename=\"ACME_DM1 01_CRF.pdf\"")
    #   expect(assigns(:render_args)).to eq({page_size: @user.paper_size, lowquality: true, basic_auth: nil})
    # end

    # it "presents acrf as pdf" do
    #   get :acrf, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response).to render_template("acrf")
    # end

    # it "presents acrf as pdf" do
    #   request.env['HTTP_ACCEPT'] = "application/pdf"
    #   get :crf, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response.content_type).to eq("application/pdf")
    #   expect(response.header["Content-Disposition"]).to eq("inline; filename=\"ACME_DM1 01_CRF.pdf\"")
    #   expect(assigns(:render_args)).to eq({page_size: @user.paper_size, lowquality: true, basic_auth: nil})
    # end

    # it "presents acrf as pdf" do
    #   get :crf, { :id => "F-ACME_DM101", :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }
    #   expect(response).to render_template("crf")
    # end

  end

  # describe "Unauthorized User" do
    
  #   login_reader

  #   it "prevents access to a reader, placeholder new" do
  #     get :placeholder_new
  #     expect(response).to redirect_to("/")
  #   end

  #   it "prevents access to a reader, placeholder create" do
  #     get :placeholder_create
  #     expect(response).to redirect_to("/")
  #   end

  #   it "prevents access to a reader, edit" do
  #     get :edit, id: 1
  #     expect(response).to redirect_to("/")
  #   end

  #   it "prevents access to a reader, update" do
  #     put :update, id: 1
  #     expect(response).to redirect_to("/")
  #   end

  #   it "prevents access to a reader, destroy" do
  #     delete :destroy, id: 1
  #     expect(response).to redirect_to("/")
  #   end

  # end

end