require 'rails_helper'

describe IsoManagedController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_curator

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
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_managed_data.ttl")
      load_test_file_into_triple_store("iso_managed_data_2.ttl")
      load_test_file_into_triple_store("iso_managed_data_3.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "updates a managed item" do 
      post :update, 
        { 
          id: "F-ACME_TEST", 
          iso_managed: 
          { 
            referer: 'http://test.host/iso_managed', 
            namespace:"http://www.assero.co.uk/MDRForms/ACME/V1", 
            :explanatoryComment => "New comment",  
            :changeDescription => "Description", 
            :origin => "Origin" 
          }
        }
      managed_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      expect(managed_item.explanatoryComment).to eq("New comment")
      expect(managed_item.changeDescription).to eq("Description")
      expect(managed_item.origin).to eq("Origin")
      expect(response).to redirect_to('http://test.host/iso_managed')
    end

    it "return the status of a managed item" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      managed_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      get :status, { id: "F-ACME_TEST", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1", current_id: "test" }
      expect(assigns(:managed_item).to_json).to eq(managed_item.to_json)
      expect(assigns(:registration_state).to_json).to eq(managed_item.registrationState.to_json)
      expect(assigns(:scoped_identifier).to_json).to eq(managed_item.scopedIdentifier.to_json)
      expect(assigns(:current_id)).to eq("test")
      expect(assigns(:owner)).to eq(true)
      expect(assigns(:referer)).to eq("http://test.host/xxx")
      expect(response).to render_template("status")
    end

    it "allows a managed item to be edited" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      managed_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      get :edit, {id: "F-ACME_TEST", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(assigns(:managed_item).to_json).to eq(managed_item.to_json)
      expect(assigns(:referer)).to eq("http://test.host/xxx")
      expect(response).to render_template("edit")
    end

    it "allows a managed item tags to be edited"
    it "allows a managed item to be found by tag"
    it "allows a tag to be added to a managed item"
    it "allows a tag to be added to a managed item, error"
    it "allows a tag to be deleted from a managed item"
    it "allows a tag to be deleted from a managed item, error"
    it "returns the tags for a managed item"
    
    #it "shows a managed item" do
    #  concept = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #  get :show, {id: "F-ACME_TEST", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
    #  expect(assigns(:concept).to_json).to eq(concept.to_json)
    #  expect(response).to render_template("show")
    #end

    it "shows a managed item, JSON" do
      concept = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, {id: "F-ACME_TEST", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq(concept.to_json.to_json)
    end

    it "displays a graph" do
      result = 
      { 
        uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1",
        rdf_type: "http://www.assero.co.uk/BusinessForm#Form"
      }
      get :graph, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(assigns(:result)).to eq(result)
    end  

    it "returns the graph links for a managed item" do
      results = 
      [
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"
        },
        # Terminologies not found anymore.
        #{
        #  uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology",
        #  rdf_type: "http://www.assero.co.uk/ISO25964#Thesaurus"
        #},
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25299",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"
        },
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25208",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"
        },
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"
        }
      ]
      get :graph_links, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(results.to_json.to_s)
    end

    it "determines the change impact for managed item" do
      bc = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
      results = { item: bc.to_json, children: [{:uri=>"http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1", :rdf_type=>"http://www.assero.co.uk/BusinessForm#Form"}] }
      get :impact, {id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1"}
      expect(assigns(:results)).to eq(results)
    end
  end

  describe "Unauthorized User" do
    
    it "show an managed item" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end