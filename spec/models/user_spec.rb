require 'rails_helper'

describe "User" do

  C_EMAIL = "fred@example.com"

	include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

	before :all do
    AuditTrail.delete_all
  end

  it "determines if user is only a system admin" do
  	user = ua_add_user(email: C_EMAIL)
  	user.add_role :sys_admin
  	expect(user.is_only_sys_admin).to eq(false)
  	user.remove_role :reader
  	expect(user.is_only_sys_admin).to eq(true)
  	ua_remove_user(C_EMAIL)
  end

  it "determines if user is only a community reader" do
    user = ua_add_user(email: C_EMAIL)
    user.add_role :community_reader
    expect(user.is_only_community?).to eq(false)
    user.remove_role :reader
    expect(user.is_only_community?).to eq(true)
    ua_remove_user(C_EMAIL)
  end

  it "allows a user's roles to be listed" do
    user = ua_add_user(email: C_EMAIL)
    user.add_role :reader
    expect(user.role_list.to_s).to eq("[\"Reader\"]")
    user.add_role :curator
    expect(user.role_list.to_s).to eq("[\"Curator\", \"Reader\"]")
    ua_remove_user(C_EMAIL)
  end

  it "allows a user's roles to be listed as a string" do
    user = ua_add_user(email: C_EMAIL)
    user.add_role :reader
    expect(user.role_list_stripped).to eq("Reader")
    user.add_role :curator
    expect(user.role_list_stripped).to eq("Curator, Reader")
    user.add_role :content_admin
    expect(user.role_list_stripped).to eq("Content Admin, Curator, Reader")
    ua_remove_user(C_EMAIL)
  end

  it "sets the reader role when a user is created" do
    user = ua_add_user(email: C_EMAIL)
    expect(user.role_list).to match_array(["Reader"])
    ua_remove_user(C_EMAIL)
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

  it "detects if removing the last administrator role in the system, one admin" do
    User.destroy_all
    user = ua_add_user(email: C_EMAIL, role: :sys_admin)
    expect(user.role_list_stripped).to eq("Reader, System Admin")
    expect(user.removing_last_admin?({:role_ids => [Role.to_id(:sys_admin)]})).to eq(false)
    expect(user.removing_last_admin?({:role_ids => [Role.to_id(:reader)]})).to eq(true)
  end

  it "detects if removing the last administrator role in the system, two admins" do
    User.destroy_all
    user = ua_add_user(email: "admin1@example.com", role: :sys_admin)
    user2 = ua_add_user(email: "admin2@example.com", role: :sys_admin)
    user3 = ua_add_user(email: "reader@example.com")

    expect(user.role_list_stripped).to eq("Reader, System Admin")
    expect(user2.role_list_stripped).to eq("Reader, System Admin")

    expect(user.removing_last_admin?({:role_ids => [Role.to_id(:sys_admin)]})).to eq(false)
    expect(user.removing_last_admin?({:role_ids => [Role.to_id(:reader)]})).to eq(false)
  end

  it "does not prohibit removing last user role, if not sys administrator" do
    User.destroy_all
    user = ua_add_user(email: C_EMAIL, role: :sys_admin)
    user2 = ua_add_user(email: "user@example.com")

    expect(user.role_list_stripped).to eq("Reader, System Admin")
    expect(user2.role_list_stripped).to eq("Reader")

    expect(user2.removing_last_admin?({:role_ids => [Role.to_id(:curator)]})).to eq(false)
  end

  it "assigns user a default name if none is provided" do
    user = ua_add_user(email: C_EMAIL)
    expect(user.name).to eq("Anonymous")
  end

  it "prohibits the user from changing the name to an empty string" do
    user = ua_add_user(email: C_EMAIL)
    user.name = ""
    user.save

    user = User.find_by(email: C_EMAIL)
    expect(user.name).to eq("Anonymous")
  end

  it "validates that password reset is forced when a new user is created (display name included && display name blank)" do
    user = User.create :email => "tst_user1@example.com", :password => "Changeme1#"
    expect(user.name).to eq("Anonymous")
    expect(user.need_change_password?).to eq(true)
    user2 = User.create :email => "tst_user2@example.com", :password => "Changeme1#", :name => "Test User"
    expect(user2.name).to eq("Test User")
    expect(user2.need_change_password?).to eq(true)
  end

  it "allows lock user" do
    user = User.create :email => "tst_user1@example.com", :password => "Changeme1#"
    expect(user.is_active?).to eq(true)
    user.lock
    expect(user.is_active?).to eq(false)
  end

  it "allows unlock user" do
    user = User.create :email => "tst_user1@example.com", :password => "Changeme1#"
    user.lock
    expect(user.is_active?).to eq(false)
    user.unlock
    expect(user.is_active?).to eq(true)
  end

  it "counts user by year" do
    User.destroy_all
    User.create :email => "fred@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "fred2@example.com", :password => "Changeme1#", current_sign_in_at: "2019-10-11 09:34:19.287445"
    User.create :email => "fred3@example.com", :password => "Changeme1#", current_sign_in_at: "2018-12-11 10:34:19.287445"
    expect(User.users_by_year).to eq({"2019"=>2, "2018"=>1})
  end

  it "counts user by year, current_sign_in nil" do
    User.destroy_all
    User.create :email => "fred@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "fred2@example.com", :password => "Changeme1#"
    User.create :email => "fred3@example.com", :password => "Changeme1#"
    expect(User.users_by_year).to eq({"2019"=>1})
  end

  it "counts users by year by week" do
    User.destroy_all
    User.create :email => "fred@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "fred2@example.com", :password => "Changeme1#", current_sign_in_at: "2019-10-11 09:34:19.287445"
    User.create :email => "fred3@example.com", :password => "Changeme1#", current_sign_in_at: "2018-12-11 10:34:19.287445"
    User.create :email => "fred4@example.com", :password => "Changeme1#", current_sign_in_at: "2018-11-11 08:34:19.287445"
    User.create :email => "fred5@example.com", :password => "Changeme1#", current_sign_in_at: "2018-10-11 09:34:19.287445"
    User.create :email => "fred6@example.com", :password => "Changeme1#", current_sign_in_at: "2017-12-11 10:34:19.287445"
    expect(User.users_by_year_by_week).to eq({"2017"=>{"50"=>1}, "2018"=>{"41"=>1, "45"=>1, "50"=>1}, "2019"=>{"40"=>1, "45"=>1}})
  end

  it "counts users by year by month" do
    User.destroy_all
    User.create :email => "fred@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "fred2@example.com", :password => "Changeme1#", current_sign_in_at: "2019-10-11 09:34:19.287445"
    User.create :email => "fred3@example.com", :password => "Changeme1#", current_sign_in_at: "2018-12-11 10:34:19.287445"
    User.create :email => "fred4@example.com", :password => "Changeme1#", current_sign_in_at: "2018-11-11 08:34:19.287445"
    User.create :email => "fred5@example.com", :password => "Changeme1#", current_sign_in_at: "2018-10-11 09:34:19.287445"
    User.create :email => "fred6@example.com", :password => "Changeme1#", current_sign_in_at: "2017-12-11 10:34:19.287445"
    expect(User.users_by_year_by_month).to eq({"2017"=>{"December"=>1}, "2018"=>{"October"=>1, "November"=>1, "December"=>1}, "2019"=>{"October"=>1, "November"=>1}})
  end

  it "counts users by year by month, current_sign_in nil" do
    User.destroy_all
    User.create :email => "fred@example.com", :password => "Changeme1#"
    User.create :email => "fred2@example.com", :password => "Changeme1#"
    User.create :email => "fred3@example.com", :password => "Changeme1#"
    User.create :email => "fred4@example.com", :password => "Changeme1#"
    User.create :email => "fred5@example.com", :password => "Changeme1#"
    User.create :email => "fred6@example.com", :password => "Changeme1#"
    expect(User.users_by_year_by_month).to eq({})
  end

  # it "counts users by current week" do
  #   User.destroy_all
  #   User.create :email => "fred@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
  #   User.create :email => "fred2@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-12 09:34:19.287445"
  #   User.create :email => "fred3@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-13 10:34:19.287445"
  #   User.create :email => "fred4@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
  #   User.create :email => "fred5@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-12 09:34:19.287445"
  #   User.create :email => "fred6@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-12 10:34:19.287445"
  #   User.create :email => "fred7@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-12 08:34:19.287445"
  #   User.create :email => "fred8@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-13 09:34:19.287445"
  #   User.create :email => "fred9@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 10:34:19.287445"
  #   expect(User.users_by_current_week).to eq({"Friday"=>0, "Monday"=>3, "Saturday"=>0, "Sunday"=>0, "Thursday"=>0, "Tuesday"=>4, "Wednesday"=>2})
  # end

  it "counts user by domain" do
    User.destroy_all
    User.create :email => "sam@example.com", :password => "Changeme1#"
    User.create :email => "dave@sanofi.com", :password => "Changeme1#"
    User.create :email => "kirsten@sanofi.com", :password => "Changeme1#"
    User.create :email => "clarisa@merck.com", :password => "Changeme1#"
    User.create :email => "adam@example.com", :password => "Changeme1#"
    User.create :email => "kevin@sanofi.com", :password => "Changeme1#"
    User.create :email => "aj@s-cubed.com", :password => "Changeme1#"
    expect(User.users_by_domain).to eq({"total"=>7, "example.com"=>2, "sanofi.com"=>3, "merck.com"=>1, "s-cubed.com"=>1})
  end

  it "counts user never logged in" do
    User.destroy_all
    User.create :email => "sam@example.com", :password => "Changeme1#"
    User.create :email => "dave@sanofi.com", :password => "Changeme1#"
    User.create :email => "kirsten@sanofi.com", :password => "Changeme1#"
    User.create :email => "clarisa@merck.com", :password => "Changeme1#"
    User.create :email => "adam@example.com", :password => "Changeme1#"
    User.create :email => "kevin@sanofi.com", :password => "Changeme1#"
    User.create :email => "aj@s-cubed.com", :password => "Changeme1#"
    expect(User.users_never_logged_in).to eq({"total"=>7})
  end

  it "counts user never logged in" do
    User.destroy_all
    User.create :email => "sam@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "dave@sanofi.com", :password => "Changeme1#"
    User.create :email => "kirsten@sanofi.com", :password => "Changeme1#"
    User.create :email => "clarisa@merck.com", :password => "Changeme1#"
    User.create :email => "adam@example.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    User.create :email => "kevin@sanofi.com", :password => "Changeme1#"
    User.create :email => "aj@s-cubed.com", :password => "Changeme1#", current_sign_in_at: "2019-11-11 08:34:19.287445"
    expect(User.users_never_logged_in).to eq({"total"=>4})
  end

end
