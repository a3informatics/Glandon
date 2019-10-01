require 'rails_helper'

describe UserSettingsController do

  include DataHelpers
  include PauseHelpers
  include UserSettingsHelpers
  include UserAccountHelpers

  describe "user settings as curator" do

    login_curator

    it "index settings" do
      get :index
      expect(assigns(:settings_metadata)).to eq(us_expected_metadata)
      expect(response).to render_template("index")
    end

    it "updates user" do
      put :update, {id: @user.id, :user_settings => {:name => "paper_size", :value => "Letter"}}
      expect(@user.read_setting(:paper_size).value).to eq("Letter")
      expect(response).to redirect_to("/user_settings")
    end

  end

  describe "user settings as sys admin" do

  	login_sys_admin

    it "prevents access, index" do
      get :index
      expect(assigns(:settings_metadata)).to eq(us_expected_metadata)
      expect(response).to render_template("index")
    end

    it "prevents access, update" do
      put :update, {id: @user.id, :user_settings => {:name => "paper_size", :value => "Letter"}}
      expect(@user.read_setting(:paper_size).value).to eq("Letter")
      expect(response).to redirect_to("/user_settings")
    end

  end

  describe "Not logged in" do

    it "index user" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'updates user' do
      user = ua_add_user email: "fred@example.com"
      put :update, {id: user.id, :user_settings => {:name => :paper_size, :value => "LETTER"}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

  describe "user settings as community reader" do

    login_community_reader

    it "index settings" do
      get :index
      expect(assigns(:settings_metadata)).to eq(us_expected_metadata)
      expect(response).to render_template("index")
    end

    it "updates user" do
      put :update, {id: @user.id, :user_settings => {:name => "paper_size", :value => "Letter"}}
      expect(@user.read_setting(:paper_size).value).to eq("Letter")
      expect(response).to redirect_to("/user_settings")
    end

  end

end
