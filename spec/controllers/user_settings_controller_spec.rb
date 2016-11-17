require 'rails_helper'

describe UserSettingsController do

  include DataHelpers
  include PauseHelpers

  describe "user settings as curator" do
  	
    login_curator
   
    it "index settings" do
      get :index
      expect(assigns(:settings_metadata).to_json).to eq("{\"paper_size\":{\"type\":\"enum\",\"enum_values\":[\"A3\",\"A4\",\"Letter\"],\"label\":\"Paper Size\"}}")
      expect(response).to render_template("index")
    end

    it "updates user" do
      user = User.find_by(:email => "user@example.com")
      put :update, {id: user.id, :user_settings => {:name => "paper_size", :value => "Letter"}}
      expect(user.read_setting(:paper_size).value).to eq("Letter")
      expect(response).to redirect_to("/user_settings")
    end

  end

  describe "Unauthorized User" do
    
    it "index user" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'creates user' do
      user = User.create :email => "fred@example.com", :password => "changeme" 
      put :update, {id: user.id, :user_settings => {:name => :paper_size, :value => "LETTER"}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end