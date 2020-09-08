require 'rails_helper'

describe TokensController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

  describe "Token as Sys Admin" do

    login_sys_admin

    def check_tokens(expected)
      tokens = Token.all
      expect(tokens.count).to eq(expected.count)
      expected.each_with_index do |item, index|
        #token = tokens[index]
        token = tokens.find{|x| x.item_uri == item[:item_uri]}
        expect(token.refresh_count).to eq(item[:refresh_count])
        expect(token.item_uri).to eq(item[:item_uri])
        expect(token.item_info).to eq(item[:item_info])
        expect(token.user_id).to eq(item[:user_id])
        expect(token.locked_at).to be_within(2.second).of Time.now
      end
    end

    def simple_thesaurus_1
      @th_1 = Thesaurus.new
      @th_1.set_initial("AIRPORTS1")
      @th_2 = Thesaurus.new
      @th_2.set_initial("AIRPORTS2")      
      @th_3 = Thesaurus.new
      @th_3.set_initial("AIRPORTS3")
      @th_4 = Thesaurus.new
      @th_4.set_initial("AIRPORTS4")
    end

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_vs_baseline.ttl"]
      load_files(schema_files, data_files)
      # clear_iso_concept_object
      # clear_iso_namespace_object
      # clear_iso_registration_authority_object
      # clear_iso_registration_state_object
      clear_token_object
      Token.delete_all
      @user1 = ua_add_user email: "token@example.com", role: :reader
      simple_thesaurus_1
      item1 = @th_1
      item2 = @th_2
      item3 = @th_3
      item4 = @th_4
      @token1 = Token.obtain(item1, @user1)
      @token2 = Token.obtain(item2, @user1)
      @token3 = Token.obtain(item3, @user1)
      @token4 = Token.obtain(item4, @user1)
    end

    after :each do
      ua_remove_user "token@example.com"
      Token.delete_all
      Token.restore_timeout
    end

    it "provides index of the tokens" do
      Token.set_timeout(5)
      get :index
      tokens = assigns(:tokens)
      expected =
      [
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS1/V1#TH", item_info: "[ACME, AIRPORTS1, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS2/V1#TH", item_info: "[ACME, AIRPORTS2, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS3/V1#TH", item_info: "[ACME, AIRPORTS3, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS4/V1#TH", item_info: "[ACME, AIRPORTS4, 1]", user_id: @user1.id }
      ]
      expect(assigns(:timeout)).to eq(5)
      check_tokens(expected)
      expect(response).to render_template("index")
    end

    it "will release a token, HTTP" do
      post :release, params:{:id => @token1.id}
      tokens = Token.all
      expected =
      [
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS2/V1#TH", item_info: "[ACME, AIRPORTS2, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS3/V1#TH", item_info: "[ACME, AIRPORTS3, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS4/V1#TH", item_info: "[ACME, AIRPORTS4, 1]", user_id: @user1.id }
      ]
      check_tokens(expected)
      expect(response).to redirect_to("/tokens")
    end

    it "will release a token, JSON" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :release, params:{:id => @token2.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{}")
      tokens = Token.all
      expected =
      [
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS1/V1#TH", item_info: "[ACME, AIRPORTS1, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS3/V1#TH", item_info: "[ACME, AIRPORTS3, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS4/V1#TH", item_info: "[ACME, AIRPORTS4, 1]", user_id: @user1.id }
      ]
      check_tokens(expected)
    end

    it "will release multiple tokens, JSON" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :release_multiple, params:{token: {id_set: [@token1.id, @token2.id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{}")
      expected =
      [
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS3/V1#TH", item_info: "[ACME, AIRPORTS3, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.acme-pharma.com/AIRPORTS4/V1#TH", item_info: "[ACME, AIRPORTS4, 1]", user_id: @user1.id },
      ]
      check_tokens(expected)
    end

    it "provides the token status" do
      request.env['HTTP_ACCEPT'] = "application/json"
      remaining = @token1.remaining
      post :status, params:{:id => @token1.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
      expect(result["running"]).to eq(true)
      expect(result["remaining"]).to eq(remaining)
    end

  end

  describe "Not logged in" do

    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "status" do
      post :status, params:{:id => 6}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "extend token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, params:{:id => 6}
      expect(response.status).to eq(401)
    end

  end

  describe "Curator User" do

    login_curator

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_vs_baseline.ttl"]
      load_files(schema_files, data_files)
      # clear_iso_concept_object
      # clear_iso_namespace_object
      # clear_iso_registration_authority_object
      # clear_iso_registration_state_object
      clear_token_object
      Token.delete_all
      @user1 = ua_add_user email: "token@example.com", role: :reader
      # item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      # item1.id = "1"
      item1 = IsoManagedV2.find_minimum(Uri.new(uri: "http://www.assero.co.uk/MDRForms/ACME/V1#F-ACME_VSBASELINE1"))
      @token1 = Token.obtain(item1, @user1)
    end

    after :all do
      ua_remove_user "token@example.com"
      Token.delete_all
    end

    it "index" do
      get :index
      expect(response).to render_template("index") # Tested above so don't repeat
    end

    it "allows the status of a token to be obtained" do
      request.env['HTTP_ACCEPT'] = "application/json"
      remaining = @token1.remaining
      post :status, params:{:id => @token1.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
      expect(result["running"]).to eq(true)
      expect(result["remaining"]).to eq(remaining)
    end

    it "allows the status of a token to be obtained, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :status, params:{:id => 6}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      result = JSON.parse(response.body)
      expect(result["running"]).to eq(false)
      expect(result["remaining"]).to eq(0)
    end

    it "allows the token to be extended, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, params:{:id => 6}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{}")
    end

    it "allows the token to be extended" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, params:{:id => @token1.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{}")
      expect(@token1.remaining).to eq(Token.get_timeout)
    end

    it "allows the token to be extended, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, params:{:id => 6}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{}")
    end

  end

end
