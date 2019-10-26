require 'rails_helper'

describe ThesauriController do

  include DataHelpers
  include UserAccountHelpers
  
  def standard_params
    params = 
    {
      :draw => "1", 
      :columns =>
      {
        "0" => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "1" => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "2" => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "3" => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "4" => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "5" => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
      }, 
      :order => { "0" => { :column => "0", :dir => "asc" }}, 
      :start => "0", 
      :length => "15", 
      :search => { :value => "", :regex => "false" }, 
    }
    return params
  end

  def sub_dir
    return "controllers/thesauri"
  end

  describe "Authorized User" do
  	
    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
      load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :each do
      ua_remove_user("lock@example.com")
    end

    # it "new thesaurus" do
    #   get :new
    #   expect(response).to render_template("new")
    # end

    it "index" do
      expected = [{x: "a1", y: true, z: "something"}, {x: "a2", y: true, z: "something else"}]
      expect(Thesaurus).to receive(:unique).and_return(expected)
      get :index
      expect(assigns(:thesauri)).to eq(expected)
      expect(response).to render_template("index")
    end

    it "index owned" do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri = Uri.new(uri: "http://www.assero.co.uk/eee#aaa")
      scope_id = uri.to_id
      namespace = IsoNamespace.new
      namespace.uri = uri
      list = 
      [
        {scope_id: scope_id, x: "a1", y: true, z: "something"}, 
        {scope_id: scope_id, x: "a2", y: true, z: "something else"},
        {scope_id: "#{scope_id}BBB", x: "a1", y: true, z: "pah"}, 
        {scope_id: "#{scope_id}CCC", x: "a1", y: true, z: "not intersted"},
        {scope_id: scope_id, x: "a3", y: true, z: "something else and more"}
      ]
      expected = list.select{|x| x[:scope_id] == scope_id}
      expect(Thesaurus).to receive(:unique).and_return(list)
      expect(IsoRegistrationAuthority).to receive(:repository_scope).and_return(namespace)
      get :index_owned
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      expect(actual).to eq(expected)
    end

    it "shows the history, initial view" do
      params = {}
      expect(Thesaurus).to receive(:history_uris).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace)}).and_return([Uri.new(uri: "http://www.example.com/a#1")])
      get :history, {thesauri: {identifier: CdiscTerm::C_IDENTIFIER, scope_id: IsoRegistrationAuthority.cdisc_scope.id}}
      expect(assigns(:thesauri_id)).to eq("aHR0cDovL3d3dy5leGFtcGxlLmNvbS9hIzE=")
      expect(assigns(:identifier)).to eq(CdiscTerm::C_IDENTIFIER)
      expect(assigns(:scope_id)).to eq(IsoRegistrationAuthority.cdisc_scope.id)
      expect(response).to render_template("history")
    end

    it "shows the history, page" do
      CT1 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      CT2 = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus).to receive(:history_pagination).with({identifier: CdiscTerm::C_IDENTIFIER, scope: an_instance_of(IsoNamespace), offset: "20", count: "20"}).and_return([CT1, CT2])        
      get :history, {thesauri: {identifier: CdiscTerm::C_IDENTIFIER, scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 20}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_expected_1.yaml", equate_method: :hash_equal)
    end

    it "thesaurus history, none" do
      expect(Thesaurus).to receive(:history_uris).with({identifier: "CDISC EXT NEW", scope: an_instance_of(IsoNamespace)}).and_return([])
      get :history, {thesauri: {identifier: "CDISC EXT NEW", scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 20, offset: 20}}
      expect(response).to redirect_to("/thesauri")
    end

    it 'creates thesaurus' do
      audit_count = AuditTrail.count
      count = Thesaurus.all.count
      expect(count).to eq(2) 
      post :create, thesauri: { :identifier => "NEW TH", :label => "New Thesaurus" }
      expect(assigns(:thesaurus).errors.count).to eq(0)
      expect(Thesaurus.all.count).to eq(count + 1) 
      expect(flash[:success]).to be_present
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(response).to redirect_to("/thesauri")
    end

    it 'creates thesaurus, fails bad identifier' do
      count = Thesaurus.all.count
      expect(count).to eq(2) 
      post :create, thesauri: { :identifier => "NEW_TH!@£$%^&*", :label => "New Thesaurus" }
      count = Thesaurus.all.count
      expect(count).to eq(2) 
      expect(assigns(:thesaurus).errors.count).to eq(1)
      expect(Thesaurus.all.count).to eq(count) 
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/thesauri")
    end

    it "edits thesaurus, no next version" do
      ct = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      get :edit, id: ct.to_id
      result = assigns(:thesaurus)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.cdisc.org/CT/V1#TH") # Note no new version, no copy.
      expect(result.identifier).to eq("CT")
      expect(response).to render_template("edit")
    end

    it "edits thesaurus, create next version" do
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      result = assigns(:thesaurus)
      token = assigns(:token)
      expect(token.user_id).to eq(@user.id)
      expect(token.item_uri).to eq("http://www.assero.co.uk/MDRThesaurus/ACME/V2#TH-ACME_CDISCEXT") # Note we get a new version, 
      																																															# the edit causes the copy.
      expect(result.identifier).to eq("CDISC EXT")
      expect(response).to render_template("edit")
    end

    it "edits thesaurus, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/thesauri'
      th = Thesaurus.find("TH-ACME_CDISCEXT", "http://www.assero.co.uk/MDRThesaurus/ACME/V2") # Use the new version from previous test.
      token = Token.obtain(th, @lock_user)
      params = 
      {
        :id => "TH-ACME_CDISCEXT", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V2" ,
      }
      get :edit, params
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/thesauri")
    end
    
    it "edits thesaurus, copy, already locked" do
      @request.env['HTTP_REFERER'] = 'http://test.host/thesauri'
      # Lock the new thesaurus
      new_th = Form.new
      new_th.id = "TH-ACME_CDISCEXT" # Note the change of fragment, uses the identifier and thus changes
      new_th.namespace = "http://www.assero.co.uk/MDRThesaurus/ACME/V2" # Note the V2, the expected new version.
      new_th.registrationState.registrationAuthority = IsoRegistrationAuthority.owner
      new_token = Token.obtain(new_th, @lock_user)
      # Attempt to edit
      params = 
      {
        :id => "TH-SPONSOR_CT-1", 
        :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1" ,
      }
      get :edit, params
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/thesauri")
    end

    it "children" do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      post :children, {id: ct.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "children_expected_1.yaml", equate_method: :hash_equal)      
    end

    it 'adds a child thesaurus concept' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      new_ct = Thesaurus::ManagedConcept.new
      new_ct.identifier = "A12345"
      new_ct.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#fake")
      new_ct.set_persisted # Needed for id method to work for paths
      token = Token.obtain(ct, @user)
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus), @user).and_return(token)        
      expect_any_instance_of(Thesaurus).to receive(:add_child).with({identifier: "A12345"}).and_return(new_ct)
      expect(AuditTrail).to receive(:update_item_event).with(@user, instance_of(Thesaurus), "Terminology updated.")
      post :add_child, {id: ct.id, thesauri: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'adds a child thesaurus concept, token refreshed, no audit event' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      new_ct = Thesaurus::ManagedConcept.new
      new_ct.identifier = "A12345"
      new_ct.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#fake")
      new_ct.set_persisted # Needed for id method to work for paths
      token = Token.obtain(ct, @user)
      token.refresh
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus), @user).and_return(token)        
      expect_any_instance_of(Thesaurus).to receive(:add_child).with({identifier: "A12345"}).and_return(new_ct)        
      post :add_child, {id: ct.id, thesauri: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'adds a child thesaurus concept, error' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      token = Token.obtain(ct, @user)
      token.refresh
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus), @user).and_return(token) 
      mc = Thesaurus::ManagedConcept.new       
      mc.errors.add(:base, "Error message 1")
      mc.errors.add(:base, "Error message 2")
      expect_any_instance_of(Thesaurus).to receive(:add_child).with({identifier: "A12345"}).and_return(mc)        
      post :add_child, {id: ct.id, thesauri: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'fails to add a child thesaurus concept, locked by another user' do
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Token).to receive(:find_token).with(instance_of(Thesaurus), @user).and_return(nil) 
      post :add_child, {id: ct.id, thesauri: {identifier: "A12345"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
      actual = JSON.parse(response.body).deep_symbolize_keys[:errors]
      check_file_actual_expected(actual, sub_dir, "add_child_expected_4.yaml", equate_method: :hash_equal)
    end

    it 'fails to delete thesaurus, locked by another user' do
      @request.env['HTTP_REFERER'] = 'http://test.host/thesauri'
      th = Thesaurus.create({ :identifier => "NEW TH", :label => "New Thesaurus" })
      token = Token.obtain(th, @lock_user)
      audit_count = AuditTrail.count
      th_count = Thesaurus.all.count
      delete :destroy, id: th.id
      expect(Thesaurus.all.count).to eq(th_count)
      expect(AuditTrail.count).to eq(audit_count)
      expect(response).to redirect_to("/thesauri")
      expect(flash[:error]).to be_present
    end
    
    it 'deletes thesaurus' do
      @request.env['HTTP_REFERER'] = 'http://test.host/thesauri'
      th = Thesaurus.create({ :identifier => "NEW TH 2", :label => "New Thesaurus 2" })
      audit_count = AuditTrail.count
      th_count = Thesaurus.all.count
      token_count = Token.all.count
      delete :destroy, id: th.id
      expect(Thesaurus.all.count).to eq(th_count - 1)
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(Token.count).to eq(token_count)
    end

    it "show" do
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      get :show, id: "aaa"
      expect(response).to render_template("show")
    end

    it "show results" do
      th = Thesaurus.new
      th.uri = Uri.new(uri: "http://www.cdisc.org/CT/V1#TH")
      request.env['HTTP_ACCEPT'] = "application/json"
      expect(Thesaurus).to receive(:find_minimum).and_return(th)
      expect_any_instance_of(Thesaurus).to receive(:managed_children_pagination).with({:count=>"10", :offset=>"0"}).and_return([{id: Uri.new(uri: "http://www.assero.co.uk/MDRThesaurus/ACME/V1").to_id}])
      get :show, {id: "aaa", offset: 0, count: 10}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      x = JSON.parse(response.body).deep_symbolize_keys
      expect(x).to hash_equal({data: [{show_path: "/thesauri/managed_concepts/aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTURSVGhlc2F1cnVzL0FDTUUvVjE=?managed_concept%5Bcontext_id%5D=#{IsoHelpers.escape_id(th.id)}", 
        :id=>"aHR0cDovL3d3dy5hc3Nlcm8uY28udWsvTURSVGhlc2F1cnVzL0FDTUUvVjE="}], count: 1, offset: 0})
    end

    # it "view a thesaurus" do
    #   params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1", :children => [] }
    #   get :view, params
    #   expect(response.content_type).to eq("text/html")
    #   expect(response.code).to eq("200")    
    # end

    it "initiates a search of a single terminology" do
      params = standard_params
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      params[:id] = ct.uri.to_id
      get :search, params
      expect(response).to render_template("search")
    end
      
    it "initiates a search of the current terminologies" do
      params = standard_params
      get :search_current, params
      expect(response).to render_template("search_current")
    end

    it "obtains the search results" do
      request.env['HTTP_ACCEPT'] = "application/json"
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      params = standard_params
      params[:id] = ct.uri.to_id
      params[:columns]["5"][:search][:value] = "cerebral"
      get :search, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      actual = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(actual, sub_dir, "search_expected_1.yaml", equate_method: :hash_equal)
    end

    it "obtains the search results, empty search" do
      request.env['HTTP_ACCEPT'] = "application/json"
      ct = CdiscTerm.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      params = standard_params
      params[:id] = ct.uri.to_id
      results = ct.search(params)
      get :search, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")    
      actual = JSON.parse(response.body).deep_symbolize_keys
      check_file_actual_expected(actual, sub_dir, "search_expected_2.yaml", equate_method: :hash_equal)
    end

    it "export as TTL" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"}
      get :export_ttl, params
    end

    it "initiates the impact operation" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"}
    	th = Thesaurus.find(params[:id], params[:namespace])  	
      get :impact, params
      expect(assigns(:thesaurus).to_json).to eq(th.to_json)
      expect(assigns(:start_path)).to eq(impact_start_thesauri_index_path)
      expect(response).to render_template("impact")
    end

    it "starts the impact operation" do
      #params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"}
      params = { :id => "TH-CDISC_CDISCTerminology", :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V43" }
    	th = Thesaurus.find(params[:id], params[:namespace])  	
    	request.env['HTTP_ACCEPT'] = "application/json"
      get :impact_start, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")   
    #write_text_file_2(response.body, sub_dir, "thesauri_controller_impact_start.txt")
      expected = read_text_file_2(sub_dir, "thesauri_controller_impact_start.txt")
      expect(response.body).to eq(expected)
	  end

	  it "produces a pdf report" do
      params = { :id => "TH-SPONSOR_CT-1", :namespace => "http://www.assero.co.uk/MDRThesaurus/ACME/V1"}
    	th = Thesaurus.find(params[:id], params[:namespace])  	
      request.env['HTTP_ACCEPT'] = "application/pdf"
      get :impact_report, params
      expect(response.content_type).to eq("application/pdf")
      expect(response.header["Content-Disposition"]).to eq("inline; filename=\"impact_analysis.pdf\"")
      expect(assigns(:render_args)).to eq({page_size: @user.paper_size, lowquality: true, basic_auth: nil})
	  end

    it "changes" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :changes, id: "aaa"
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/changes"})
      expect(response).to render_template("changes")
    end

    it "obtains the change results" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:changes).with(2).and_return({versions: ["2019-01-01"], items: {}})
      request.env['HTTP_ACCEPT'] = "application/json"
      get :changes_data, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200") 
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({items: {}, versions: ["2019-01-01"]})
    end

    it "changes_report" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/pdf"
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:changes).with(2).and_return({versions: ["2019-01-01"], items: {}})
      get :changes_report, id: "aaa"
      expect(response.content_type).to eq("application/pdf")
    end

    it "submission" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:forward_backward).and_return({start: nil, end: Uri.new(uri: "http://www.xxx.com/aaa#1")})
      get :submission, id: "aaa"
      expect(assigns(:links)).to eq({start: "", end: "/thesauri/aHR0cDovL3d3dy54eHguY29tL2FhYSMx/submission"})
      expect(response).to render_template("submission")
    end

    it "obtains the submission results" do
      @user.write_setting("max_term_display", 2)
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:submission).with(2).and_return({versions: ["2019-01-01"], items: {}})
      request.env['HTTP_ACCEPT'] = "application/json"
      get :submission_data, id: "aaa"
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200") 
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({items: {}, versions: ["2019-01-01"]})
    end

    it "submission_report" do
      @user.write_setting("max_term_display", 2)
      request.env['HTTP_ACCEPT'] = "application/pdf"
      expect(Thesaurus).to receive(:find_minimum).and_return(Thesaurus.new)
      expect_any_instance_of(Thesaurus).to receive(:submission).with(2).and_return({versions: ["2019-01-01"], items: {}})
      get :submission_report, id: "aaa"
      expect(response.content_type).to eq("application/pdf")
    end

    it "extension" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extension, {thesauri: {}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200") 
      expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to eq({items: {}, versions: ["2019-01-01"]})
    end

  end

  describe "Community Reader" do
    
    login_community_reader

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
      ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :each do
      ua_remove_user("lock@example.com")
    end

    it "index" do
      expected = [{x: "a1", y: true, z: "something"}, {x: "a2", y: true, z: "something else"}]
      expect(Thesaurus).to receive(:unique).and_return(expected)
      get :index
      expect(assigns(:thesauri)).to eq(expected)
      expect(response).to redirect_to("/")
    end

    it "history" do
      params = {}
      get :history, {thesauri: {identifier: CdiscTerm::C_IDENTIFIER, scope_id: IsoRegistrationAuthority.cdisc_scope.id}}
      expect(response).to redirect_to("/cdisc_terms/history")
    end

  end

  describe "Unauthorized User" do
    
    login_reader

    it "prevents access to a reader, edit" do
      get :edit, id: 1 # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, add child" do
      get :add_child
      expect(response).to redirect_to("/")
    end

    it "prevents access to a reader, destroy" do
      delete :destroy, id: 10 # id required to be there for routing, can be anything
      expect(response).to redirect_to("/")
    end

  end

  describe "Controller Helpers" do

    # Tested here as difficult to setup test environment for the helpers with policies and paths
    
    login_curator

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..5)
    end

    it "adds history paths, status path" do
      # No current
      request.env['HTTP_ACCEPT'] = "application/json"
      get :history, {thesauri: {identifier: CdiscTerm::C_IDENTIFIER, scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 10, offset: 0}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_paths_expected_1.yaml", equate_method: :hash_equal)
      # With current
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V3#TH"))
      ct.has_state.make_current
      request.env['HTTP_ACCEPT'] = "application/json"
      get :history, {thesauri: {identifier: CdiscTerm::C_IDENTIFIER, scope_id: IsoRegistrationAuthority.cdisc_scope.id, count: 10, offset: 0}}
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "history_paths_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end