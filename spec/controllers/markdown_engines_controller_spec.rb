require 'rails_helper'

describe MarkdownEnginesController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_content_admin

    it "index markdown" do
      get :index
      expect(response).to render_template("index")
    end

    it 'create markdown' do
      post :create, :markdown_engine => { :markdown => "Well this is a *test*"}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"result\":\"\\u003cp\\u003eWell this is a \\u003cem\\u003etest\\u003c/em\\u003e\\u003c/p\\u003e\\n\"}")
    end

  end

  describe "Unauthorized User" do
    
    it "index markdown" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'create markdown' do
      post :create
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end