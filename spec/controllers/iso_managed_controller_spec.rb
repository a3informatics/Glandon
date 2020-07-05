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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", 
        "iso_managed_data.ttl", "iso_managed_data_2.ttl",
        "iso_managed_data_3.ttl", "form_example_vs_baseline.ttl", 
        "form_example_general.ttl", "form_example_dm1_branch.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
    end

    it "index of items" #do
    #   get :index
    # #Xwrite_yaml_file(assigns(:managed_items), sub_dir, "iso_managed_index.yaml")
    #   expected = read_yaml_file(sub_dir, "iso_managed_index.yaml")
    #   expect(assigns(:managed_items)).to match_array(expected)
    #   expect(response).to render_template("index")
    # end

    it "updates a managed item" do
      post :update,
        params:{
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

    it "allows a managed item to be edited" do
      @request.env['HTTP_REFERER'] = "http://test.host/xxx"
      managed_item = IsoManaged.find("F-ACME_TEST", "http://www.assero.co.uk/MDRForms/ACME/V1")
      get :edit, params:{id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(assigns(:managed_item).to_json).to eq(managed_item.to_json)
      expect(assigns(:close_path)).to eq("/forms/history/?identifier=TEST&scope_id=#{managed_item.scopedIdentifier.namespace.id}")
      expect(response).to render_template("edit")
    end

    it "allows a managed item tags to be edited"
    it "allows a managed item to be found by tag"
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
      get :show, params:{id: "F-ACME_TEST", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(concept.to_json.to_json)
    end

    it "displays a graph" # do
    #   result =
    #   {
    #     uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1",
    #     rdf_type: "http://www.assero.co.uk/BusinessForm#Form",
    #     label: "Vital Signs Baseline"
    #   }
    #   get :graph, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
    #   expect(assigns(:result)).to eq(result)
    # end

    it "returns the graph links for a managed item" # do
    #   results =
    #   [
    #     {
    #       uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347",
    #       rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
    #       label: "Height (BC C25347)"
    #     },
    #     # Terminologies not found anymore.
    #     #{
    #     #  uri: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42#TH-CDISC_CDISCTerminology",
    #     #  rdf_type: "http://www.assero.co.uk/ISO25964#Thesaurus"
    #     #},
    #     {
    #       uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25299",
    #       rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
    #       label: "Diastolic Blood Pressure (BC C25299)"
    #     },
    #     {
    #       uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25208",
    #       rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
    #       label: "Weight (BC C25208)"
    #     },
    #     {
    #       uri: "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25298",
    #       rdf_type: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
    #       label: "Systolic Blood Pressure (BC C25298)"
    #     }
    #   ]
    #   get :graph_links, {id: "F-ACME_VSBASELINE1", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   expect(response.body).to eq(results.to_json.to_s)
    # end

    it "returns the branches for an item" # do
    #   parent = Form.find("F-ACME_DM1BRANCH", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #   child = Form.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #   child.add_branch_parent(parent.id, parent.namespace)
    #   child = Form.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
    #   child.add_branch_parent(parent.id, parent.namespace)
    #   get :branches, {id: "F-ACME_DM1BRANCH", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   results = JSON.parse(response.body, symbolize_names: true)
    # #Xwrite_yaml_file(results, sub_dir, "iso_managed_branches_json_1.yaml")
    #   expected = read_yaml_file(sub_dir, "iso_managed_branches_json_1.yaml")
    #   expect(results).to hash_equal(expected)
    # end

    it "returns the branches for an item" do
      results = { data: [] }
      get :branches, params:{id: "F-ACME_VSBASELINE1", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(results.to_json.to_s)
    end

    it "destroy" do
      @request.env['HTTP_REFERER'] = 'http://test.host/managed_item'
      audit_count = AuditTrail.count
      mi_count = IsoManaged.all.count
      token_count = Token.all.count
      delete :destroy, params:{ :id => "F-ACME_TEST", iso_managed: { :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(IsoManaged.all.count).to eq(mi_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end

    it "comments" do
      params = {identifier: "XXX", scope_id: "1234" }
      expected_base =
      [
        {uri: Uri.new(uri: "http://test.host/managed_item#1"), a: "x", b: "y"},
        {uri: Uri.new(uri: "http://test.host/managed_item#2"), a: "x1", b: "y1"}
      ]
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(IsoNamespace).to receive(:find).with("1234").and_return(IsoNamespace.new)
      expect(IsoManagedV2).to receive(:comments).with({identifier: params[:identifier], scope: an_instance_of(IsoNamespace)}).and_return(expected_base)
      get :comments, params:{ iso_managed: params}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expected = expected_base
      expected[0][:uri] = expected[0][:uri].to_s
      expected[0][:edit_path] = "/iso_managed/1/edit?iso_managed%5Bnamespace%5D=http%3A%2F%2Ftest.host%2Fmanaged_item"
      expected[1][:uri] = expected[1][:uri].to_s
      expected[1][:edit_path] = "/iso_managed/2/edit?iso_managed%5Bnamespace%5D=http%3A%2F%2Ftest.host%2Fmanaged_item"
      result = JSON.parse(response.body).deep_symbolize_keys[:data]
      result[0][:uri] = result[0][:uri].to_s
      result[1][:uri] = result[1][:uri].to_s
      expect(result).to hash_equal(expected)
    end

  end

  describe "Content Admin User" do

    login_content_admin

    def sub_dir
      return "controllers"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", 
        "iso_managed_data.ttl", "iso_managed_data_2.ttl",
        "iso_managed_data_3.ttl", "form_example_vs_baseline.ttl", 
        "form_example_general.ttl", "form_example_dm1_branch.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
    end

    it "export" #do
    #   item = IsoManaged.find("BC-ACME_BC_C25298", "http://www.assero.co.uk/MDRBCs/V1", false)
    #   uri = UriV3.new( uri: item.uri.to_s )
    #   allow_any_instance_of(IsoManaged).to receive(:triples).and_return("triples")
    #   allow_any_instance_of(IsoManaged).to receive(:owner_short_name).and_return("ACME")
    #   allow(controller).to receive(:to_turtle).with("triples").and_return("content")
    #   expect(ExportFileHelpers).to receive(:save).with("content", "ACME_BC C25298_1.ttl").and_return("filepath/a")
    #   get :export, params:{ :id => uri.to_id }
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   expect(response.body).to eq("{\"file_path\":\"filepath/a\"}")
    # end

  end

  describe "Unauthorized User" do

    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "update"

    it "status" do
      get :status, params:{ id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1", current_id: "test" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "changes"
    it "edit" do
       get :edit, params:{id: "F-ACME_TEST", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "edit_tags"
    it "find_by_tag"
    it "add_tag"
    it "delete_tag"
    it "tags"

    it "branches" do
      get :branches, params:{id: "F-ACME_VSBASELINE1", iso_managed: { namespace: "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "show an managed item" do
      get :show, params:{id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "graph"
    it "graph_links"

    it "impact" do
      get :impact, params:{ id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "impact_start" do
      get :impact_start, params:{ id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "impact_next" do
      get :impact_next, params:{ id: "BC-ACME_BC_C25298", namespace: "http://www.assero.co.uk/MDRBCs/V1" }
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy" do
      delete :destroy, params:{ :id => "F-ACME_TEST", iso_managed: { :namespace => "http://www.assero.co.uk/MDRForms/ACME/V1" }}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "export" do
      get :export, params:{id: "XXXXXXX"} # Used new ID, can be anything
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
