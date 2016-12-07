require 'rails_helper'
describe ThesaurusConceptsController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_curator

    before :all do
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
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "edits concept, top level" do
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      result = assigns(:thesaurus_concept)
      referer_path = assigns(:referer_path)
      close_path = assigns(:close_path)
      expect(result.identifier).to eq("A00001")
      expect(result.notation).to eq("VSTEST")
      expect(result.definition).to eq("A set of additional Vital Sign Test Codes to extend the CDISC set.")
      expect(result.preferredTerm).to eq("")
      expect(result.synonym).to eq("")
      expect(referer_path).to eq("/thesauri/TH-SPONSOR_CT-1/edit?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FACME%2FV1")
      expect(close_path).to eq("/thesauri/history?identifier=CDISC+EXT&scope_id=NS-ACME")
      expect(response).to render_template("edit")
    end

    it "edits concept, lower level" do
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      params = 
      {
        :id => "THC-A00002", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      result = assigns(:thesaurus_concept)
      referer_path = assigns(:referer_path)
      close_path = assigns(:close_path)
      expect(result.identifier).to eq("A00002")
      expect(result.notation).to eq("APGAR")
      expect(result.definition).to eq("An APGAR Score")
      expect(result.preferredTerm).to eq("")
      expect(result.synonym).to eq("")
      expect(referer_path).to eq("/thesaurus_concepts/THC-A00001/edit?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FACME%2FV1")
      expect(close_path).to eq("/thesauri/history?identifier=CDISC+EXT&scope_id=NS-ACME")
      expect(response).to render_template("edit")
    end

    it "edits concept, no token" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      expect(response).to redirect_to("/thesauri/history?identifier=CDISC+EXT&scope_id=NS-ACME")
    end

    it "gets children" do
      params = 
      {
        :id => "THC-A00010", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :children, params
      tc = ThesaurusConcept.find("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1", false)
      result = {}
      result[:data] = []
      tc.parentIdentifier = "A00010"
      result[:data] << tc.to_json
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(result.to_json)
    end

    it "updates concept with audit" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :identifier => "A00001", 
          :notation => "NEW NOTATION", 
          :synonym => "New syn", 
          :definition => "New def", 
          :preferredTerm => "New PT"
        }
      }
      audit_count = AuditTrail.count
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      put :update, params
      tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A00001")
      expect(tc.notation).to eq("NEW NOTATION")
      expect(tc.definition).to eq("New def")
      expect(tc.preferredTerm).to eq("New PT")
      expect(tc.synonym).to eq("New syn")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "updates concept with no audit, token refreshed" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :identifier => "A00001", 
          :notation => "NEW NOTATION", 
          :synonym => "New syn", 
          :definition => "New def plus stuff", 
          :preferredTerm => "New PT"
        }
      }
      audit_count = AuditTrail.count
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      token.refresh
      put :update, params
      tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A00001")
      expect(tc.notation).to eq("NEW NOTATION")
      expect(tc.definition).to eq("New def plus stuff")
      expect(tc.preferredTerm).to eq("New PT")
      expect(tc.synonym).to eq("New syn")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "fails to update concept with error" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :identifier => "A00001", 
          :notation => "NEW NOTATION!@£$%^&*", 
          :synonym => "Ned syn", 
          :definition => "New def", 
          :preferredTerm => "New PT"
        }
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      put :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"fieldErrors\":[{\"name\":\"notation\",\"status\":\"contains invalid characters\"}]}")
    end

    it "fails to update concept without token" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :identifier => "A00001", 
          :notation => "NEW NOTATION!@£$%^&*", 
          :synonym => "Ned syn", 
          :definition => "New def", 
          :preferredTerm => "New PT"
        }
      }
      put :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"data\":null,\"link\":\"/thesauri/history?identifier=CDISC+EXT\\u0026scope_id=NS-ACME\"}")
    end

    it "adds child concept" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999", 
          :notation => "NEW 999", 
          :synonym => "New syn 999", 
          :definition => "New def 999", 
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      post :add_child, params
      tc = ThesaurusConcept.find("THC-A00001_A0000999", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A0000999")
      expect(tc.notation).to eq("NEW 999")
      expect(tc.definition).to eq("New def 999")
      expect(tc.preferredTerm).to eq("New PT 999")
      expect(tc.synonym).to eq("New syn 999")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "fails to add child concept, duplicate" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999", 
          :notation => "NEW 999", 
          :synonym => "New syn 999", 
          :definition => "New def", 
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      post :add_child, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The Thesaurus Concept, identifier A0000999, already exists in the database.\"]}")
    end
    
    it "fails to add child concept, no token" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept => 
        {
          :id => "", 
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999", 
          :notation => "NEW 999", 
          :synonym => "New syn 999", 
          :definition => "New def", 
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      post :add_child, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The changes were not saved as the edit lock timed out.\"]}")
    end
    
    it "fails to delete a concept, no token" do
      params = 
      {
        :id => "THC-A00001_A0000999", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      delete :destroy, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The changes were not saved as the edit lock timed out.\"]}")
    end

    it "deletes a concept" do
      params = 
      {
        :id => "THC-A00001_A0000999", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      delete :destroy, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "returns a concept as JSON" do
      params = { :id => "THC-A00001", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
    end

    it "returns a concept as HTML" do
      params = { :id => "THC-A00001", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      get :show, params
      expect(response.content_type).to eq("text/html")
      expect(response.code).to eq("200")    
    end

  end

end