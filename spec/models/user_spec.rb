require 'rails_helper'

describe User do

	include DataHelpers
  include PauseHelpers

	before :all do
    AuditTrail.delete_all
  end

  it "allows a user's roles to be listed" do
    user = User.new
    user.add_role Role::C_READER
    expect(user.role_list.to_s).to eq("[\"Reader\"]")
    user.add_role Role::C_CURATOR
    expect(user.role_list.to_s).to eq("[\"Curator\", \"Reader\"]")
  end

  it "allows a user's roles to be listed as a string" do
    user = User.new
    user.add_role Role::C_READER
    expect(user.role_list_stripped).to eq("Reader")
    user.add_role Role::C_CURATOR
    expect(user.role_list_stripped).to eq("Curator, Reader")
    user.add_role Role::C_CONTENT_ADMIN
    expect(user.role_list_stripped).to eq("Content Admin, Curator, Reader")
  end

  it "sets the reader role when a user is created" do
    user = User.new
    user.set_extra
    expect(user.role_list.to_s).to eq("[\"Reader\"]")
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

  it "determines if a user is a reader" do
    user = User.new
    expect(user.is_a_reader?).to eq(false)
    user.add_role Role::C_READER
    expect(user.is_a_reader?).to eq(true)
  end
  
  it "determines if a user is a curator" do
    user = User.new
    expect(user.is_a_curator?).to eq(false)
    user.add_role Role::C_CURATOR
    expect(user.is_a_reader?).to eq(true)
    expect(user.is_a_curator?).to eq(true)
  end

  it "determines if a user is a content admin" do
    user = User.new
    expect(user.is_a_content_admin?).to eq(false)
    user.add_role Role::C_CONTENT_ADMIN
    expect(user.is_a_reader?).to eq(true)
    expect(user.is_a_curator?).to eq(true)
    expect(user.is_a_content_admin?).to eq(true)
  end

  it "determines if a user is a system admin" do
    user = User.new
    expect(user.is_a_system_admin?).to eq(false)
    user.add_role Role::C_SYS_ADMIN
    expect(user.is_a_system_admin?).to eq(true)
  end

end
