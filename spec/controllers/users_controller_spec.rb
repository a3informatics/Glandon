require 'rails_helper'

describe UsersController do

  include DataHelpers
  include PauseHelpers
  
  describe "Authorized User" do
  	
    login_sys_admin

    it "index users" do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      users = User.all
      get :index
      expect(assigns(:users).to_json).to eq(users.to_json)
      expect(response).to render_template("index")
    end

    it "new user" do
      get :new
      expect(response).to render_template("new")
    end

    it 'creates user' do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      post :create, user: { email: "new1@example.com", password: "12345678", password_confirmation: "12345678" }
      expect(User.all.count).to eq(6) # 1 in DB by default, 1 x Admin user, 3 x seeded and 1 created
      expect(flash[:success]).to be_present
      expect(response).to redirect_to("/users")
    end

    it 'creates user, fails, short password' do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      post :create, user: { email: "new2@example.com", password: "1234567", password_confirmation: "1234567" }
      expect(User.all.count).to eq(5)
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/users")
    end

    it 'deletes user' do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      user4 = User.create :email => "new@example.com", :password => "changeme" 
      delete :destroy, :id => user4.id
      expect(User.all.count).to eq(5)
    end

    it "edits user" do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      user = User.find_by(:email => "sid@example.com")
      get :edit, :id => user.id
      expect(response).to render_template("edit")
    end

    it "updates user" do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      user2 = User.create :email => "sid@example.com", :password => "changeme" 
      user3 = User.create :email => "boris@example.com", :password => "changeme" 
      user = User.find_by(:email => "sid@example.com")
      put :update, {id: user.id, :user => {role_ids: ["1", "2", "3", "4"]}}
      user = User.find_by(:email => "sid@example.com")
      expect(user.has_role? :sys_admin).to eq(true)
      expect(user.has_role? :reader).to eq(true)
      expect(user.has_role? :curator).to eq(true)
      expect(user.has_role? :content_admin).to eq(true)
      expect(response).to redirect_to("/users")
    end

    it "updates user name" do
      user1 = User.create :email => "fred@example.com", :password => "changeme", name: "x"
      user = User.find_by(:email => "fred@example.com")
      expect(user.name).to eq("x")
      put :update_name, {id: user.id, :user => {name: "Updated Name"}}
      user = User.find_by(:email => "fred@example.com")
      expect(user.name).to eq("Updated Name")
      expect(response).to redirect_to("/user_settings")
    end

  end

  describe "Unauthorized User" do
    
    login_reader

    it "index registration authority" do
      get :index
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "new registration authority" do
      get :new
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it 'creates namespace' do
      post :create, user: { email: "new2@example.com", password: "1234567", password_confirmation: "1234567" }
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it 'deletes user' do
      delete :destroy, :id => User.all.last.id
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "edits user" do
      get :edit, :id => User.all.last.id
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "updates user" do
      put :update, {id: User.all.last.id, :user => {role_ids: ["1", "2", "3", "4"]}}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do
    
    it "index scoped identifier" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "new scoped identifier" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'creates scoped_identifier' do
      post :create, user: { email: "new2@example.com", password: "1234567", password_confirmation: "1234567" }
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'deletes user' do
      delete :destroy, :id => User.all.last.id
      expect(response).to redirect_to("/users/sign_in")
    end

    it "edits user" do
      get :edit, :id => User.all.last.id
      expect(response).to redirect_to("/users/sign_in")
    end

    it "updates user" do
      put :update, {id: User.all.last.id, :user => {role_ids: ["1", "2", "3", "4"]}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end