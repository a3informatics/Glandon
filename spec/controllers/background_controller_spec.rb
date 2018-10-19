require 'rails_helper'

describe BackgroundsController do

  include DataHelpers
  include PauseHelpers

  describe "background as content admin" do
  	
    login_content_admin
   
    before :each do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      Background.delete_all
      @b1 = Background.create(description: "job 1", complete: true, percentage: 100, status: "Doing something", started: Time.now, completed: Time.now)
      @b2 = Background.create(description: "job 2", complete: false, percentage: 50, status: "Doing something", started: Time.now, completed: Time.now)
      @b3 = Background.create(description: "job 3", complete: false, percentage: 60, status: "Doing something", started: Time.now, completed: Time.now)
    end
    
    after :each do
    end
    
    it "index" do
      get :index
      expect(assigns(:jobs).count).to eq(3)
      expect(assigns(:jobs).map{|j| j.id}).to match_array([@b1.id, @b2.id, @b3.id])
      expect(response.code).to eq("200")
      expect(response).to render_template("index")
    end

    it "destroy" do
      expect(Background.all.count).to eq(3)
      delete :destroy, {id: @b2.id}
      expect(Background.all.count).to eq(2)
      expect(Background.all.map{|j| j.id}).to match_array([@b1.id, @b3.id])
      expect(response).to redirect_to(backgrounds_path)
    end

    it "destroy, child import exists" do
      import = Import.create(background_id: @b2.id)
      expect(Background.all.count).to eq(3)
      delete :destroy, {id: @b2.id}
      expect(Background.all.count).to eq(3)
      expect(Background.all.map{|j| j.id}).to match_array([@b1.id, @b2.id, @b3.id])
      expect(response).to redirect_to(backgrounds_path)
    end

    it "destroy_multiple all" do
      expect(Background.all.count).to eq(3)
      delete :destroy_multiple, {backgrounds: {items: "all"}}
      expect(Background.all.count).to eq(0)
      expect(response).to redirect_to(backgrounds_path)
    end

    it "destroy_multiple all, child import exists" do
      import = Import.create(background_id: @b2.id)
      expect(Background.all.count).to eq(3)
      delete :destroy_multiple, {backgrounds: {items: "all"}}
      expect(Background.all.count).to eq(1)
      expect(Background.all.map{|j| j.id}).to match_array([@b2.id])
      expect(response).to redirect_to(backgrounds_path)
    end

    it "destroy_multiple completed" do
      expect(Background.all.count).to eq(3)
      delete :destroy_multiple, {backgrounds: {items: "completed"}}
      expect(Background.all.count).to eq(2)
      expect(Background.all.map{|j| j.id}).to match_array([@b2.id, @b3.id])
      expect(response).to redirect_to(backgrounds_path)
    end

    it "destroy_multiple completed, child import exists" do
      import = Import.create(background_id: @b1.id)
      expect(Background.all.count).to eq(3)
      delete :destroy_multiple, {backgrounds: {items: "completed"}}
      expect(Background.all.count).to eq(3)
      expect(Background.all.map{|j| j.id}).to match_array([@b1.id, @b2.id, @b3.id])
      expect(response).to redirect_to(backgrounds_path)
    end

  end

  describe "Reader User" do
    
    login_reader

    it "index" do
      get :index
      expect(response).to redirect_to("/")
    end

    it "destroy" do
      delete :destroy, {id: 1}
      expect(response).to redirect_to("/")
    end

    it "destroy_multiple" do
      delete :destroy_multiple
      expect(response).to redirect_to("/")
    end

  end 
    
  describe "Unauthorized User" do
    
    it "index" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy" do
      delete :destroy, {id: 1}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy_multiple" do
      delete :destroy_multiple
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end