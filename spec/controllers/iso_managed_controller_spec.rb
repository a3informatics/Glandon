require 'rails_helper'

describe IsoManagedController do

  include DataHelpers
  include PublicFileHelpers
  include DownloadHelpers

  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_managed_data.ttl")
      load_test_file_into_triple_store("iso_managed_data_2.ttl")
      load_test_file_into_triple_store("iso_managed_data_3.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("form_example_dm1_branch.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "index of items" do 
      get :index
    #Xwrite_yaml_file(assigns(:managed_items), sub_dir, "iso_managed_index.yaml")
    	expected = read_yaml_file(sub_dir, "iso_managed_index.yaml")
      expect(assigns(:managed_items)).to match_array(expected)
      expect(response).to render_template("index")
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
      get :status, { id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1", current_id: "test" }}
      expect(assigns(:managed_item).to_json).to eq(managed_item.to_json)
      expect(assigns(:registration_state).to_json).to eq(managed_item.registrationState.to_json)
      expect(assigns(:scoped_identifier).to_json).to eq(managed_item.scopedIdentifier.to_json)
      expect(assigns(:current_id)).to eq("test")
      expect(assigns(:owner)).to eq(true)
      expect(assigns(:close_path)).to eq("/forms/history/?identifier=TEST&scope_id=#{managed_item.scopedIdentifier.namespace.id}")
      expect(response).to render_template("status")
    end

    it "allows a managed item to be edited" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      managed_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      get :edit, {id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(assigns(:managed_item).to_json).to eq(managed_item.to_json)
      expect(assigns(:close_path)).to eq("/forms/history/?identifier=TEST&scope_id=#{managed_item.scopedIdentifier.namespace.id}")
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
        rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
        label: "Vital Signs Baseline"
      }
      get :graph, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(assigns(:result)).to eq(result)
    end  

    it "returns the graph links for a managed item" do
      results = 
      [
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
          label: "Height (BC C25347)"
        },
        # Terminologies not found anymore.
        #{
        #  uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology",
        #  rdf_type: "http://www.assero.co.uk/ISO25964#Thesaurus"
        #},
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25299",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
          label: "Diastolic Blood Pressure (BC C25299)"
        },
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25208",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
          label: "Weight (BC C25208)"
        },
        {
          uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298",
          rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
          label: "Systolic Blood Pressure (BC C25298)"
        }
      ]
      get :graph_links, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(results.to_json.to_s)
    end

    it "returns the branches for an item" do
      parent = Form.find("F-ACME_DM1BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
      child = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
      child.add_branch_parent(parent.id, parent.namespace)
      child = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      child.add_branch_parent(parent.id, parent.namespace)
      get :branches, {id: "F-ACME_DM1BRANCH", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      results = JSON.parse(response.body, symbolize_names: true)
    #Xwrite_yaml_file(results, sub_dir, "iso_managed_branches_json_1.yaml")
      expected = read_yaml_file(sub_dir, "iso_managed_branches_json_1.yaml")
      expect(results).to hash_equal(expected)
    end

    it "returns the branches for an item" do
      results = { data: [] }
      get :branches, {id: "F-ACME_VSBASELINE1", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(results.to_json.to_s)
    end

    it "allows impact to be assessed" do
      item = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
      get :impact, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(assigns(:start_path)).to eq(impact_start_iso_managed_index_path)
      expect(assigns(:item).to_json).to eq(item.to_json)
    end

    it "allows impact to be assessed, start" do
    	item = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
      request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_start, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      hash = JSON.parse(response.body, symbolize_names: true)
      expect(hash.length).to eql(1)
      expect(hash[0]).to eql(item.uri.to_s)
    end

    it "allows impact to be assessed, next" do
      item = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
      request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_next, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      hash = JSON.parse(response.body, symbolize_names: true)
    #Xwrite_yaml_file(hash, sub_dir, "iso_managed_impact_next.yaml")
      results = read_yaml_file(sub_dir, "iso_managed_impact_next.yaml")
      expect(hash).to hash_equal(results)
    end

    it "destroy" do
      @request.env['HTTP_REFERER'] = 'http://test.host/managed_item'
      audit_count = AuditTrail.count
      mi_count = IsoManaged.all.count
      token_count = Token.all.count
      delete :destroy, { :id => "F-ACME_TEST", iso_managed: { :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(IsoManaged.all.count).to eq(mi_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end

  end

  describe "Content Admin User" do
    
    login_content_admin

    def sub_dir
      return "controllers"
    end

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_managed_data.ttl")
      load_test_file_into_triple_store("iso_managed_data_2.ttl")
      load_test_file_into_triple_store("iso_managed_data_3.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("form_example_dm1_branch.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "export" do
      item = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
      uri = UriV3.new( uri: item.uri.to_s )
      allow_any_instance_of(IsoManaged).to receive(:triples).and_return("triples")
      allow_any_instance_of(IsoManaged).to receive(:owner_short_name).and_return("ACME")
      allow(controller).to receive(:to_turtle).with("triples").and_return("content")
      expect(ExportFileHelpers).to receive(:save).with("content", "ACME_BC C25298_1.ttl").and_return("filepath/a")
      get :export, { :id => uri.to_id }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"file_path\":\"filepath/a\"}")
    end

  end

  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "update"
    
    it "status" do
      get :status, { id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1", current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "changes"
    it "edit" do
       get :edit, {id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "edit_tags"
    it "find_by_tag"
    it "add_tag"
    it "delete_tag"
    it "tags"
    
    it "branches" do
      get :branches, {id: "F-ACME_VSBASELINE1", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "show an managed item" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "graph"
    it "graph_links"
    
    it "impact" do
      get :impact, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "impact_start" do
      get :impact_start, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end
    
    it "impact_next" do
      get :impact_next, { id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end
    
    it "destroy" do
      delete :destroy, { :id => "F-ACME_TEST", iso_managed: { :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "export" do
      get :export, {id: "XXXXXXX"} # Used new ID, can be anything
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end