require 'rails_helper'

describe IsoConceptController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_reader

    def sub_dir
      return "controllers"
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
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
      load_test_file_into_triple_store("iso_concept_extension.ttl")
      load_test_file_into_triple_store("iso_concept_data.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      clear_iso_concept_object
    end

    #it "show a concept" do
    #  concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
    #  get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
    #  expect(assigns(:concept).to_json).to eq(concept.to_json)
    #  expect(response).to render_template("show")
    #end

    it "show concept as JSON" do
      concept = IsoConcept.find("F-AE_G1_I2", "http://www.assero.co.uk/X/V1")
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq(concept.to_json.to_json)
    end

    it "displays a graph" do
      result = 
      { 
        uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1_G1_G2",
        rdf_type: "http://www.assero.co.uk/BusinessForm#NormalGroup",
        label: "Height (BC_C25347)"
      }
      get :graph, {id: "F-ACME_VSBASELINE1_G1_G2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(assigns(:result)).to eq(result)
    end

    it "returns the graph links for a concept" do
      get :graph_links, {id: "F-ACME_VSBASELINE1_G1_G2", namespace: "http://www.assero.co.uk/MDRForms/ACME/V1"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      hash = JSON.parse(response.body, symbolize_names: true)
    #write_yaml_file(hash, sub_dir, "iso_concept_controller_example_1.yaml")
      results = read_yaml_file(sub_dir, "iso_concept_controller_example_1.yaml")
      expect(hash).to hash_equal(results)
    end

    it "allows impact to be assessed" do
      item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      get :impact, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
      expect(assigns(:start_path)).to eq(impact_start_iso_concept_index_path)
      expect(assigns(:item).to_json).to eq(item.to_json)
    end

    it "allows impact to be assessed, start" do
    	item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_start, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      hash = JSON.parse(response.body, symbolize_names: true)
      expect(hash.length).to eql(1)
      expect(hash[0]).to eql(item.uri.to_s)
    end

    it "allows impact to be assessed, next" do
      item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
      request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_next, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      hash = JSON.parse(response.body, symbolize_names: true)
    #write_yaml_file(hash, sub_dir, "iso_concept_controller_example_2.yaml")
      results = read_yaml_file(sub_dir, "iso_concept_controller_example_2.yaml")
      expect(hash).to hash_equal(results)
    end

    it "allows impact to be assessed, exception" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_next, {id: "", namespace: ""}
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq("{\"item\":null,\"children\":[]}")
    end

    it "allows cross references to be found" do
      item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
    end
    
  end

  describe "Unauthorized User" do
    
    it "show a concept" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end