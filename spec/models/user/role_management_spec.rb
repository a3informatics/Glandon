require 'rails_helper'

describe "User::RoleManagememt" do

  C_EMAIL = "fred@example.com"

	include DataHelpers
  include PauseHelpers
  include UserAccountHelpers

	def sub_dir
    return "models/user/role_management"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_roles.ttl")
    AuditTrail.delete_all
  end

  after :all do
  end

  before :each do
    User.destroy_all
    @user = ua_add_user(email: C_EMAIL)
  end
  
  after :each do
    ua_remove_user(C_EMAIL)
  end

  it "add_role" do
    result = @user.add_role(:reader)
    expect(result).to eq(true)
    uas = User::Access.all
    expect(uas.count).to eq(1)
    expect(uas.first.user_id).to eq(@user.id)
    expect(uas.first.has_role_objects.count).to eq(1)
    expect(uas.first.has_role.first.name).to eq("reader")
    expect(uas.first.can_access_scope_objects.count).to eq(0)
  end

  it "add_role, invalid role" do
    expect{@user.add_role(:readerX)}.to raise_error(Errors::ApplicationLogicError, "Role not found when adding a user role: readerX.")
  end

  it "remove_role" do
    @user.add_role(:reader)
    @user.add_role(:term_reader)
    uas = User::Access.all
    expect(uas.count).to eq(1)
    expect(uas.first.user_id).to eq(@user.id)
    expect(uas.first.has_role_objects.count).to eq(2)
    expect(uas.first.has_role.sort_by{|x| x.name}.map{|x| x.name}).to eq(["reader", "term_reader"])
    expect(uas[0].can_access_scope_objects.count).to eq(0)
    @user.remove_role(:reader)
    expect(uas.count).to eq(1)
    expect(uas.first.user_id).to eq(@user.id)
    expect(uas.first.has_role_objects.count).to eq(1)
    expect(uas.first.has_role.sort_by{|x| x.name}.map{|x| x.name}).to eq(["term_reader"])
    expect(uas[0].can_access_scope_objects.count).to eq(0)    
  end

  it "has_role?" do
    result = @user.add_role(:reader)
    expect(@user.has_role?(:reader)).to eq(true)
    expect(@user.has_role?(:term_reader)).to eq(false)
    expect(@user.has_role?(:readerX)).to eq(false)
  end

  it "single_role?" do
    result = @user.add_role(:reader)
    expect(@user.single_role?).to eq(true)
    result = @user.add_role(:term_reader)
    expect(@user.single_role?).to eq(false)
  end

  it "allocated_roles" do
    result = @user.add_role(:reader)
    results = @user.allocated_roles
    check_file_actual_expected(results.sort_by{|x| x.name}.map{|x| x.to_h}, sub_dir, "allocated_roles_expected_1.yaml")
    result = @user.add_role(:term_reader)
    results = @user.allocated_roles
    check_file_actual_expected(results.sort_by{|x| x.name}.map{|x| x.to_h}, sub_dir, "allocated_roles_expected_2.yaml")
  end

  it "allocated_role_names" do
    result = @user.add_role(:reader)
    result = @user.add_role(:term_reader)
    results = @user.allocated_role_names
    expect(results).to match_array([:reader, :term_reader])
  end

  it "role_list" do
    results = @user.role_list
    expect(results).to match_array(["Reader"]) # User always has reader
    result = @user.add_role(:reader)
    results = @user.role_list
    expect(results).to match_array(["Reader"])
    result = @user.add_role(:term_reader)
    results = @user.role_list
    expect(results).to match_array(["Terminology Reader", "Reader"])
    result = @user.add_role(:curator)
    results = @user.role_list
    expect(results).to match_array(["Terminology Reader", "Curator", "Reader"])
  end

  it "role_list_stripped" do
    result = @user.add_role(:term_reader)
    result = @user.add_role(:curator)
    results = @user.role_list_stripped
    expect(results).to eq("Curator, Reader, Terminology Reader")
  end

end
