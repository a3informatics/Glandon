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
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:preferred_term_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_count).and_return(5)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :changes, id: "aaa"
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/managed_concepts/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/changes"})
      expect(response).to render_template("changes")
    end

    it "changes data" do
      expected = {items: {:"1"=>{:changes_path=>"/thesauri/unmanaged_concepts/1/changes", :id=>"1"}, :"2"=>{:changes_path=>"/thesauri/unmanaged_concepts/2/changes", :id=>"2"}}}
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      get :changes_data, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "changes summary" do
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:preferred_term_objects).and_return([])
      get :changes_summary, {id: "aaa", last_id: "bbb", ver_span: "x"}
      expect(assigns(:links)).to eq({})
      expect(assigns(:version_span)).to eq("x")
      expect(assigns(:version_count)).to eq(2)
      expect(assigns(:close_path)).to eq(dashboard_index_path)
      expect(response).to render_template("changes_summary")
    end

    it "changes summary data" do
      expected = {items: {:"1"=>{:changes_path=>"/thesauri/unmanaged_concepts/1/changes", :id=>"1"}, :"2"=>{:changes_path=>"/thesauri/unmanaged_concepts/2/changes", :id=>"2"}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_summary).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      get :changes_summary_data, {id: "aaa", last_id: "bbb", ver_span: "x"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "differences summary" do
      expected = {items: {:"1" => {id: "1"}, :"2" => {id: "2"}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:differences_summary).and_return(expected)
      get :differences_summary, {id: "aaa", last_id: "bbb", ver_span: "x"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
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

    it "show data" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expected = [
        {id: "1", delete: false, delete_path: "", show_path: "/thesauri/unmanaged_concepts/1?unmanaged_concept%5Bcontext_id%5D=bbb"},
        {id: "2", delete: true, delete_path: "/thesauri/unmanaged_concepts/2?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVlgjWFhY", show_path: "/thesauri/unmanaged_concepts/2?unmanaged_concept%5Bcontext_id%5D=bbb"}
      ]
      tc = Thesaurus::ManagedConcept.new
      tc.uri = Uri.new(uri: "http://www.cdisc.org/CT/VX#XXX")
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(tc)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:children_pagination).and_return([{id: "1", delete: false}, {id: "2", delete: true}])
      get :show_data, {id: "aaa", offset: 10, count: 10, managed_concept: {context_id: "bbb"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "export csv" do
      expect(Thesaurus::ManagedConcept).to receive(:find_full).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:scoped_identifier).and_return("C12345")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:to_csv).and_return(["XXX", "YYY"])
      expect(@controller).to receive(:send_data).with(["XXX", "YYY"], {filename: "CDISC_CL_C12345.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'})
      expect(@controller).to receive(:render)
      get :export_csv, id: "aaa"
    end

    it "pdf report" do
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:scoped_identifier).and_return("C12345")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      expect(Reports::CdiscChangesReport).to receive(:new).and_return(Reports::CdiscChangesReport.new)
      expect_any_instance_of(Reports::CdiscChangesReport).to receive(:create).and_return("abcd")
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :changes_report, id: "aaa"
      expect(response.content_type).to eq("application/pdf")
      expect(response.header["Content-Disposition"]).to eq("inline; filename=\"CDISC_CL_C12345.pdf\"")
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

  describe "subsets" do

    login_curator

    before :all do
      schema_files =["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl",
        "ISO11179Concepts.ttl", "thesaurus.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "CT_SUBSETS.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
    end

    it "find subsets" do
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66726/V19#C66726")
      get :find_subsets, {id: tc_uri.to_id}
      actual = JSON.parse(response.body)
      check_file_actual_expected(actual, sub_dir, "subsets_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find subsets, no subsets found" do
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C81226/V19#C81226")
      get :find_subsets, {id: tc_uri.to_id}
      actual = JSON.parse(response.body)
      expect(actual["data"]).to eq([])
    end

  end
end
