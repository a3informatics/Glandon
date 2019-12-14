require 'rails_helper'

describe IsoConceptController do

  include DataHelpers
  include ControllerHelpers
  
  describe "Authrorized User" do
  	
    login_reader

    def sub_dir
      return "controllers/iso_concept"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_extension.ttl", 
        "iso_concept_data.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
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
      hash = check_good_json_response(response)
    #write_yaml_file(hash, sub_dir, "iso_concept_controller_example_1.yaml")
      results = read_yaml_file(sub_dir, "graph_links_example_1.yaml")
      expect(hash).to hash_equal(results)
    end

    it "allows impact to be assessed" # do
    #   item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
    #   get :impact, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
    #   expect(assigns(:start_path)).to eq(impact_start_iso_concept_index_path)
    #   expect(assigns(:item).to_json).to eq(item.to_json)
    # end

    it "allows impact to be assessed, start" # do
    # 	item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :impact_start, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
    #   expect(response.code).to eq("200")
    #   expect(response.content_type).to eq("application/json")
    #   hash = JSON.parse(response.body, symbolize_names: true)
    #   expect(hash.length).to eql(1)
    #   expect(hash[0]).to eql(item.uri.to_s)
    # end

    it "allows impact to be assessed, next" # do
    #   item = IsoConcept.find("CLI-C71148_C62166", "http://www.assero.co.uk/MDRThesaurus/CDISC/V42", false)
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :impact_next, {id: "CLI-C71148_C62166", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"}
    #   expect(response.code).to eq("200")
    #   expect(response.content_type).to eq("application/json")
    #   hash = JSON.parse(response.body, symbolize_names: true)
    # #write_yaml_file(hash, sub_dir, "iso_concept_controller_example_2.yaml")
    #   results = read_yaml_file(sub_dir, "graph_links_example_2.yaml")
    #   expect(hash).to hash_equal(results)
    # end

    it "allows impact to be assessed, exception" # do
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   get :impact_next, {id: "", namespace: ""}
    #   expect(response.code).to eq("200")
    #   expect(response.content_type).to eq("application/json")
    #   expect(response.body).to eq("{\"item\":null,\"children\":[]}")
    # end

    it "allows cross references to be found"

    it "gets tags" do
      item = IsoConceptV2.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      get :tags, id: item.id
      actual = check_good_json_response(response)
      expect(actual).to eq(["SDTM"])
    end

    it "add change note" do
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3300")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item = IsoConceptV2.find(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add_change_note, {id: item.id, iso_concept: {description: "sssss", reference: "ref"}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_change_note_expected_1.yaml")
    end

    it "get change notes" do
      item = IsoConceptV2.find(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3301")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00+01:00 2000"))
      item.add_change_note(description: "desc1", reference: "ref1", user_reference: "a@b.com")
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3302")
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 13:00:00+01:00 2000"))
      item.add_change_note(description: "desc2", reference: "ref2", user_reference: "a@b.com")
      request.env['HTTP_ACCEPT'] = "application/json"
      get :change_notes, id: item.id
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "change_notes_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Unauthorized User" do
    
    it "show a concept" do
      get :show, {id: "F-AE_G1_I2", namespace: "http://www.assero.co.uk/X/V1"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end