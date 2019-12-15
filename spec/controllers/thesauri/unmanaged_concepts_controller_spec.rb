require 'rails_helper'

describe Thesauri::UnmanagedConceptsController do

  include DataHelpers

  def sub_dir
    return "controllers/thesauri/unmanaged_concept"
  end

  describe "Authorized User" do

    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
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
      get :show, {id: "aaa", unmanaged_concept: {context_id: "bbb"}}
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
      mtc = Thesaurus::ManagedConcept.create({identifier: "X000001", notation: "X"})
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
      mtc = Thesaurus::ManagedConcept.create({identifier: "Y000001", notation: "Y"})
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

    it "updates concept, no token"

    it "deletes concept, token" do
      umtc = Thesaurus::UnmanagedConcept.new
      umtc.notation = "NEW NOTATION"
      umtc.uri = Uri.new(uri: "http://www.s-cubed.dk/CT/V1#fake")
      umtc.set_persisted # Needed for id method to work for paths
      mtc = Thesaurus::ManagedConcept.create({identifier: "Y000001", notation: "Y"})
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
      mtc = Thesaurus::ManagedConcept.create({identifier: "Y000001", notation: "Y"})
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
        :"Hair Cover" =>
        {
          :description => "Hair Cover",
          :references =>
          [
            {
              :parent => { :date => "2011-06-10T00:00:00+00:00", :identifier=>"C95121", :notation=>"PHSPRPCD" },
              :child =>  { :identifier => "C95109", :notation=>"HAIRCOV" },
              :id => "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5",
              :show_path => "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjI2I1RI"
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
        :"Hair Cover" =>
        {
          :description => "Hair Cover",
          :references =>
          [
            {
              :parent => { :date => "2011-06-10T00:00:00+00:00", :identifier=>"C95121", :notation=>"PHSPRPCD" },
              :child =>  { :identifier => "C95109", :notation=>"HAIRCOV" },
              :id => "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5",
              :show_path => "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?"
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
        :"Hair Cover" =>
        {
          :description => "Hair Cover",
          :references =>
          [
            {
              :parent => { :date => "2011-06-10T00:00:00+00:00", :identifier=>"C95121", :notation=>"PHSPRPCD" },
              :child =>  { :identifier => "C95109", :notation=>"HAIRCOV" },
              :id => "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5",
              :show_path => "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?"
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
        :"Hair or Fur Cover" =>
        {
          :description => "Hair or Fur Cover",
          :references =>
          [
            {
              :parent => { :date => "2011-06-10T00:00:00+00:00", :identifier=>"C95121", :notation=>"PHSPRPCD" },
              :child =>  { :identifier => "C95109", :notation=>"HAIRCOV" },
              :id => "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5",
              :show_path => "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjI2I1RI"
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
        :"Hair or Fur Cover" =>
        {
          :description => "Hair or Fur Cover",
          :references =>
          [
            {
              :parent => { :date => "2011-06-10T00:00:00+00:00", :identifier=>"C95121", :notation=>"PHSPRPCD" },
              :child =>  { :identifier => "C95109", :notation=>"HAIRCOV" },
              :id => "aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5",
              :show_path => "/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzk1MTIxL1YyNiNDOTUxMjFfQzk1MTA5?"
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
        description: "This term replaces term from the Microbiology Susceptibility TEST codelist. Per FDA guidance, for tests concerning 50% inhibition on microbial growth/replication, please use the newly released EC50 terms; for tests concerning 50% inhibition on microbial enzymatic activity, please use the newly released IC50 and IC95 terms.",
        current: [],
        previous:
        [
          {
            child: { identifier: "C116248", notation: "IC50 Reference Control Result" },
            id: uri_1.to_id,
            parent: { date: "2017-06-30T00:00:00+00:00", identifier: "C128687", notation: "MSTEST" },
            show_path: "/thesauri/unmanaged_concepts/#{uri_1.to_id}?unmanaged_concept%5Bcontext_id%5D=#{th.id}"
          },
          {
            child: { identifier: "C116252", notation: "IC95 Reference Control Result" },
            id: uri_2.to_id,
            parent: { date: "2017-06-30T00:00:00+00:00", identifier: "C128687", notation: "MSTEST" },
            show_path: "/thesauri/unmanaged_concepts/#{uri_2.to_id}?unmanaged_concept%5Bcontext_id%5D=#{th.id}"
          }
        ]
      }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :change_instruction_links, {id: tc.id, unmanaged_concept: {context_id: th.id}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to hash_equal(expected)
    end

  end

=begin
    it "edits concept, top level" do
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      params =
      {
        :id => "THC-A00001",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      result = assigns(:thesaurus_concept)
      referer_path = assigns(:referer_path)
      close_path = assigns(:close_path)
      expect(result.identifier).to eq("A00001")
      expect(result.notation).to eq("VSTEST")
      expect(result.definition).to eq("A set of additional Vital Sign Test Codes to extend the CDISC set.")
      expect(result.preferredTerm).to eq("")
      expect(result.synonym).to eq("")
      expect(referer_path).to eq("/thesauri/TH-SPONSOR_CT-1/edit?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FACME%2FV1")
      expect(close_path).to eq("/thesauri/history?identifier=CDISC+EXT&scope_id=#{IsoHelpers.escape_id(th.scope.id)}")
      expect(response).to render_template("edit")
    end

    it "edits concept, lower level" do
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      params =
      {
        :id => "THC-A00002",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      result = assigns(:thesaurus_concept)
      referer_path = assigns(:referer_path)
      close_path = assigns(:close_path)
      expect(result.identifier).to eq("A00002")
      expect(result.notation).to eq("APGAR")
      expect(result.definition).to eq("An APGAR Score")
      expect(result.preferredTerm).to eq("")
      expect(result.synonym).to eq("")
      expect(referer_path).to eq("/thesaurus_concepts/THC-A00001/edit?namespace=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FACME%2FV1")
      expect(close_path).to eq("/thesauri/history?identifier=CDISC+EXT&scope_id=#{IsoHelpers.escape_id(th.scope.id)}")
      expect(response).to render_template("edit")
    end

    it "edits concept, no token" do
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      params =
      {
        :id => "THC-A00001",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      expect(response).to redirect_to("/thesauri/history?identifier=CDISC+EXT&scope_id=#{IsoHelpers.escape_id(th.scope.id)}")
    end

    it "gets children" do
      params =
      {
        :id => "THC-A00010",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :children, params
      tc = ThesaurusConcept.find("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1", false)
      result = {}
      result[:data] = []
      tc.parentIdentifier = "A00010"
      result[:data] << tc.to_json
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq(result.to_json)
    end
=end



=begin
    it "adds child concept" do
      params =
      {
        :id => "THC-A00001",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept =>
        {
          :id => "",
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999",
          :notation => "NEW 999",
          :synonym => "New syn 999",
          :definition => "New def 999",
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      post :add_child, params
      tc = ThesaurusConcept.find("THC-A00001_A0000999", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      expect(tc.identifier).to eq("A00001.A0000999")
      expect(tc.notation).to eq("NEW 999")
      expect(tc.definition).to eq("New def 999")
      expect(tc.preferredTerm).to eq("New PT 999")
      expect(tc.synonym).to eq("New syn 999")
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "fails to add child concept, duplicate" do
      params =
      {
        :id => "THC-A00001",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept =>
        {
          :id => "",
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999",
          :notation => "NEW 999",
          :synonym => "New syn 999",
          :definition => "New def",
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      th = Thesaurus.find("TH-SPONSOR_CT-1", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      token = Token.obtain(th, @user)
      post :add_child, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The Thesaurus Concept, identifier A00001.A0000999, already exists\"]}")
    end

    it "fails to add child concept, no token" do
      params =
      {
        :id => "THC-A00001",
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
        :thesaurus_concept =>
        {
          :id => "",
          :namespace => "" ,
          :label => "New TC",
          :identifier => "A0000999",
          :notation => "NEW 999",
          :synonym => "New syn 999",
          :definition => "New def",
          :preferredTerm => "New PT 999",
          :type => "http://www.assero.co.uk/ISO25964#ThesaurusConcept"
        }
      }
      post :add_child, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      expect(response.body).to eq("{\"errors\":[\"The changes were not saved as the edit lock timed out.\"]}")
    end


    it "returns a concept as JSON" do
      params = { :id => "THC-A00001", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
    #write_yaml_file(result, sub_dir, "show_expected_1.yml")
      expected = read_yaml_file(sub_dir, "show_expected_1.yml")
      expect(result).to eq(expected)
    end

    it "returns a concept as HTML" do
      params = { :id => "THC-A00001", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
      get :show, params
      expect(response.content_type).to eq("text/html")
      expect(response.code).to eq("200")
    end

    it "returns the cross references" do
      # Set up references
      tc_1 = ThesaurusConcept.find("THC-A00010", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      tc_2 = ThesaurusConcept.find("THC-A00011", "http://www.assero.co.uk/MDRThesaurus/ACME/V1")
      or_1 = OperationalReferenceV2.new
      or_1.ordinal = 1
      or_1.subject_ref = tc_1.uri
      cr_1 = CrossReference.new
      cr_1.comments = "Linking two TCs"
      cr_1.ordinal = 1
      cr_1.children << or_1
      sparql = SparqlUpdateV2.new
      uri = cr_1.to_sparql_v2(tc_2.uri, sparql)
      sparql.triple({uri: tc_2.uri}, {:prefix => UriManagement::C_BCR, :id => "crossReference"}, {:uri => uri})
      result = CRUD.update(sparql.to_s)
      expect(result.success?).to eq(true)
      params = { id: tc_2.id, thesaurus_concept: {namespace: tc_2.namespace, direction: :from }}
      request.env['HTTP_ACCEPT'] = "application/json"
      get :cross_reference_start, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("[\"http://www.assero.co.uk/MDRThesaurus/ACME/V1#THC-A00011\"]")
    end

    it "returns the cross reference detail" do
      params = { id: "THC-A00011", thesaurus_concept: {namespace: "http://www.assero.co.uk/MDRThesaurus/ACME/V1", direction: :from }}
      request.env['HTTP_ACCEPT'] = "application/json"
      get :cross_reference_details, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
    #write_yaml_file(result, sub_dir, "cross_reference_details_expected_1.yml")
      expected = read_yaml_file(sub_dir, "cross_reference_details_expected_1.yml")
      expect(result).to eq(expected)
    end
=end

end
