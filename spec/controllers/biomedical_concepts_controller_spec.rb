require 'rails_helper'

describe BiomedicalConceptsController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers/biomedical_concepts"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "biomedical_concept_instances.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    after :all do
    end
    
    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "show" do
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/HEIGHT/V1#BCI"))
      get :show, params: { :id => bci.id}
      expect(response).to render_template("show")
    end

    it "show results" do
      bci = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/HEIGHT/V1#BCI"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(BiomedicalConceptInstance).to receive(:find_minimum).and_return(bci)
      get :show_data, params:{id: bci.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_results_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/HEIGHT/V1#BCI"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(BiomedicalConceptInstance).to receive(:history_pagination).with({identifier: instance.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([instance])
      get :history, params:{biomedical_concept: {identifier: instance.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      params = {}
      expect(BiomedicalConceptInstance).to receive(:latest).and_return(BiomedicalConceptInstance.new)
      get :history, params:{biomedical_concept: {identifier: "HEIGHT", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
      expect(assigns(:identifier)).to eq("HEIGHT")
      expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
      expect(response).to render_template("history")
    end

    # it "shows the history" do
    #   ra = IsoRegistrationAuthority.find_by_short_name("ACME")
    #   get :history, params: { :biomedical_concept => { :identifier => "BC C49677", :scope_id => ra.ra_namespace.id }}
    #   expect(response).to render_template("history")
    # end

    # it "lists all unique templates, HTML" do
    #   get :index
    #   expect(assigns[:bcs].count).to eq(13)
    #   expect(response).to render_template("index")
    # end

  #   it "lists all released items" do
  #     request.env['HTTP_ACCEPT'] = "application/json"
  #     get :list
  #     expect(response.content_type).to eq("application/json")
  #     expect(response.code).to eq("200")
  #     results = JSON.parse(response.body, symbolize_names: true)
  #   #Xwrite_yaml_file(results, sub_dir, "bc_controller_list.yaml")
  #     expected = read_yaml_file(sub_dir, "bc_controller_list.yaml")
  #     expect(results).to hash_equal(expected)
  #   end

  #   it "shows the history, redirects when empty" do
  #     ra = IsoRegistrationAuthority.find_by_short_name("ACME")
  #     get :history, { :biomedical_concept => { :identifier => "BC C49678x", :scope_id => ra.ra_namespace.id }}
  #     expect(response).to redirect_to("/biomedical_concepts")
  #   end

  #   it "creates the new BC" do
  #     item = BiomedicalConceptTemplate.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
  #     audit_count = AuditTrail.count
  #     bc_count = BiomedicalConcept.all.count
  #     post :create, { :biomedical_concept => { :uri => item.uri.to_s, :identifier => "NEW BC", :label => "New BC" }}
  #     bc = assigns(:bc)
  #     expect(bc.errors.count).to eq(0)
  #     expect(BiomedicalConcept.all.count).to eq(bc_count + 1) 
  #     expect(flash[:success]).to be_present
  #     expect(AuditTrail.count).to eq(audit_count + 1)
  #     expect(response).to redirect_to("/biomedical_concepts")
  #   end

  #   it "creates the new BC, error" do
  #     item = BiomedicalConceptTemplate.find("BCT-Obs_PQR", "http://www.assero.co.uk/MDRBCTs/V1")
  #     audit_count = AuditTrail.count
  #     bc_count = BiomedicalConcept.all.count
  #     post :create, { :biomedical_concept => { :uri => "", :identifier => "NEW BC", :label => "New BC" }}
  #     expect(response).to redirect_to("/biomedical_concepts/new")
  #   end

  #   it "edit, no next version" do
  #     get :edit, { :id => "BC-ACME_NEWBC", :biomedical_concept => {:namespace => "http://www.assero.co.uk/MDRBCs/ACME/V1" }}
  #     result = assigns(:bc)
  #     token = assigns(:token)
  #     expect(token.user_id).to eq(@user.id)
  #     expect(token.item_uri).to eq("http://www.assero.co.uk/MDRBCs/ACME/V1#BC-ACME_NEWBC") # Note no new version, no copy.
  #     expect(result.identifier).to eq("NEW BC")
  #     expect(response).to render_template("edit")
  #   end

  #   it "edit BC, next version" do
  #     get :edit, { :id => "BC-ACME_BC_C25347", :biomedical_concept => {:namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     result = assigns(:bc)
  #     token = assigns(:token)
  #     expect(token.user_id).to eq(@user.id)
  #     expect(token.item_uri).to eq("http://www.assero.co.uk/MDRBCs/ACME/V2#BC-ACME_BCC25347") # Note no new version, no copy.
  #     expect(result.identifier).to eq("BC C25347")
  #     expect(response).to render_template("edit")
  #   end
    
  #   it "edits BC, already locked" do
  #     @request.env['HTTP_REFERER'] = 'http://test.host/biomedical_concepts'
  #     bc = BiomedicalConcept.find("BC-ACME_NEWBC", "http://www.assero.co.uk/MDRBCs/ACME/V1") 
  #     token = Token.obtain(bc, @lock_user)
  #     get :edit, { :id => "BC-ACME_NEWBC", :biomedical_concept => {:namespace => "http://www.assero.co.uk/MDRBCs/ACME/V1" }}
  #     expect(flash[:error]).to be_present
  #     expect(response).to redirect_to("/biomedical_concepts")
  #   end

  #   it "initiates the cloning of a BC" do
  #     get :clone, { :id => "BC-ACME_BC_C25347", :biomedical_concept => {:namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     bc = assigns(:bc)
  #     expect(bc.id).to eq("BC-ACME_BC_C25347")
  #     expect(response).to render_template("clone")
  #   end

  #   it "clones a BC" do
  #     audit_count = AuditTrail.count
  #     bc_count = BiomedicalConcept.unique.count
  #     params = 
  #     { 
  #       biomedical_concept: 
  #       { 
  #         :identifier => "CLONE", 
  #         :label => "New Clone" , 
  #         :bc_id => "BC-ACME_BC_C25347", 
  #         :bc_namespace => "http://www.assero.co.uk/MDRBCs/V1" 
  #       }
  #     }
  #     post :clone_create, params
  #     bc = assigns(:bc)
  #     expect(bc.errors.count).to eq(0)
  #     expect(BiomedicalConcept.unique.count).to eq(bc_count + 1) 
  #     expect(flash[:success]).to be_present
  #     expect(AuditTrail.count).to eq(audit_count + 1)
  #     expect(response).to redirect_to("/biomedical_concepts")
  #   end

  #   it "clones a BC, error duplicate" do
  #     audit_count = AuditTrail.count
  #     bc_count = BiomedicalConcept.all.count
  #     params = 
  #     { 
  #       biomedical_concept: 
  #       { 
  #         :identifier => "CLONE", 
  #         :label => "New Clone" , 
  #         :bc_id => "BC-ACME_BC_C25347", 
  #         :bc_namespace => "http://www.assero.co.uk/MDRBCs/V1" 
  #       }
  #     }
  #     post :clone_create, params
  #     bc = assigns(:bc)
  #     expect(bc.errors.count).to eq(1)
  #     expect(flash[:error]).to be_present
  #     expect(response).to redirect_to("/biomedical_concepts/BC-ACME_BC_C25347/clone?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRBCs%2FV1")
  #   end

  #   it "edit lock"

  #   it "edit multiple"

  #   it "destroy" do
  #     @request.env['HTTP_REFERER'] = 'http://test.host/biomedical_concepts'
  #     audit_count = AuditTrail.count
  #     bc_count = BiomedicalConcept.all.count
  #     token_count = Token.all.count
  #     delete :destroy, { :id => "BC-ACME_CLONE", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/ACME/V1" }}
  #     expect(BiomedicalConcept.all.count).to eq(bc_count - 1)
  #     expect(AuditTrail.count).to eq(audit_count + 1)
  #     expect(Token.count).to eq(token_count)
  #   end
    
  #   it "upgrade" do
  #     bc = BiomedicalConcept.find("BC-ACME_BC_C49678", "http://www.assero.co.uk/MDRBCs/V1") 
  #     get :upgrade, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(flash[:error]).to be_present
  #     expect(response).to redirect_to("/biomedical_concepts/history?biomedical_concept%5Bidentifier%5D=BC+C49678&biomedical_concept%5Bscope_id%5D=#{IsoHelpers.escape_id(bc.scope.id)}")
  #   end

    #       request.env['HTTP_ACCEPT'] = "application/json"
    #   get :index
    #   actual = check_good_json_response(response)
    #   check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    # instance = BiomedicalConceptInstance.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/HEIGHT/V1#BCI"))


    # it "show" do
    #   th = Thesaurus.create({ :identifier => "NEW TH 2", :label => "New Thesaurus 3" })
    #   expect(Thesaurus).to receive(:find_minimum).and_return(th)
    #   get :show, params:{id: "aaa"}
    #   expect(response).to render_template("show")
    # end

    # it "show results" do
    #   th = Thesaurus.new
    #   th.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   expect(Thesaurus).to receive(:find_minimum).and_return(th)
    #   expect_any_instance_of(Thesaurus).to receive(:managed_children_pagination).with({:count=>"10", :offset=>"0", :tags=>["SDTM"]}).and_return([{id: Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1").to_id}])
    #   expect_any_instance_of(Thesaurus).to receive(:is_owned_by_cdisc?).and_return(true)
    #   get :show, params:{id: "aaa", offset: 0, count: 10}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   x = JSON.parse(response.body).deep_symbolize_keys
    #   expect(x).to hash_equal({data: [{show_path: "/thesauri/managed_concepts/aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTURSVGhlc2F1cnVzL0FDTUUvVjE=?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th.id)}",
    #     :id=>"aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTURSVGhlc2F1cnVzL0FDTUUvVjE="}], count: 1, offset: 0})
    # end

  #   it "export_ttl" do
  #     get :export_ttl, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #   end

  #   it "export_json" do
  #     get :export_json, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #   end

  # end

  # describe "Reader User" do
    
  #   login_reader

  #   def sub_dir
  #     return "controllers"
  #   end

  #   it "creates the new BC" do
  #     post :create, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end

  #   it "edits an BC" do
  #     get :edit, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end
    
  #   it "initiates the cloning of a BC" do
  #     get :clone, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end

  #   it "clones a BC" do
  #     post :clone_create, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end

  #   it "create" do 
  #     post :create, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end
    
  #   it "destroy" do
  #     delete :destroy, { :id => "BC-ACME_BC_C49678", :biomedical_concept => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
  #     expect(response).to redirect_to("/")
  #   end
    
  end

end