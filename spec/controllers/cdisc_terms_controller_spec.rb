require 'rails_helper'

describe CdiscTermsController do

  include DataHelpers
  include PauseHelpers
  include PublicFileHelpers
  
  def sub_dir
    return "controllers/cdisc_terms"
  end
    
  describe "Curator User" do
  	
    login_curator

    # def standard_params
    #   params = 
    #   {
    #     :draw => "1", 
    #     :columns =>
    #     {
    #       "0" => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "1" => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "2" => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "3" => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "4" => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
    #       "5" => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
    #     }, 
    #     :order => { "0" => { :column => "0", :dir => "asc" }}, 
    #     :start => "0", 
    #     :length => "15", 
    #     :search => { :value => "", :regex => "false" }, 
    #     :id => "TH-CDISC_CDISCTerminology", 
    #     :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
    #   }
    #   return params
    # end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
    load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
  end

    it "index" do
      return_values = []
      (1..20).each_with_index {|x, index| return_values << {id: Uri.new(uri: "http://www.example.com/a##{index+1}").to_id, date: "#{1998+index}-01-01"}}
      expect(CdiscTerm).to receive(:version_dates).and_return(return_values)
      get :index
      expect(assigns(:current_id)).to eq(Uri.new(uri: "http://www.example.com/a#17").to_id) # 4th to end
      expect(assigns(:latest_id)).to eq(Uri.new(uri: "http://www.example.com/a#20").to_id) # Latest
      expect(assigns(:versions)).to eq(return_values)
      expect(assigns(:versions_yr_span)).to eq(["1998", "2017"])
      expect(response).to render_template("index")
    end

    it "shows the history, initial view" do
      ct = Thesaurus.new
      ct.uri = Uri.new(uri: "http://www.example.com/th#th")
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1"),Uri.new(uri: "http://www.example.com/a#2")])
      expect(Thesaurus).to receive(:find_minimum).with(Uri.new(uri: "http://www.example.com/a#2").to_id).and_return(ct)
      get :history
      expect(assigns(:cdisc_term_id)).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9hIzI=")
      expect(assigns(:identifier)).to eq(CdiscTerm::C_IDENTIFIER)
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(assigns(:ct).uri).to eq(ct.uri)
      expect(response).to render_template("history")
    end

    it "shows the history, page" do
      CT1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      CT2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus).to receive(:history_pagination).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([CT1, CT2])        
      get :history, {cdisc_term: {count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Content Admin User" do
    
    login_content_admin

    it "shows the history, initial view" do
      ct = Thesaurus.new
      ct.uri = Uri.new(uri: "http://www.example.com/th#th")
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1"),Uri.new(uri: "http://www.example.com/a#2")])
      expect(Thesaurus).to receive(:find_minimum).with(Uri.new(uri: "http://www.example.com/a#2").to_id).and_return(ct)
      get :history
      expect(assigns(:cdisc_term_id)).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9hIzI=")
      expect(assigns(:identifier)).to eq(CdiscTerm::C_IDENTIFIER)
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(assigns(:ct).uri).to eq(ct.uri)
      expect(response).to render_template("history")
    end

  end

  describe "Community Reader" do
    
    login_community_reader

    it "changes, window size 2" do
      uri1 = Uri.new(uri: "http://www.example.com/a#1")
      uri2 = Uri.new(uri: "http://www.example.com/a#2")
      x = Thesaurus.new
      y = Thesaurus.new
      x.uri = uri1
      y.uri = uri2
      expect(CdiscTerm).to receive(:version_dates).and_return([{id:uri1.to_id},{id:uri2.to_id}])
      expect(Thesaurus).to receive(:find_minimum).with(uri1.to_id).and_return(x)
      expect(Thesaurus).to receive(:find_minimum).with(uri2.to_id).and_return(y)
      expect_any_instance_of(Thesaurus).to receive(:changes_cdu).with(2).and_return({created: [{identifier: "1234", label: "Severity", notation: "AESEV", id: "aaa"},
                                                                                                {identifier: "12345", label: "Severity", notation: "AESEV", id: "aaa2"},
                                                                                                {identifier: "123456", label: "Severity", notation: "AESEV", id: "aaa3"}
                                                                                                ], 
                                                                                      deleted: [{identifier: "123", label: "Patient", notation: "PTient", id: "aaa3"}
                                                                                                ], 
                                                                                      updated: [{identifier: "15635", label: "Country", notation: "COUNTRY", id: "bbb2"},
                                                                                                {identifier: "12345", label: "Severity", notation: "AESEV", id: "aaa2"}
                                                                                                ],
                                                                                      versions: ["XXX","YYY"]
                                                                                    })
      request.env['HTTP_ACCEPT'] = "application/json" 
      get :changes, {cdisc_term: {other_id: uri2.to_id}, id: uri1.to_id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "changes_expected_1.yaml", equate_method: :hash_equal)
    end

    it "changes, window size 6" do
      uri1 = Uri.new(uri: "http://www.example.com/a#1")
      uri2 = Uri.new(uri: "http://www.example.com/a#2")
      x = Thesaurus.new
      y = Thesaurus.new
      x.uri = uri1
      y.uri = uri2
      expect(CdiscTerm).to receive(:version_dates).and_return([{id:uri1.to_id},{id: "eee"},{id: "iii"},{id: "ooo"},{id: "uuu"},{id:uri2.to_id}])
      expect(Thesaurus).to receive(:find_minimum).with(uri1.to_id).and_return(x)
      expect(Thesaurus).to receive(:find_minimum).with(uri2.to_id).and_return(y)
      expect_any_instance_of(Thesaurus).to receive(:changes_cdu).with(6).and_return({created: [{identifier: "12345", label: "Severity", notation: "AESEV", id: "aaa"}], 
                                                                                      deleted: [{identifier: "123", label: "Patient", notation: "PTient", id: "bbb"}], 
                                                                                      updated: [{identifier: "15635", label: "Country", notation: "COUNTRY", id: "ccc"}],
                                                                                      versions: ["AAA","BBB"]
                                                                                    })
      request.env['HTTP_ACCEPT'] = "application/json" 
      get :changes, {cdisc_term: {other_id: uri2.to_id}, id: uri1.to_id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "changes_expected_2.yaml", equate_method: :hash_equal)
    end

    it "changes, window size 10" do
      uri1 = Uri.new(uri: "http://www.example.com/a#1")
      uri2 = Uri.new(uri: "http://www.example.com/a#2")
      x = Thesaurus.new
      y = Thesaurus.new
      x.uri = uri1
      y.uri = uri2
      expect(CdiscTerm).to receive(:version_dates).and_return([{id: "eee"},{id:uri1.to_id},{id: "mmm"},{id: "nnn"},{id: "ppp"},
                                                              {id: "iii"},{id: "ooo"},{id: "uuu"},{id: "qqq"},{id: "www"},{id:uri2.to_id},{id: "ttt"},{id: "rrr"}])
      expect(Thesaurus).to receive(:find_minimum).with(uri1.to_id).and_return(x)
      expect(Thesaurus).to receive(:find_minimum).with(uri2.to_id).and_return(y)
      expect_any_instance_of(Thesaurus).to receive(:changes_cdu).with(10).and_return({created: [{identifier: "1234", label: "Severity", notation: "AESEV", id: "aaa"},
                                                                                                {identifier: "12345", label: "Severity", notation: "AESEV", id: "aaa2"},
                                                                                                {identifier: "123456", label: "Severity", notation: "AESEV", id: "aaa3"},
                                                                                                {identifier: "123457", label: "Severity", notation: "AESEV", id: "aaa4"},
                                                                                                {identifier: "15635", label: "Country", notation: "COUNTRY", id: "bbb2"}
                                                                                                ], 
                                                                                      deleted: [{identifier: "123", label: "Patient", notation: "PTient", id: "aaa3"},
                                                                                                {identifier: "123457", label: "Severity", notation: "AESEV", id: "aaa4"}
                                                                                                ], 
                                                                                      updated: [{identifier: "15635", label: "Country", notation: "COUNTRY", id: "bbb2"},
                                                                                                {identifier: "12345", label: "Severity", notation: "AESEV", id: "aaa2"}
                                                                                                ],
                                                                                      versions: ["CCC","DDD"]
                                                                                    })
      request.env['HTTP_ACCEPT'] = "application/json" 
      get :changes, {cdisc_term: {other_id: uri2.to_id}, id: uri1.to_id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "changes_expected_3.yaml", equate_method: :hash_equal)
    end

  end

  describe "Reader User" do
    
    login_reader

    it "shows the history, initial view" do
      ct = Thesaurus.new
      ct.uri = Uri.new(uri: "http://www.example.com/th#th")
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1"),Uri.new(uri: "http://www.example.com/a#2")])
      expect(Thesaurus).to receive(:find_minimum).with(Uri.new(uri: "http://www.example.com/a#2").to_id).and_return(ct)
      get :history
      expect(assigns(:cdisc_term_id)).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9hIzI=")
      expect(assigns(:identifier)).to eq(CdiscTerm::C_IDENTIFIER)
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(assigns(:ct).uri).to eq(ct.uri)
      expect(response).to render_template("history")
    end

  end
  
end