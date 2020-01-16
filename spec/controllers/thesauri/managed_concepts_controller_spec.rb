require 'rails_helper'

describe Thesauri::ManagedConceptsController do

  include DataHelpers
  include UserAccountHelpers
  include IsoManagedHelpers

  def sub_dir
    return "controllers/thesauri/managed_concept"
  end

  describe "Authorized User - Read" do

    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
      load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
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
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
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
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      ext_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#XXXXX")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(true)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended_by).and_return(ext_uri)
      get :show, {id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:can_be_extended)).to eq(false)
      expect(assigns(:is_extended)).to eq(true)
      expect(assigns(:is_extended_path)).to eq("/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th_uri.to_id)}")
      expect(assigns(:is_extending)).to eq(false)
      expect(assigns(:is_extending_path)).to eq("")
      expect(response).to render_template("show")
    end

    it "show, extending" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
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
      expect(assigns(:is_extending_path)).to eq("/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th_uri.to_id)}")
      expect(response).to render_template("show")
    end

    it "show data" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expected = [
        {id: "1", delete: false, delete_path: "", single_parent: false, show_path: "/thesauri/unmanaged_concepts/1?unmanaged_concept%5Bcontext_id%5D=bbb&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVlgjWFhY"},
        {id: "2", delete: true, delete_path: "/thesauri/unmanaged_concepts/2?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVlgjWFhY", single_parent: true, show_path: "/thesauri/unmanaged_concepts/2?unmanaged_concept%5Bcontext_id%5D=bbb&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVlgjWFhY"}
      ]
      tc = Thesaurus::ManagedConcept.new
      ct = Thesaurus.new
      tc.uri = Uri.new(uri: "http://www.cdisc.org/CT/VX#XXX")
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(tc)
      expect(Thesaurus).to receive(:find_minimum).and_return(ct)
      expect(ct).to receive(:is_owned_by_cdisc?).and_return(true)
      expect(ct).to receive(:tag_labels).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:children_pagination).and_return([{id: "1", delete: false, single_parent: false}, {id: "2", delete: true, single_parent: true}])
      get :show_data, {id: "aaa", offset: 10, count: 10, managed_concept: {context_id: "bbb"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C28421/V1#C28421")
      get :children, id: tc_uri.to_id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      results = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(results, sub_dir, "children_expected_1.yaml")
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

    it "set with indicators" do
      expect(Thesaurus::ManagedConcept).to receive(:set_with_indicators_paginated).with({"count"=>"10", "offset"=>"10", "type"=>"subsets"}).and_return([{x: 1}, {x: 2}])
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :set_with_indicators, {managed_concept: {offset: "10", count: "10", type: "subsets"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      results = JSON.parse(response.body).deep_symbolize_keys[:data]
      expect(JSON.parse(response.body).deep_symbolize_keys[:count]).to eq(2)
      expect(JSON.parse(response.body).deep_symbolize_keys[:offset]).to eq(10)
      check_file_actual_expected(results, sub_dir, "set_with_indicators_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Authorized User - History" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..61)
    end

    after :all do
      #
    end

    it "shows the history, initial view" do
      params = {}
      get :history, {managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id}}
      expect(assigns(:thesauri_id)).to eq("aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2Nzg2L1Y2MCNDNjY3ODY=")
      expect(assigns(:identifier)).to eq("C66786")
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(response).to render_template("history")
    end

    it "shows the history, page, bug GLAN-1107" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :history, {managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1a.yaml", equate_method: :hash_equal)
      expect(JSON.parse(response.body).deep_symbolize_keys[:offset]).to eq(0)
      expect(count = JSON.parse(response.body).deep_symbolize_keys[:count]).to eq(20)
      get :history, {managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1b.yaml", equate_method: :hash_equal)
      expect(JSON.parse(response.body).deep_symbolize_keys[:offset]).to eq(20)
      expect(count = JSON.parse(response.body).deep_symbolize_keys[:count]).to eq(0)
    end

  end

  describe "Authorized User - Edit" do

    login_curator

    before :all do
     
      NameValue.destroy_all
      NameValue.create(name: "thesaurus_parent_identifier", value: "123")
      NameValue.create(name: "thesaurus_child_identifier", value: "456")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :each do
      ua_remove_user("lock@example.com")
    end

    it "create" do
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("XXX1")
      post :create
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/XXX1/V1#XXX1"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      # @todo really should check actual but issue with dates
      check_dates(mc, sub_dir, "create_expected_1.yaml", :creation_date, :last_change_date)
      check_file_actual_expected(mc.to_h, sub_dir, "create_expected_1.yaml", equate_method: :hash_equal)
    end

    it "create, error" do
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).and_return(false)
      post :create
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(nil)
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "create_expected_2.yaml", equate_method: :hash_equal)
    end

    it "update" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(ct, @user)
      put :update, {id: mc.id, edit: {notation: "AAAAA", parent_id: ct.id }}
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update properties" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(mc, @user)
      put :update_properties, {id: mc.id, edit: {synonym: "syn1; syn2"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:data][0]
      expect(actual[:synonym]).to eq("syn1; syn2")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "update properties, error" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(mc, @user)
      put :update_properties, {id: mc.id, edit: {definition: "\#€=/*-/"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("Definition contains invalid characters")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it 'adds a child thesaurus concept' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      new_um = Thesaurus::ManagedConcept.new
      new_um.identifier = "A12345"
      new_um.definition = "A def"
      new_um.notation = "XXX"
      new_um.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1/A12345#fake")
      new_um.set_persisted # Needed for id method to work for paths
      token = Token.obtain(mc, @user)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus::ManagedConcept), @user).and_return(token)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:add_child).with({"identifier"=>"A12345"}).and_return(new_um)
      expect(AuditTrail).to receive(:update_item_event).with(@user, instance_of(Thesaurus::ManagedConcept), "Code list updated.")
      post :add_child, {id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'adds childrens synonyms to managed concept' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      uc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      post :add_children_synonyms, {id: mc.id, managed_concept: {reference_id: uc.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_children_synonyms_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'adds a child thesaurus concept, no audit' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      new_um = Thesaurus::ManagedConcept.new
      new_um.identifier = "A12345"
      new_um.definition = "A def"
      new_um.notation = "XXX"
      new_um.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1/A12345#fake")
      new_um.set_persisted # Needed for id method to work for paths
      token = Token.obtain(mc, @user)
      token.refresh
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus::ManagedConcept), @user).and_return(token)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:add_child).with({"identifier"=>"A12345"}).and_return(new_um)
      post :add_child, {id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'adds a child thesaurus concept, error' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      new_um = Thesaurus::ManagedConcept.new
      new_um.identifier = "A12345"
      new_um.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1/A12345#fake")
      new_um.set_persisted # Needed for id method to work for paths
      new_um.errors.add(:base, "Something went wrong")
      token = Token.obtain(mc, @user)
      token.refresh
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus::ManagedConcept), @user).and_return(token)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:add_child).with({"identifier"=>"A12345"}).and_return(new_um)
      post :add_child, {id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'adds a child thesaurus concept, error' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/AIRPORTS/V1#TH"))
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus::ManagedConcept), @user).and_return(nil)
      post :add_child, {id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end

    it "edit" do
      uri_th = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_tc = Uri.new(uri: "http://www.cdisc.org/C49489/V1#C49489")
      get :edit, {id: uri_tc.to_id, thesaurus_concept: {parent_id: uri_th.to_id}}
      expect(assigns(:close_path)).to eq("/thesauri/managed_concepts/history?managed_concept%5Bidentifier%5D=C49489&managed_concept%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ%3D%3D")
      expect(assigns(:tc_identifier_prefix)).to eq("C49489.")
      expect(assigns(:token)).to_not eq(nil)
      expect(response).to render_template("edit")
    end

    it "edit, locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/referrer'
      uri_th = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_tc = Uri.new(uri: "http://www.cdisc.org/C49489/V1#C49489")
      tc = Thesaurus::ManagedConcept.find_minimum(uri_tc)
      token = Token.obtain(tc, @lock_user)
      get :edit, {id: uri_tc.to_id, thesaurus_concept: {parent_id: uri_th.to_id}}
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

  end

  describe "subsets" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_subsets_1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
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

    it "edit subset" do
      ct = Uri.new(uri: "http://www.cdisc.org/CT/V19#TH")
      sub_mc = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: "http://www.s-cubed.dk/S000001/V19#S000001"))
      sub_mc.update(is_ordered: Thesaurus::Subset.create(uri: Thesaurus::Subset.create_uri(sub_mc.uri)))
      get :edit_subset, id: sub_mc.id
      expect(assigns(:subset_mc).id).to eq(sub_mc.id)
      expect(assigns(:source_mc).id).to eq(sub_mc.subsets_links.to_id)
      expect(assigns(:subset).uri.to_id).to eq(sub_mc.is_ordered.uri.to_id)
      expect(assigns(:close_path)).to eq(history_thesauri_managed_concepts_path({managed_concept: {identifier: sub_mc.scoped_identifier, scope_id: sub_mc.scope}}))
      expect(assigns(:token)).to_not eq(nil)
      expect(response).to render_template("edit_subset")
    end

    it "edit subset, locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/referrer'
      tc = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: "http://www.s-cubed.dk/S000001/V19#S000001"))
      token = Token.obtain(tc, @lock_user)
      get :edit_subset, id: tc.id
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

  end

  describe "extensions" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_extension.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..28)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "create extension" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      post :create_extension, {id: tc.id, managed_concept: {context_id: tc.id }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      x = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(JSON.parse(response.body).deep_symbolize_keys, sub_dir, "create_extension_expected_1.yaml", equate_method: :hash_equal)
    end

    it "edit extension" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      get :edit_extension, {id: tc.id}
      expect(assigns(:is_extending)).to eq(true)
      expect(assigns(:is_extending_path)).to eq("/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk5MDc5L1YyOCNDOTkwNzk=?managed_concept%5Bcontext_id%5D=")
      expect(assigns(:close_path)).to eq("/thesauri/managed_concepts/history?managed_concept%5Bidentifier%5D=A00001&managed_concept%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ%3D%3D")
      expect(assigns(:token)).to_not eq(nil)
      expect(response).to render_template("edit_extension")
    end

    it "edit extension, locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/referrer'
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      token = Token.obtain(tc, @lock_user)
      get :edit_extension, {id: tc.id}
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

    it "add child to extension" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      child_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      token = Token.obtain(tc, @user)
      post :add_extensions, {id: tc.id, managed_concept: {extension_ids: [child_1.id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
    end

  end

  describe "Unauthorized User" do

    login_reader

    it "prevents access to a reader, edit" do
      get :edit, id: 10
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, add child" do
      get :add_child, id: 10
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      delete :destroy, id: 10 # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

  end

end
