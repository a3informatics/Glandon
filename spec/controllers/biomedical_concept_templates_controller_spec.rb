require 'rails_helper'

describe BiomedicalConceptTemplatesController do

  include DataHelpers
  include PauseHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Reader User" do
  	
    login_reader

    def sub_dir
      return "controllers/biomedical_concept_templates"
    end

    before :all do
      load_files(schema_files, ["iso_registration_authority_real.ttl","iso_namespace_real.ttl"])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("biomedical_concept_templates.ttl")
      load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    end

    it "index, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      actual = check_good_json_response(response)
      check_file_actual_expected(actual[:data], sub_dir, "index_expected_1.yaml", equate_method: :hash_equal)
    end

    # it "shows the history, page" do
    #   instance = BiomedicalConceptTemplate.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/HEIGHT/V1#BCI"))
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   expect(BiomedicalConceptInstance).to receive(:history_pagination).with({identifier: instance.has_identifier.identifier, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([instance])
    #   get :history, params:{biomedical_concept_instance: {identifier: instance.has_identifier.identifier, scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE", count: 20, offset: 20}}
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.code).to eq("200")
    #   actual = JSON.parse(response.body).deep_symbolize_keys[:data]
    #   check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    # end

    # it "shows the history, initial view" do
    #   params = {}
    #   expect(BiomedicalConceptInstance).to receive(:latest).and_return(BiomedicalConceptTemplate.new)
    #   get :history, params:{biomedical_concept_instance: {identifier: "HEIGHT", scope_id: "aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE"}}
    #   expect(assigns(:identifier)).to eq("HEIGHT")
    #   expect(assigns(:scope_id)).to eq("aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjU0NVQkVE")
    #   expect(response).to render_template("history")
    # end

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