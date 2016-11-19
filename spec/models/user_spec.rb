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

end
