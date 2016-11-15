require 'rails_helper'

describe ThesaurusConceptsController do

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
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
    end

    it "edits concept" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A00001")
      expect(tc.notation).to eq("VSTEST")
      expect(tc.definition).to eq("A set of additional Vital Sign Test Codes to extend the CDISC set.")
      expect(tc.preferredTerm).to eq("")
      expect(tc.synonym).to eq("")
      expect(response).to render_template("edit")
    end

    it "updates concept" do
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => 
        [
          {
            :id => "THC-A00001", 
            :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
            :identifier => "NEWNEW", 
            :notation => "NEW NOTATION", 
            :synonym => "New syn", 
            :definition => "New def", 
            :preferredTerm => "New PT"
          }
        ]
      }
      put :update, params
      tc = ThesaurusConcept.find("THC-A00001", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A00001")
      expect(tc.notation).to eq("NEW NOTATION")
      expect(tc.definition).to eq("New def")
      expect(tc.preferredTerm).to eq("New PT")
      expect(tc.synonym).to eq("New syn")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "fails to update concept with error" do
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => 
        [
          {
            :id => "THC-A00001", 
            :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
            :identifier => "NEWNEW", 
            :notation => "NEW NOTATION!@£$%^&*", 
            :synonym => "Ned syn", 
            :definition => "New def", 
            :preferredTerm => "New PT"
          }
        ]
      }
      put :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"Notation contains invalid characters\"]}")
    end

    it "adds child concept" do
      params = 
      {
        :id => "THC-A00001", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => 
        [
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
        ]
      }
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
        :children => 
        [
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
        ]
      }
      post :add_child, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The Thesaurus Concept, identifier A0000999, already exists in the database.\"]}")
    end
    
    it "impact analysis"

    it "deletes a concept" do
      params = 
      {
        :id => "THC-A00001_A0000999", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => []
      }
      delete :destroy, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "fails to delete a concept, already deleted" do
      params = 
      {
        :id => "THC-A00001_A0000999", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :children => []
      }
      delete :destroy, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The Thesaurus Concept, identifier A0000999, already exists in the database.\"]}")
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