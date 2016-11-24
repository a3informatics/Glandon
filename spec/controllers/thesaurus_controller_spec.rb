require 'rails_helper'

describe ThesauriController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_curator

    it "clears triple store and loads test data" do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
    end

    it "new thesaurus" do
      get :new
      expect(response).to render_template("new")
    end

    it "index thesauri" do
      thesauri = Thesaurus.unique
      get :index
      expect(assigns(:thesauri).to_json).to eq(thesauri.to_json)
      expect(response).to render_template("index")
    end

    it "thesaurus history" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :history, params
      expect(response).to render_template("history")
    end

    it 'creates thesaurus' do
      audit_count = AuditTrail.count
      expect(Thesaurus.all.count).to eq(1) 
      post :create, thesaurus: { :identifier => "NEW TH", :label => "New Thesaurus" }
      expect(assigns(:thesaurus).errors.count).to eq(0)
      expect(Thesaurus.all.count).to eq(2) 
      expect(flash[:success]).to be_present
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("/thesauri")
    end

    it 'creates thesaurus, fails bad identifier' do
      expect(Thesaurus.all.count).to eq(2) 
      post :create, thesaurus: { :identifier => "NEW_TH!@£$%^&*", :label => "New Thesaurus" }
      expect(assigns(:thesaurus).errors.count).to eq(1)
      expect(Thesaurus.all.count).to eq(2) 
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/thesauri/new")
    end

    it 'edits thesaurus'

    it 'adds a child thesaurus concept' do
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => 
        [
          {
            :id => "", 
            :namespace => "" ,
            :label => "New TC",
            :identifier => "A99999", 
            :notation => "NEW 999", 
            :synonym => "New syn 999", 
            :definition => "New def 999", 
            :preferredTerm => "New PT 999",
            :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
          }
        ]
      }
      audit_count = AuditTrail.count
      post :add_child, params
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc = ThesaurusConcept.find("TH-SPONSOR_CT-1_A99999", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A99999")
      expect(tc.notation).to eq("NEW 999")
      expect(tc.definition).to eq("New def 999")
      expect(tc.preferredTerm).to eq("New PT 999")
      expect(tc.synonym).to eq("New syn 999")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(th.children.count).to eq(4)
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it 'adds a child thesaurus concept - error definition' do
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => 
        [
          {
            :id => "", 
            :namespace => "" ,
            :label => "New TC",
            :identifier => "A99998", 
            :notation => "NEW 998", 
            :synonym => "New syn 998", 
            :definition => "New def 998!@£$%^&*(", 
            :preferredTerm => "New PT 998",
            :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
          }
        ]
      }
      audit_count = AuditTrail.count
      post :add_child, params
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(response.code).to eq("422")
      expect(th.children.count).to eq(4)
      expect(AuditTrail.count).to eq(audit_count)
    end

    it 'deletes thesaurus' do
      params = 
        {
          :id => "TH-ACME_NEWTH", 
          :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        }
      audit_count = AuditTrail.count
      delete :destroy, params
      expect(Thesaurus.all.count).to eq(1)
      expect(AuditTrail.count).to eq(audit_count + 1)
    end
    
    it "returns a thesaurus as JSON" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
    end

    it "returns a thesaurus as HTML" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      get :show, params
      expect(response.content_type).to eq("text/html")
      expect(response.code).to eq("200")    
    end

    it "view a thesaurus" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      get :view, params
      expect(response.content_type).to eq("text/html")
      expect(response.code).to eq("200")    
    end

    it "def search"
    it "def next"
    it "def export_ttl"

  end

end