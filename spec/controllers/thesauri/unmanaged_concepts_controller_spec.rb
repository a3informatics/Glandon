require 'rails_helper'

describe Thesauri::UnmanagedConceptsController do

  include DataHelpers

  def sub_dir
    return "controllers/thesauri/unmanaged_concept"
  end

  describe "Authorized User" do

    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl"]
      load_files(schema_files, data_files)
    end

    after :each do
    end

    it "show" do
      @user.write_setting("max_term_display", 2)
      ct = Thesaurus.new
      expect(Thesaurus).to receive(:find_minimum).and_return(ct)
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(Thesaurus::UnmanagedConcept.new)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(Thesaurus::ManagedConcept.new)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:preferred_term_objects).and_return([])
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:children?).and_return(false)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:supporting_edit?).and_return(false)
      get :show, {id: "aaa", unmanaged_concept: {context_id: "bbb", parent_id: "ppp"}}
      expect(assigns(:context_id)).to eq("bbb")
      expect(assigns(:has_children)).to eq(false)
      expect(response).to render_template("show")
    end

    it "show data" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expected = [
        {id: "1", show_path: "/thesauri/unmanaged_concepts/1?unmanaged_concept%5Bcontext_id%5D=bbb"},
        {id: "2", show_path: "/thesauri/unmanaged_concepts/2?unmanaged_concept%5Bcontext_id%5D=bbb"}
      ]
      ct = Thesaurus.new
      expect(Thesaurus).to receive(:find_minimum).and_return(ct)
      expect(ct).to receive(:is_owned_by_cdisc?).and_return(true)
      expect(ct).to receive(:tag_labels).and_return([])
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(Thesaurus::UnmanagedConcept.new)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:children_pagination).and_return([{id: "1"}, {id: "2"}])
      get :show_data, {id: "aaa", offset: 10, count: 10, unmanaged_concept: {context_id: "bbb"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "changes" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(Thesaurus::UnmanagedConcept.new)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:synonym_objects).and_return([])
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:preferred_term_objects).and_return([])
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:changes_count).and_return(5)
      get :changes, id: "aaa"
      expect(response).to render_template("changes")
    end

    it "changes data" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(Thesaurus::UnmanagedConcept.new)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:changes).and_return({a: "1", b: "2"})
      get :changes_data, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({a: "1", b: "2"})
    end

    it "differences" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(Thesaurus::UnmanagedConcept.new)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:differences).and_return({a: "1", b: "2"})
      get :differences, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({a: "1", b: "2"})
    end

    it "updates concept, token" do
      umtc = Thesaurus::UnmanagedConcept.new
      umtc.notation = "NEW NOTATION"
      umtc.uri = Uri.new(uri: "http://www.s-cubed.dk/CT/V1#fake")
      umtc.set_persisted # Needed for id method to work for paths
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("X000001")
      mtc = Thesaurus::ManagedConcept.create
      expect(Thesaurus::UnmanagedConcept).to receive(:find_children).and_return(umtc)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(mtc)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:update).and_return(umtc)
      token = Token.obtain(mtc, @user)
      put :update, {id: umtc.id, edit: { parent_id: mtc.id, notation: "NEW NOTATION"}}
      expect(response.code).to eq("200")
      expect(response.content_type).to eq("application/json")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "update_expected_1.yaml")
    end

    it "updates concept, token but errors" do
      umtc = Thesaurus::UnmanagedConcept.new
      umtc.notation = "NEW NOTATION"
      umtc.uri = Uri.new(uri: "http://www.s-cubed.dk/CT/V1#fake")
      umtc.errors.add(:notation, "Notation fake error")
      umtc.errors.add(:identifier, "Identifier fake error")
      umtc.set_persisted # Needed for id method to work for paths
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("Y000001")
      mtc = Thesaurus::ManagedConcept.create
      token = Token.obtain(mtc, @user)
      expect(Thesaurus::UnmanagedConcept).to receive(:find_children).and_return(umtc)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(mtc)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:update).and_return(umtc)
      put :update, {id: umtc.id, edit: { parent_id: mtc.id, notation: "NEW NOTATION"}}
      expected = [{name: "notation", status: "Notation fake error"}, {name: "identifier", status: "Identifier fake error"}]
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:fieldErrors]).to eq(expected)
      #token = Token.obtain(th, @user)
      #expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "updates, error II" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      umc = mc.add_child({managed_concept: {notation: "T4"}})
      token = Token.obtain(mc, @user)
      put :update, {id: umc.id, edit: {parent_id: mc.id, preferred_term: "Terminal 5"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expected = [{name: "preferred_term", status: "duplicate detected 'Terminal 5'"}]
      expect(JSON.parse(response.body).deep_symbolize_keys[:fieldErrors]).to eq(expected)
    end

    it "updates concept, no token"

    it "deletes concept, token" do
      umtc = Thesaurus::UnmanagedConcept.new
      umtc.notation = "NEW NOTATION"
      umtc.uri = Uri.new(uri: "http://www.s-cubed.dk/CT/V1#fake")
      umtc.set_persisted # Needed for id method to work for paths
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("Y000001")
      mtc = Thesaurus::ManagedConcept.create
      token = Token.obtain(mtc, @user)
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(umtc)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(mtc)
      expect_any_instance_of(Thesaurus::UnmanagedConcept).to receive(:delete_or_unlink).and_return(1)
      put :destroy, {id: umtc.id, unmanaged_concept: { parent_id: mtc.id}}
      expected = []
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "deletes concept, no token" do
      umtc = Thesaurus::UnmanagedConcept.new
      umtc.notation = "NEW NOTATION"
      umtc.uri = Uri.new(uri: "http://www.s-cubed.dk/CT/V1#fake")
      umtc.set_persisted # Needed for id method to work for paths
      umtc.errors.add(:base, "Destroy error")
      expect(Thesaurus::ManagedConcept).to receive(:generated_identifier?).twice.and_return(true)
      expect(Thesaurus::ManagedConcept).to receive(:new_identifier).and_return("Y000001")
      mtc = Thesaurus::ManagedConcept.create
      expect(Thesaurus::UnmanagedConcept).to receive(:find).and_return(umtc)
      expect(Thesaurus::ManagedConcept).to receive(:find_minimum).and_return(mtc)
      put :destroy, {id: umtc.id, unmanaged_concept: { parent_id: mtc.id}}
      expected = ["The changes were not saved as the edit lock timed out."]
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(expected)
    end

    it "returns the synonym links, context" do
      expected =
      {
        :"Hair Cover"=>
        {
          :description=>"Hair Cover", 
          :references=>
          [
            {
              :parent=> { :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE=", :identifier=>"C95121", :notation=>"PHSPRPCD", :date=>"2011-06-10T00:00:00+00:00"}, 
              :child=> {:identifier=>"C95109", :notation=>"HAIRCOV"}, 
              :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjI2I1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE%3D"
            }
          ]
        }
      }
      load_cdisc_term_versions(1..30)
      request.env['HTTP_ACCEPT'] = "application/json"
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      get :synonym_links, {id: tc.id, unmanaged_concept: {context_id: th.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns the synonym links, no context" do
      expected =
      {
        :"Hair Cover"=>
        {
          :description=>"Hair Cover", 
          :references=>
          [
            {
              :parent=> {:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE=", :identifier=>"C95121", :notation=>"PHSPRPCD", :date=>"2011-06-10T00:00:00+00:00"}, 
              :child=>{:identifier=>"C95109", :notation=>"HAIRCOV"}, 
              :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE%3D"
            }
          ]
        }
      }
      load_cdisc_term_versions(1..30)
      request.env['HTTP_ACCEPT'] = "application/json"
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      get :synonym_links, {id: tc.id, unmanaged_concept: {
      }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns the synonym links, no context" do
      expected =
      {
        :"Hair Cover"=>
        {
          :description=>"Hair Cover", 
          :references=>
          [
            {
              :parent=> {:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE=", :identifier=>"C95121", :notation=>"PHSPRPCD", :date=>"2011-06-10T00:00:00+00:00"}, 
              :child=>{:identifier=>"C95109", :notation=>"HAIRCOV"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE%3D"
            }
          ]
        }
      }
      load_cdisc_term_versions(1..30)
      request.env['HTTP_ACCEPT'] = "application/json"
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      get :synonym_links, {id: tc.id, unmanaged_concept: {}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns the preferred term links, context" do
      expected =
      {
        :"Hair or Fur Cover"=>
        {
          :description=>"Hair or Fur Cover", 
          :references=>
          [
            {
              :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE=", :identifier=>"C95121", :notation=>"PHSPRPCD", :date=>"2011-06-10T00:00:00+00:00"}, 
              :child=>{:identifier=>"C95109", :notation=>"HAIRCOV"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjI2I1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE%3D"
            }
          ]
        }
      }
      load_cdisc_term_versions(1..30)
      request.env['HTTP_ACCEPT'] = "application/json"
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      get :preferred_term_links, {id: tc.id, unmanaged_concept: {context_id: th.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "returns the preferred term links, no context" do
      expected =
      {
        :"Hair or Fur Cover"=>
        {
          :description=>"Hair or Fur Cover", 
          :references=>
          [
            {
              :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE=", :identifier=>"C95121", :notation=>"PHSPRPCD", :date=>"2011-06-10T00:00:00+00:00"}, 
              :child=>{:identifier=>"C95109", :notation=>"HAIRCOV"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjE%3D"
            }
          ]
        }
      }
      load_cdisc_term_versions(1..30)
      request.env['HTTP_ACCEPT'] = "application/json"
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V26#TH"))
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C95120/V26#C95120_C95109"))
      get :preferred_term_links, {id: tc.id, unmanaged_concept: {}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq(expected)
    end

    it "update properties" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      umc = mc.add_child({managed_concept: {identifier: "SERVERIDENTIFER"}})
      token = Token.obtain(mc, @user)
      put :update_properties, {id: umc.id, edit: {parent_id: mc.id, synonym: "syn1; syn2"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:data][0]
      expect(actual[:synonym]).to eq("syn1; syn2")
      expect(AuditTrail.count).to eq(audit_count+1)
    end

    it "update properties, error I" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      umc = mc.add_child({managed_concept: {identifier: "SERVERIDENTIFER"}})
      token = Token.obtain(mc, @user)
      put :update_properties, {id: umc.id, edit: {parent_id: mc.id, definition: "\#€=/*-/"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("Definition contains invalid characters")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "update properties, error II" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      umc = mc.add_child({managed_concept: {notation: "T4"}})
      token = Token.obtain(mc, @user)
      put :update_properties, {id: umc.id, edit: {parent_id: mc.id, notation: "T5"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("Notation duplicate detected 'T5'")
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "update properties, error II" do
      request.env["HTTP_REFERER"] = "path"
      audit_count = AuditTrail.count
      mc = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.acme-pharma.com/A00001/V1#A00001"))
      umc = mc.add_child({managed_concept: {notation: "T4"}})
      token = Token.obtain(mc, @user)
      put :update_properties, {id: umc.id, edit: {parent_id: mc.id, preferred_term: "Terminal 5"}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(actual[0]).to eq("Preferred term duplicate detected 'Terminal 5'")
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

  describe "cross reference links" do

    login_curator

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "change_instructions_v53.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..53)
    end

    after :all do
    end

    it "returns the change instructions links" do
      uri_1 = Uri.new(uri: "http://www.cdisc.org/C128687/V49#C128687_C116248")
      uri_2 = Uri.new(uri: "http://www.cdisc.org/C128687/V49#C128687_C116252")
      tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(uri: "http://www.cdisc.org/C128687/V53#C128687_C139124"))
      th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
      expected =
      {
        :description=>"This term replaces term from the Microbiology Susceptibility TEST codelist. Per FDA guidance, for tests concerning 50% inhibition on microbial growth/replication, please use the newly released EC50 terms; for tests concerning 50% inhibition on microbial enzymatic activity, please use the newly released IC50 and IC95 terms.", 
        :previous=>
        [
          {
            :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw==", :identifier=>"C128687", :notation=>"MSTEST", :date=>"2017-06-30T00:00:00+00:00"}, 
            :child=>{:identifier=>"C116252", :notation=>"IC95 Reference Control Result"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjUy", 
            :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjUy?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjUzI1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw%3D%3D"}, 
            {
              :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw==", :identifier=>"C128687", :notation=>"MSTEST", :date=>"2017-06-30T00:00:00+00:00"}, 
              :child=>{:identifier=>"C116248", :notation=>"IC50 Reference Control Result"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjQ4", 
              :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjQ4?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjUzI1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw%3D%3D"
            }
          ], 
          :current=>[]
      }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :change_instruction_links, {id: tc.id, unmanaged_concept: {context_id: th.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to hash_equal(expected)
    end

  end

end
