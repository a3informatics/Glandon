require 'rails_helper'

describe Thesauri::ManagedConceptsController do

  include DataHelpers
  include UserAccountHelpers
  include IsoManagedHelpers
  include ControllerHelpers

  def sub_dir
    return "controllers/thesauri/managed_concept"
  end

  def make_standard(item)
    IsoManagedHelpers.make_item_standard(item)
  end

  describe "Authorized User - Read" do

    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_upgrade.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..2)
    end

    it "changes" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:preferred_term_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_count).and_return(5)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :changes, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/managed_concepts/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/changes"})
      expect(response).to render_template("changes")
    end

    it "changes data" do
      expected = {:data=>{:items=>{:"1"=>{:changes_path=>"/thesauri/unmanaged_concepts/1/changes", :id=>"1"}, :"2"=>{:changes_path=>"/thesauri/unmanaged_concepts/2/changes", :id=>"2"}}}}
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      get :changes_data, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}
      expect(check_good_json_response(response)).to eq(expected)
    end

    it "changes summary" do
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:preferred_term_objects).and_return([])
      get :changes_summary, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, last_id: "bbb", ver_span: "x"}
      expect(assigns(:links)).to eq({})
      expect(assigns(:version_span)).to eq("x")
      expect(assigns(:version_count)).to eq(2)
      expect(assigns(:close_path)).to eq(dashboard_index_path)
      expect(response).to render_template("changes_summary")
    end

    it "changes summary data" do
      expected = {:data=>{items: {:"1"=>{:changes_path=>"/thesauri/unmanaged_concepts/1/changes", :id=>"1"}, :"2"=>{:changes_path=>"/thesauri/unmanaged_concepts/2/changes", :id=>"2"}}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_summary).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      get :changes_summary_data, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, last_id: "bbb", ver_span: "x"}
      expect(check_good_json_response(response)).to eq(expected)
    end

    it "changes summary data impact" do
      expected = {:data=>{items: {:"1"=>{:changes_path=>"/thesauri/unmanaged_concepts/1/changes", :id=>"1", :status=>"a"}, :"2"=>{:changes_path=>"/thesauri/unmanaged_concepts/2/changes", :id=>"2", :status=>"a"}}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes_summary_impact).and_return({items: {:"1" => {id: "1", status: "a"}, :"2" => {id: "2", status: "a"}}})
      get :changes_summary_data_impact, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, last_id: "bbb", ver_span: "x"}
      expect(check_good_json_response(response)).to eq(expected)
    end

    it "impact" do
      expected = {items: {:"1" => {id: "1"}, :"2" => {id: "2"}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:impact).and_return(expected)
      get :impact, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, impact: {sponsor_th_id: "sponsor.id"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "upgrade" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/U00001/V1#U00001"))
      source = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V1#C65047"))
      ref_ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      ct = Thesaurus.create({:identifier => "TESTUpgrade", :label => "Test Thesaurus"})
      ct.set_referenced_thesaurus(ref_ct)
      target = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V2#C65047"))
      put :upgrade, params:{id: tc.id, upgrade: {sponsor_th_id: ct.id}}
      expect(check_good_json_response(response)).to eq({:data=>{}})
    end

    it "upgrade, errors" do
      errors = ActiveModel::Errors.new(nil)
      errors.add(:base, "Error")
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/U00001/V1#U00001"))
      ct = Thesaurus.create({:identifier => "TESTUpgradeErr", :label => "Test Thesaurus"})
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:upgrade).and_return(nil)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:errors).twice.and_return(errors)
      put :upgrade, params:{id: tc.id, upgrade: {sponsor_th_id: ct.id}}
      expect(check_error_json_response(response)).to eq({:errors=>["Error"]})
    end

    it "upgrade data" do
      request.env['HTTP_ACCEPT'] = "application/json"
      s_th_old = Thesaurus.create({ :identifier => "S TH OLD", :label => "Old Sponsor Thesaurus" })
      r_th_old = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V1#TH"))
      r_th_new = Thesaurus.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V2#TH"))
      s_th_old.set_referenced_thesaurus(r_th_old)
      tc_old = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C65047/V1#C65047"))
      tc_new = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C65047/V2#C65047"))
      e_old = s_th_old.add_extension(tc_old.id)
      make_standard(e_old)
      s_th_old = Thesaurus.find_minimum(s_th_old.uri)
      make_standard(s_th_old)
      s_th_new = s_th_old.create_next_version
      s_th_new.set_referenced_thesaurus(r_th_new)
      s_th_new = Thesaurus.find_minimum(s_th_new.uri)
      get :upgrade_data, params:{id: tc_old.id, impact: {sponsor_th_id: s_th_new.id}}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "upgrade_data_expected_1.yaml")
    end

    it "differences summary" do
      expected = {:items=>{:"1"=>{:id=>"1"}, :"2"=>{:id=>"2"}}}
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:differences_summary).and_return(expected)
      get :differences_summary, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, last_id: "bbb", ver_span: "x"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "is_extended" do
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(true)
      get :is_extended, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}
      expect(check_good_json_response(response)).to eq({data: true})
    end

    it "is_extension" do
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extension?).and_return(false)
      get :is_extension, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}
      expect(check_good_json_response(response)).to eq({data: false})
    end

    it "show, no extension" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66767/V2#C66767")
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:extend_opts)).to eq({
        allowed: false,
        override: true,
        extended: false,
        extension: false,
        extending_path: "",
        extension_path: ""
      })
      expect(response).to render_template("show")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:extend_opts)[:allowed]).to eq(true)
    end

    it "show, non extensible code list" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66767/V2#C66767")
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return(true)
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:extend_opts)).to eq({
        allowed: false,
        override: true,
        extended: false,
        extension: false,
        extending_path: "",
        extension_path: ""
      })
      expect(response).to render_template("show")
    end

    it "show, non extensible code list" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66767/V2#C66767")
      expect(Thesaurus::ManagedConcept).to receive(:can_extend_unextensible?).and_return(false)
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:extend_opts)).to eq({
        allowed: false,
        override: false,
        extended: false,
        extension: false,
        extending_path: "",
        extension_path: ""
      })
      expect(response).to render_template("show")
    end

    it "show, extended" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      ext_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#XXXXX")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(true)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended_by).and_return(ext_uri)
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:extend_opts)).to eq({
        allowed: false,
        override: false,
        extended: true,
        extension: false,
        extending_path: "",
        extension_path: "/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th_uri.to_id)}"
      })
      expect(response).to render_template("show")
    end

    it "show, extending" do
      th_uri =  Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#C66780")
      ext_uri =  Uri.new(uri: "http://www.cdisc.org/C66780/V2#XXXXX")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extended?).and_return(false) # Note, wrong way but useful for test
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:extension_of).and_return(ext_uri)
      get :show, params:{id: tc_uri.to_id, managed_concept: {context_id: th_uri.to_id}}
      expect(assigns(:context_id)).to eq(th_uri.to_id)
      expect(assigns(:extend_opts)).to eq({
        allowed: true,
        override: false,
        extended: false,
        extension: true,
        extending_path: "/thesauri/managed_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2NzgwL1YyI1hYWFhY?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th_uri.to_id)}",
        extension_path: ""
      })
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
      get :show_data, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id, offset: 10, count: 10, managed_concept: {context_id: "bbb"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C28421/V1#C28421")
      get :children, params:{id: tc_uri.to_id}
      results = check_good_json_response(response)
      check_file_actual_expected(results, sub_dir, "children_expected_1.yaml", equate_method: :hash_equal)
    end

    it "export csv" do
      expect(Thesaurus::ManagedConcept).to receive(:find_full).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:scoped_identifier).and_return("C12345")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:to_csv).and_return(["XXX", "YYY"])
      expect(@controller).to receive(:send_data).with(["XXX", "YYY"], {filename: "CDISC_CL_C12345.csv", disposition: 'attachment', type: 'text/csv; charset=utf-8; header=present'})
      #expect(@controller).to receive(:render)
      get :export_csv, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}, format: 'text/csv'
    end

    it "pdf report" do
      expect(Thesaurus::ManagedConcept).to receive(:find_with_properties).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:scoped_identifier).and_return("C12345")
      expect_any_instance_of(Thesaurus::ManagedConcept).to receive(:changes).and_return({items: {:"1" => {id: "1"}, :"2" => {id: "2"}}})
      expect(Reports::CdiscChangesReport).to receive(:new).and_return(Reports::CdiscChangesReport.new)
      expect_any_instance_of(Reports::CdiscChangesReport).to receive(:create).and_return("abcd")
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :changes_report, params:{id: Uri.new(uri: "http://www.acme-pharma.com/aaa/V1#aaa").to_id}
      expect(response.content_type).to eq("application/pdf")
      expect(response.header["Content-Disposition"]).to eq("inline; filename=\"CDISC_CL_C12345.pdf\"")
    end

    it "set with indicators" do
      expect(Thesaurus::ManagedConcept).to receive(:set_with_indicators_paginated).with({"count"=>"10", "offset"=>"10", "type"=>"subsets"}).and_return([{x: 1}, {x: 2}])
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :set_with_indicators, params:{managed_concept: {offset: "10", count: "10", type: "subsets"}}
      results = check_good_json_response(response)
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

    it "shows the history, initial view" do
      params = {}
      get :history, params:{managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id}}
      expect(assigns(:tc).id).to eq("aHR0cDovL3d3dy5jZGlzYy5vcmcvQzY2Nzg2L1Y2MCNDNjY3ODY=")
      expect(assigns(:identifier)).to eq("C66786")
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(response).to render_template("history")
    end

    it "shows the history, page, bug GLAN-1107" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :history, params:{managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 0}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1a.yaml", equate_method: :hash_equal)
      expect(JSON.parse(response.body).deep_symbolize_keys[:offset]).to eq(0)
      expect(count = JSON.parse(response.body).deep_symbolize_keys[:count]).to eq(20)
      get :history, params:{managed_concept: {identifier: "C66786", scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 20}}
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
      put :update, params:{id: mc.id, edit: {notation: "AAAAA", parent_id: ct.id }}
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "update_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update properties" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(mc, @user)
      put :update_properties, params:{id: mc.id, edit: {synonym: "syn1; syn2"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:data][0]
      expect(actual[:synonym]).to eq("syn1; syn2")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "update properties, error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(mc, @user)
      put :update_properties, params:{id: mc.id, edit: {definition: "\#€=/*-/"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("Definition contains invalid characters")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "update properties, failed to lock" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      token = Token.obtain(mc, @lock_user)
      put :update_properties, params:{id: mc.id, edit: {definition: "ok def"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("The item is locked for editing by user: lock@example.com.")
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
      expect(AuditTrail).to receive(:update_item_event).with(@user, instance_of(Thesaurus::ManagedConcept), "Code list owner: ACME, identifier: A00001, was updated.")
      post :add_child, params:{id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
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
      post :add_child, params:{id: mc.id, managed_concept: {identifier: "A12345"}}
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
      post :add_child, params:{id: mc.id, managed_concept: {identifier: "A12345"}}
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
      post :add_child, params:{id: mc.id, managed_concept: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end


    it 'adds childrens synonyms to managed concept' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      uc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000012"))
      token = Token.obtain(mc, @user)
      post :add_children_synonyms, params:{id: mc.id, managed_concept: {reference_id: uc.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_children_synonyms_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'adds childrens synonyms to managed concept, error' do
      request.env['HTTP_ACCEPT'] = "application/json"
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      uc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      token = Token.obtain(mc, @user)
      post :add_children_synonyms, params:{id: mc.id, managed_concept: {reference_id: uc.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_children_synonyms_expected_2.yaml", equate_method: :hash_equal)
    end

    it "adds childrens synonyms to managed concept, failed to lock" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001"))
      uc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri:"http://www.acme-pharma.com/A00001/V1#A00001_A000011"))
      token = Token.obtain(mc, @lock_user)
      post :add_children_synonyms, params:{id: mc.id, managed_concept: {reference_id: uc.id}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("The item is locked for editing by user: lock@example.com.")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "edit" do
      uri_th = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      uri_tc = Uri.new(uri: "http://www.cdisc.org/C49489/V1#C49489")
      get :edit, params:{id: uri_tc.to_id, thesaurus_concept: {parent_id: uri_th.to_id}}
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
      get :edit, params:{id: uri_tc.to_id, thesaurus_concept: {parent_id: uri_th.to_id}}
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

    it "destroy" do
      audit_count = AuditTrail.count
      tc = Thesaurus::ManagedConcept.create
      delete :destroy, params:{id: tc.id}
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "destroy, error" do
      audit_count = AuditTrail.count
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      delete :destroy, params:{id: tc.id}
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The code list cannot be deleted as it is in use."])
      expect(AuditTrail.count).to eq(audit_count)
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
      get :find_subsets, params:{id: tc_uri.to_id}
      actual = JSON.parse(response.body)
      check_file_actual_expected(actual, sub_dir, "subsets_expected_1.yaml", equate_method: :hash_equal)
    end

    it "find subsets, no subsets found" do
      tc_uri =  Uri.new(uri: "http://www.cdisc.org/C81226/V19#C81226")
      get :find_subsets, params:{id: tc_uri.to_id}
      actual = JSON.parse(response.body)
      expect(actual["data"]).to eq([])
    end

    it "edit subset" do
      ct = Uri.new(uri: "http://www.cdisc.org/CT/V19#TH")
      sub_mc = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: "http://www.s-cubed.dk/S000001/V19#S000001"))
      sub_mc.synonyms_and_preferred_terms
      sub_mc.update(is_ordered: Thesaurus::Subset.create(parent_uri: sub_mc.uri))
      get :edit_subset, params:{id: sub_mc.id}
      expect(assigns(:subset_mc).id).to eq(sub_mc.id)
      expect(assigns(:source_mc).id).to eq(sub_mc.subsets_links.to_id)
      expect(assigns(:subset).uri.to_id).to eq(sub_mc.is_ordered.uri.to_id)
      expect(assigns(:close_path)).to eq(history_thesauri_managed_concepts_path({managed_concept: {identifier: sub_mc.scoped_identifier, scope_id: sub_mc.scope}}))
      expect(assigns(:token)).to_not eq(nil)
      expect(assigns(:upgradable)).to eq(false)
      expect(response).to render_template("edit_subset")
    end

    it "edit subset, locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/referrer'
      tc = Thesaurus::ManagedConcept.find_with_properties(Uri.new(uri: "http://www.s-cubed.dk/S000001/V19#S000001"))
      token = Token.obtain(tc, @lock_user)
      get :edit_subset, params:{id: tc.id}
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

    it "create subset" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66726/V19#C66726"))
      post :create_subset, params:{id: tc.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      x = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(JSON.parse(response.body).deep_symbolize_keys, sub_dir, "create_subset_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "rank" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      load_local_file_into_triple_store("models/thesaurus/rank", "rank_input_1.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "create rank" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V20#C66741"))
      post :add_rank, params:{id: tc.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "update rank" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V20#C66741"))
      content = {cli_id: Uri.new(uri:"http://www.cdisc.org/C66741/V20#C66741_C87054").to_id, rank: 2}
      put :update_rank, params:{id: tc.id, managed_concept: {children_ranks: [content]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "remove rank" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V20#C66741"))
      rank = Thesaurus::Rank.find(Uri.new(uri: "http://www.assero.co.uk/TRC#e0c80ddd-2f1c-4832-885e-9283e87d6bd8"))
      delete :remove_rank, params:{id: tc.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "get ranked children" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V20#C66741"))
      get :children_ranked, params:{id: tc.id, offset: 0, count: 17}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
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
      post :create_extension, params:{id: tc.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      x = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(JSON.parse(response.body).deep_symbolize_keys, sub_dir, "create_extension_expected_1.yaml", equate_method: :hash_equal)
    end

    it "edit extension" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      get :edit_extension, params:{id: tc.id}
      expect(assigns(:tc).id).to eq(tc.id)
      expect(assigns(:extended_tc).id).to eq(extended_tc.id)
      expect(assigns(:close_path)).to eq("/thesauri/managed_concepts/history?managed_concept%5Bidentifier%5D=A00001&managed_concept%5Bscope_id%5D=aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTlMjQUNNRQ%3D%3D")
      expect(assigns(:token)).to_not eq(nil)
      expect(assigns(:upgradable)).to eq(false)
      expect(response).to render_template("edit_extension")
    end

    it "edit extension, locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/referrer'
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      token = Token.obtain(tc, @lock_user)
      get :edit_extension, params:{id: tc.id}
      expect(assigns(:token)).to eq(nil)
      expect(response).to redirect_to("/referrer")
      expect(flash[:error]).to match(/The item is locked for editing by user: lock@example.com.*/)
    end

    it "add child to extension" do
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      child_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      token = Token.obtain(tc, @user)
      post :add_extensions, params:{id: tc.id, managed_concept: {set_ids: [{id: child_1.id, context_id: extended_tc.id}]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "add child to extension, failed to lock" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      extended_tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C99079/V28#C99079"))
      child_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      token = Token.obtain(tc, @lock_user)
       post :add_extensions, params:{id: tc.id, managed_concept: {set_ids: [{id: child_1.id, context_id: extended_tc.id}]}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("The item is locked for editing by user: lock@example.com.")
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

  describe "upgrade extensions" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..34)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "upgrade extension" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc_32 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      item_1 = tc_32.create_extension
      item_1 = Thesaurus::ManagedConcept.find_with_properties(item_1.uri)
      token = Token.obtain(item_1, @user)
      put :upgrade_extension, params:{id: item_1.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "upgrade_extension_expected_1.yaml", equate_method: :hash_equal)
    end

    it "upgrade extension, lock error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      tc_32 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      item_1 = tc_32.create_extension
      item_1 = Thesaurus::ManagedConcept.find_with_properties(item_1.uri)
      token = Token.obtain(item_1, @lock_user)
      put :upgrade_extension, params:{id: item_1.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "upgrade_extension_expected_2.yaml", equate_method: :hash_equal)
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

    describe "upgrade subsets" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..34)
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "upgrade subset" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc_32 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      item_1 = tc_32.create_subset
      item_1 = Thesaurus::ManagedConcept.find_minimum(item_1.uri)
      token = Token.obtain(item_1, @user)
      put :upgrade_subset, params:{id: item_1.id}
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "upgrade_subset_expected_1.yaml", equate_method: :hash_equal)
    end

    it "upgrade subset, lock error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      tc_32 = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri:"http://www.cdisc.org/C99079/V32#C99079"))
      item_1 = tc_32.create_subset
      item_1 = Thesaurus::ManagedConcept.find_minimum(item_1.uri)
      token = Token.obtain(item_1, @lock_user)
      put :upgrade_extension, params:{id: item_1.id}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "upgrade_subset_expected_2.yaml", equate_method: :hash_equal)
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "upgrade subset, bug" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.create
      make_standard(tc)
      item_1 = tc.create_subset
      item_1.update(is_ordered: Thesaurus::Subset.create(parent_uri: item_1.uri))
      tc.create_next_version
      item_1 = Thesaurus::ManagedConcept.find_minimum(item_1.uri)
      token = Token.obtain(item_1, @user)
      put :upgrade_subset, params:{id: item_1.id}
      actual = check_good_json_response(response)
      request.env['HTTP_ACCEPT'] = "application/json"
      get :edit_subset, params:{id: item_1.id}, as: :js
      expect(assigns(:subset_mc).id).to eq(item_1.id)
      expect(assigns(:source_mc).id).to eq(item_1.subsets_links.to_id)
      expect(assigns(:subset).uri.to_id).to eq(item_1.is_ordered_links.to_id)
      expect(assigns(:token)).to_not eq(nil)
      expect(assigns(:upgradable)).to eq(false)
      expect(response).to render_template("edit_subset")
    end

  end

  describe "add children" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_extension.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..4)
      Token.delete_all
    end

    after :each do
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "add children to standard" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66780/V4#C66780"))
      child = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66781/V4#C66781_C25301"))
      token = Token.obtain(tc, @user)
      post :add_children, params:{id: tc.id, managed_concept: {set_ids: [child.id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
    end

    it "add children to standard, error, subset" do
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67154/V4#C67154"))
      tc.add_link(:subsets, Uri.new(uri: "http://www.acme-pharma.com/FAKE/V1#FAKE"))
      child = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66781/V4#C66781_C25301"))
      token = Token.obtain(tc, @user)
      post :add_children, params:{id: tc.id, managed_concept: {set_ids: [child.id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["Code list is a subset."])
    end

    it "add children to standard, error token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V4#C65047"))
      child = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66781/V4#C66781_C25301"))
      post :add_children, params:{id: tc.id, managed_concept: {set_ids: [child.id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The edit lock has timed out."])
    end

    it "add children, failed to lock" do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      tc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C65047/V4#C65047"))
      child = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66781/V4#C66781_C25301"))
      token = Token.obtain(tc, @lock_user)
      post :add_children, params:{id: tc.id, managed_concept: {set_ids: [child.id]}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("The item is locked for editing by user: lock@example.com.")
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

  describe "pairing" do

    login_curator

    before :all do
      @lock_user = ua_add_user(email: "lock@example.com")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..4)
      Token.delete_all
    end

    after :each do
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "pair a code list" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      token = Token.obtain(parent, @user)
      post :pair, params:{id: parent.id, managed_concept: {reference_id: child.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq([])
    end

    it "pair a code list, error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      token = Token.obtain(parent, @user)
      post :pair, params:{id: parent.id, managed_concept: {reference_id: child.id}}
      post :pair, params:{id: parent.id, managed_concept: {reference_id: child.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["Pairing not permitted, already paired."])
    end

    it "pair a code list, error token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      post :pair, params:{id: parent.id, managed_concept: {reference_id: child.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The edit lock has timed out."])
    end

    it "unpair a code list" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      token = Token.obtain(parent, @user)
      post :pair, params:{id: parent.id, managed_concept: {reference_id: child.id}}
      post :unpair, params:{id: parent.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq([])
    end

    it "unpair a code list, error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      token = Token.obtain(parent, @user)
      post :unpair, params:{id: parent.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["Cannot unpair as the item is not paired."])
    end

    it "unpair a code list, error token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      parent = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C66741/V4#C66741"))
      child = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C67153/V4#C67153"))
      post :unpair, params:{id: parent.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(["The edit lock has timed out."])
    end

  end

  describe "Unauthorized User" do

    login_reader

    it "prevents access to a reader, edit" do
      get :edit, params:{id: 10}
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, add child" do
      get :add_child, params:{id: 10}
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      delete :destroy, params:{id: 10} # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

    it "add children" do
      post :add_children, params:{id: 10, managed_concept: {set_ids: ["15"]}}
      expect(response).to redirect_to("/")
    end

  end

end
