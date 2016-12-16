require 'rails_helper'

describe FormsController do

  include DataHelpers
  include PauseHelpers
  
  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers/forms"
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
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    it "provides a new object" do
      get :new
      result = assigns[:form]
      expected = Form.new
      expected.creationDate = result.creationDate
      expected.lastChangeDate = result.lastChangeDate
      expect(result.to_json).to eq(expected.to_json)
      expect(response).to render_template("new")
    end

    it "lists all unique forms, HTML" do
      get :index
      expect(assigns[:forms].count).to eq(3)
      expect(response).to render_template("index")
    end
    
    it "lists all unique forms, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      #write_text_file_2(response.body, sub_dir, "forms_controller_index.txt")
      expected = read_text_file_2(sub_dir, "forms_controller_index.txt")
      expect(response.body).to eq(expected)
    end

    it "shows the history" do
      get :history
      expect(response).to render_template("history")
    end

    it "placeholder_new" do
      get :new
      expect(assigns[:form].to_json).to eq(Form.new.to_json)
      expect(response).to render_template("new")
    end

    it "placeholder_create" do
      audit_count = AuditTrail.count
      form_count = Form.all.count
      post :placeholder_create, form: { :identifier => "NEW TH", :label => "New Thesaurus", :freeText => "* List Item 1\n* List Item 2\n\nThis form is required to do the following:\n\n* Collect the date" }
      form = assigns(:form)
      expect(form.errors.count).to eq(0)
      expect(Form.unique.count).to eq(form_count + 1) 
      expect(flash[:success]).to be_present
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("/forms")
    end

    it "edit"
    it "clone"
    it "create"
    it "update"
    it "destroy"

    it "show" do
      get :show, { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      expect(response).to render_template("show")
    end

    it "view " do
      get :view, { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V39" }
      expect(response).to render_template("view")
    end

    it "export_ttl"
    it "export_json"
    it "export_odm"
    it "acrf"
    it "acrf_report"
    it "crf"
    it "crf_report"
    it "full_crf_report"

  end

  describe "Unauthorized User" do
    
    login_reader

    it "prevents access to a reader, placeholder new" do
      get :placeholder_new
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, placeholder create" do
      get :placeholder_create
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, edit" do
      get :edit, id: 1
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, update" do
      put :update, id: 1
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      delete :destroy, id: 1
      expect(response).to redirect_to("/")
    end

  end

end