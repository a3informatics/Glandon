require 'rails_helper'

describe UsersController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

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
      count = User.all.count
      post :create, user: { email: "new1@example.com", password: "12345678", password_confirmation: "12345678", name: "New" }
      expect(User.all.count).to eq(count + 1)
      expect(flash[:success]).to be_present
      expect(response).to redirect_to("/users")
    end

    it 'creates user, fails, short password' do
      user1 = User.create :email => "fred@example.com", :password => "changeme"
      user2 = User.create :email => "sid@example.com", :password => "changeme"
      user3 = User.create :email => "boris@example.com", :password => "changeme"
      count = User.all.count
      post :create, user: { email: "new2@example.com", password: "1234567", password_confirmation: "1234567", name: "New"  }
      expect(User.all.count).to eq(count)
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/users")
    end

    it 'deletes user' do
      user1 = User.create :email => "fred@example.com", :password => "changeme"
      user2 = User.create :email => "sid@example.com", :password => "changeme"
      user3 = User.create :email => "boris@example.com", :password => "changeme"
      user4 = User.create :email => "new@example.com", :password => "changeme"
      count = User.all.count
      delete :destroy, :id => user4.id
      expect(User.all.count).to eq(count - 1)
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
      user1.add_role :sys_admin
      user2 = User.create :email => "sid@example.com", :password => "changeme"
      user1.add_role :curator
      user3 = User.create :email => "boris@example.com", :password => "changeme"
      user1.add_role :content_admin
      role_sa = Role.where(name: "sys_admin").first
      role_r = Role.where(name: "reader").first
      role_cr = Role.where(name: "curator").first
      role_ca = Role.where(name: "content_admin").first
      put :update, {id: user2.id, :user => {role_ids: ["#{role_sa.id}", "#{role_r.id}", "#{role_cr.id}", "#{role_ca.id}"]}}
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

    it "prevents removing last sys admin user role" do
      current_user = User.find_by(:email => "base@example.com")
      put :update, {id: current_user.id, :user => {role_ids: ["#{Role.to_id(:curator)}"]}}
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You cannot remove the last system administrator.*/)

      current_user.add_role(:sys_admin)
    end

    it "allows removing sys admin user role if another sys admin exists" do
      admin_user = ua_add_user(email: "admin@example.com", role: :sys_admin)
      expect(admin_user.role_list_stripped).to eq("Reader, System Admin")

      put :update, {id: admin_user.id, :user => {role_ids: ["#{Role.to_id(:curator)}"]}}

      admin_user = User.find_by(:email => "admin@example.com")
      expect(admin_user.role_list_stripped).to eq("Curator")
      expect(response).to redirect_to("/users")
    end

    it "allows removing any role that's not sys admin" do
      admin_user = User.find_by(:email => "base@example.com")
      curator_user = ua_add_user(email: "curator@example.com", role: :curator)

      expect(admin_user.role_list_stripped).to eq("System Admin")
      expect(curator_user.role_list_stripped).to eq("Curator, Reader")

      put :update, {id: curator_user.id, :user => {role_ids: ["#{Role.to_id(:reader)}"]}}

      curator_user = User.find_by(:email => "curator@example.com")
      expect(curator_user.role_list_stripped).to eq("Reader")
      expect(response).to redirect_to("/users")
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
      delete :destroy, :id => 1
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "edits user" do
      user1 = User.create :email => "fred@example.com", :password => "changeme"
      get :edit, :id => user1.id
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "updates user" do
      user1 = User.create :email => "fred@example.com", :password => "changeme"
      put :update, {id: user1.id, :user => {role_ids: ["1", "2", "3", "4"]}}
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
      delete :destroy, :id => 1
      expect(response).to redirect_to("/users/sign_in")
    end

    it "edits user" do
      get :edit, :id => 1
      expect(response).to redirect_to("/users/sign_in")
    end

    it "updates user" do
      put :update, {id: 1, :user => {role_ids: ["1", "2", "3", "4"]}}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
