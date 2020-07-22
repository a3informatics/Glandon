require 'rails_helper'

describe BiomedicalConceptTemplatesController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Curator User" do
  	
    login_curator

    def sub_dir
      return "controllers/biomedical_concept_templates"
    end

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "index" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    it "shows the history, page" do
      bct_1 = BiomedicalConceptTemplate.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/BASIC_OBS/V1#BCT"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(BiomedicalConceptTemplate).to receive(:history_pagination).with({identifier: bct_1.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([bct_1])
      get :history, params:{biomedical_concept_template: {identifier: bct_1.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "history_expected_1a.yaml", equate_method: :hash_equal)
    end

    it "shows the history, initial view" do
      bct = BiomedicalConceptTemplate.new
      bct.uri = Uri.new(uri: "http://www.example.com/bct#bct")
      expect(BiomedicalConceptTemplate).to receive(:latest).with({identifier: "identifier", scope: an_instance_of(IsoNamespace)}).and_return(bct)
      get :history, params:{biomedical_concept_template: {identifier: "identifier", scope_id: IsoRegistrationAuthority.cdisc_scope.id}}
      expect(assigns(:bt).id).to eq(bct.id)
      expect(assigns(:identifier)).to eq("identifier")
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(response).to render_template("history")
    end

    # it "lists all unique templates, HTML" do
    #   get :index
    #   expect(assigns[:bcts].count).to eq(2)
    #   expect(response).to render_template("index")
    # end
    
    # it "lists all unique templates, JSON" do  
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :index
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    # write_text_file_2(response.body, sub_dir, "bct_controller_index.txt")
    #   expected = read_text_file_2(sub_dir, "bct_controller_index.txt")
    #   expect(response.body).to eq(expected)
    # end

    # it "lists all released templates, JSON" do  
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :list
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   result = JSON.parse(response.body)
    # #Xwrite_yaml_file(result, sub_dir, "bct_controller_list.yml")
    #   expected = read_yaml_file(sub_dir, "bct_controller_list.yml")
    #   expect(result).to hash_equal(expected)
    # end

    # it "lists all templates, JSON" do  
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :all
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   result = JSON.parse(response.body)
    # #Xwrite_yaml_file(result, sub_dir, "bct_controller_all.yml")
    #   expected = read_yaml_file(sub_dir, "bct_controller_all.yml")
    #   expect(result).to hash_equal(expected)
    # end

    # it "shows the history" do
    #   ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    #   get :history, { :biomedical_concept_template => { :identifier => "Obs PQR", :scope_id => ra.ra_namespace.id }}
    #   expect(response).to render_template("history")
    # end

    # it "shows the history, redirects when empty" do
    #   ra = IsoRegistrationAuthority.find_by_short_name("CDISC")
    #   get :history, { :biomedical_concept_template => { :identifier => "Obs PQRx", :scope_id => ra.ra_namespace.id }}
    #   expect(response).to redirect_to("/biomedical_concept_templates")
    # end

    # it "show" do
    #   get :show, { :id => "BCT-Obs_PQR", :biomedical_concept_template => { :namespace => "http://www.assero.co.uk/MDRBCTs/V1" }}
    #   expect(response).to render_template("show")
    # end

  end

end