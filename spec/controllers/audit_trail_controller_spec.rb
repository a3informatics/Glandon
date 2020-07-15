require 'rails_helper'

describe AuditTrailController do

  include DataHelpers
  include PauseHelpers

  describe "audit trail as curator" do
  	
    login_curator
   
    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      AuditTrail.destroy_all
      User.destroy_all
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "CDISC", identifier: "I1", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "CDISC", identifier: "I2", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 1, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 2, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T1", version: "1", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T2", version: "2", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "ACME", identifier: "T3", version: "3", event: 3, description: "description")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
      ar = AuditTrail.create(date_time: Time.now, user: "user1@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
      ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Login")
      ar = AuditTrail.create(date_time: Time.now, user: "user2@example.com", owner: "", identifier: "", version: "", event: 4, description: "Logout")
    end

    after :all do
      User.destroy_all
      AuditTrail.destroy_all
    end
    
    it "index" do
      get :index
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(15) 
      expect(response).to render_template("index")
    end

    it "index, log" do
      expect(ConsoleLogger).to receive(:log).with("AuditTrailController", "index", "15 audit records.")
      get :index
      expect(response).to render_template("index")
    end

    it "search audit trail - event user" do
      user = User.find_by(:email => "base@example.com")
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "", :event =>"4"}}
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(4)
      expect(response).to render_template("index")
    end

    it "search audit trail - event create" do
      user = User.find_by(:email => "base@example.com")
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "", :event =>"1"}}
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(5)
      expect(response).to render_template("index")
    end

    it "search audit trail - event delete" do
      user = User.find_by(:email => "base@example.com")
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "", :event =>"3"}}
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(3)
      expect(response).to render_template("index")
    end

    it "search audit trail - owner" do
      user = User.find_by(:email => "base@example.com")
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"CDISC", :identifier => "", :event =>"0"}}
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(2)
      expect(response).to render_template("index")
    end

    it "search audit trail - identifier" do
      user = User.find_by(:email => "base@example.com")
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "T3", :event =>"0"}}
      expect(assigns(:users).count).to eq(2)
      expect(assigns(:owners).count).to eq(3)
      expect(assigns(:events).count).to eq(5)
      expect(assigns(:items).count).to eq(3)
      expect(response).to render_template("index")
    end

    it "export_csv" do
      get :export_csv
    end

    it "stats_by_domain" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :stats_by_domain
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end
    
    it "stats_by_current_week" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :stats_by_current_week
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end
    
    it "stats_by_year" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :stats_by_year
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "stats_by_year_by_month" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :stats_by_year_by_month
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end
    
    it "stats_by_year_by_week" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :stats_by_year_by_week
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

  end

  describe "Reader User" do
    
    login_reader

    it "index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it 'search' do
      user = User.create :email => "fred@example.com", :password => "changeme" 
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "T10", :event =>"0"}}
      expect(response).to redirect_to("/")
      user.destroy
    end

  end 
    
  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'search' do
      user = User.create :email => "fred@example.com", :password => "changeme" 
      put :search, params:{id: user.id, :audit_trail => {:user =>"", :owner =>"", :identifier => "T10", :event =>"0"}}
      expect(response).to redirect_to("/users/sign_in")
      user.destroy
    end

  end

end