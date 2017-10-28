require 'rails_helper'

describe User do

	include DataHelpers
  include PauseHelpers

	before :all do
    AuditTrail.delete_all
  end

  it "determines if user is only a system admin" do
  	user = User.create email: "fred@fred.com", password: "12345678"
  	user.add_role :sys_admin
  	expect(user.is_only_sys_admin).to eq(false)
  	user.remove_role :reader
  	expect(user.is_only_sys_admin).to eq(true)
  	user.destroy
  end

  it "allows a user's roles to be listed" do
    user = User.new
    user.add_role :reader
    expect(user.role_list.to_s).to eq("[\"Reader\"]")
    user.add_role :curator
    expect(user.role_list.to_s).to eq("[\"Curator\", \"Reader\"]")
  end

  it "allows a user's roles to be listed as a string" do
    user = User.new
    user.add_role :reader
    expect(user.role_list_stripped).to eq("Reader")
    user.add_role :curator
    expect(user.role_list_stripped).to eq("Curator, Reader")
    user.add_role :content_admin
    expect(user.role_list_stripped).to eq("Content Admin, Curator, Reader")
  end

  it "sets the reader role when a user is created" do
    user = User.create :email => "fred@fred.com", :password => "password" 
    expect(user.role_list).to match_array(["Reader"])
    user.destroy
  end

  it "logs an audit event when a user password is changed" do
    user = User.new
    expect(user).to receive(:encrypted_password_changed?) {true}
    user.user_update
    expect(AuditTrail.count).to eq(1)
  end

  it "does not log an audit event when a user password is not changed" do
    user = User.new
    expect(user).to receive(:encrypted_password_changed?) {false}
    user.user_update
    expect(AuditTrail.count).to eq(0)
  end

end
