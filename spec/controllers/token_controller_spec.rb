require 'rails_helper'

describe TokensController do

  include DataHelpers
  include PauseHelpers

  describe "Token as Sys Admin" do
  	
    login_sys_admin
   
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_token_object
      Token.delete_all
      @user1 = User.create :email => "token@example.com", :password => "changeme" 
      @user1.add_role :reader
      item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      item1.id = "1"
      item2 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      item2.id = "2"
      item3 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      item3.id = "3"
      item4 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      item4.id = "4"
      @token1 = Token.obtain(item1, @user1)
      @token2 = Token.obtain(item2, @user1)
      @token3 = Token.obtain(item3, @user1)
      @token4 = Token.obtain(item4, @user1)
    end
    
    after :all do
      @user1 = User.where(:email => "token@example.com")
      @user1[0].destroy
      Token.delete_all
    end

    it "provides index of the tokens" do
      Token.set_timeout(5)
      get :index
      tokens = assigns(:tokens)
      expected = 
      [
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#1", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#2", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#3", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#4", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id }
      ]
      expect(assigns(:timeout)).to eq(5)
      expect(tokens.count).to eq(4)
      expected.each_with_index do |item, index|
        #token = tokens[index]
        token = tokens.find{|x| x.item_uri == item[:item_uri]}
        expect(token.refresh_count).to eq(item[:refresh_count]) 
        expect(token.item_uri).to eq(item[:item_uri]) 
        expect(token.item_info).to eq(item[:item_info]) 
        expect(token.user_id).to eq(item[:user_id])
        expect(token.locked_at).to be_within(2.second).of Time.now
      end
      expect(response).to render_template("index")
    end

    it "will release a token, HTTP" do
      post :release, :id => @token1.id
      tokens = Token.all
      expected = 
      [
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#2", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#3", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#4", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id }
      ]
      expect(tokens.count).to eq(3)
      expected.each_with_index do |item, index|
        #token = tokens[index]
        token = tokens.find{|x| x.item_uri == item[:item_uri]}
        expect(token.refresh_count).to eq(item[:refresh_count]) 
        expect(token.item_uri).to eq(item[:item_uri]) 
        expect(token.item_info).to eq(item[:item_info]) 
        expect(token.user_id).to eq(item[:user_id])
        expect(token.locked_at).to be_within(2.second).of Time.now
      end
      expect(response).to redirect_to("/tokens")
    end

    it "will release a token, JSON" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :release, :id => @token2.id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{}")
      tokens = Token.all
      expect(tokens.count).to eq(3)
      expected = 
      [
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#1", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#3", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id },
        { refresh_count: 0, item_uri: "http://www.assero.co.uk/MDRForms/ACME/V1#4", item_info: "[ACME, VS BASELINE, 1]", user_id: @user1.id }
      ]
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

    it "status" do
      get :status, :id => 6
      expect(response).to redirect_to("/")
    end

  end

  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

  end

  describe "Not Sys Admin User" do
    
    login_curator
   
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_token_object
      Token.delete_all
      @user1 = User.create :email => "token@example.com", :password => "changeme" 
      @user1.add_role :reader
      item1 = IsoManaged.find("F-ACME_VSBASELINE1", "http://www.assero.co.uk/MDRForms/ACME/V1")
      item1.id = "1"
      @token1 = Token.obtain(item1, @user1)
    end
    
    after :all do
      @user1 = User.where(:email => "token@example.com")
      @user1[0].destroy
      Token.delete_all
    end

    it "index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it "allows the staus of a token to be obtained" do
      request.env['HTTP_ACCEPT'] = "application/json"
      remaining = @token1.remaining
      post :status, :id => @token1.id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      result = JSON.parse(response.body)
      expect(result["running"]).to eq(true)
      expect(result["remaining"]).to eq(remaining)
    end

    it "allows the staus of a token to be obtained, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :status, :id => 6
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      result = JSON.parse(response.body)
      expect(result["running"]).to eq(false)
      expect(result["remaining"]).to eq(0)
    end

    it "allows the token to be extended, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, :id => 6
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{}")
    end

    it "allows the token to be extended" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, :id => @token1.id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{}")
      expect(@token1.remaining).to eq(Token.get_timeout)
    end

    it "allows the token to be extended, no token" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :extend_token, :id => 6
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")  
      expect(response.body).to eq("{}")
    end

  end

end