require 'rails_helper'

describe Thesauri::ManagedConceptsController do

  include DataHelpers
  
  def sub_dir
    return "controllers/thesauri/managed_concept"
  end

  describe "Authorized User" do
  	
    login_curator

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
      ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
      load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
#      Token.delete_all
#      @lock_user = User.create :email => "lock@example.com", :password => "changeme" 
    end

    after :each do
    end

    it "changes" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_count).and_return(5)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :changes, id: "aaa"
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/managed_concepts/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/changes"})
      expect(response).to render_template("changes")
    end

    it "is_extended" do
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(true)
      get :is_extended, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys
      expect(actual).to eq({data: true})
    end

    it "is_extension" do
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extension?).and_return(false)
      get :is_extension, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys
      expect(actual).to eq({data: false})
    end
    
    it "show, no extension" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#CT")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66767/V2#C66767")
      get :show, {id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:can_be_extended)).to eq(false)
      expect(assigns(:is_extended)).to eq(false)
      expect(assigns(:is_extended_path)).to eq("")
      expect(assigns(:is_extending)).to eq(false)
      expect(assigns(:is_extending_path)).to eq("")
      expect(response).to render_template("show")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      get :show, {id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:can_be_extended)).to eq(true)
    end

    it "show, extended" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#CT")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      ext_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#XXXXX")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(true)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended_by).and_return(ext_uri)
      get :show, {id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:can_be_extended)).to eq(false)
      expect(assigns(:is_extended)).to eq(true)
      expect(assigns(:is_extended_path)).to eq("/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjIjQ1Q%3D")
      expect(assigns(:is_extending)).to eq(false)
      expect(assigns(:is_extending_path)).to eq("")
      expect(response).to render_template("show")
    end

    it "show, extending" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#CT")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      ext_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#XXXXX")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(false) # Note, wrong way but useful for test
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extension_of).and_return(ext_uri)
      get :show, {id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:can_be_extended)).to eq(true)
      expect(assigns(:is_extended)).to eq(false)
      expect(assigns(:is_extended_path)).to eq("")
      expect(assigns(:is_extending)).to eq(true)
      expect(assigns(:is_extending_path)).to eq("/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjIjQ1Q%3D")
      expect(response).to render_template("show")
    end

    # it "edit" do
    #   uri_th = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
    #   uri_tc = Uri.new(uri: "http://www.cdisc.org/C49489/V1#C49489")
    #   get :edit, {id: uri_tc.to_id, thesaurus_concept: {parent_id: uri_th.to_id}}
    #   expect(assigns(:close_path)).to eq("")
    #   expect(assigns(:referrer_path)).to eq("")
    #   expect(assigns(:tc_identifier_prefix)).to eq("XXX")
    #   expect(response).to render_template("edit")
    # end

  end
  
end