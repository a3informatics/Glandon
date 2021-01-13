require 'rails_helper'

describe Role do

	include DataHelpers
  include RoleFactory
  include SecureRandomHelpers

  def sub_dir
    return "models/role"
  end
  
  before :each do
    load_files(schema_files, [])
    allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
    @roles = []
    @data = 
    [
      {name: "sysAdmin", description: "", display_text: "AAA", enabled: true, system_admin: false, combined_with: []},
      {name: "contentAdmin", description: "", display_text: "BBB", enabled: false, system_admin: false, combined_with: []},
      {name: "curator", description: "", display_text: "CCC", enabled: true, system_admin: false, combined_with: []},
      {name: "reader", description: "Reader role", display_text: "DDD", enabled: true, system_admin: false, combined_with: []},
      {name: "termReader", description: "", display_text: "EEE", enabled: true, system_admin: false, combined_with: []},
      {name: "termCurator", description: "", display_text: "FFF", enabled: true, system_admin: false, combined_with: []},
      {name: "communityReader", description: "", display_text: "GGG", enabled: true, system_admin: false, combined_with: []}
    ]
    @data.each {|x| @roles << create_role(x)}
  end

  it "all" do
    results = Role.all
    check_file_actual_expected(results.map{|x| x.to_h}, sub_dir, "all_expected_1.yaml")    
  end

	it "provides a list of roles" do
		results = Role.list
		check_file_actual_expected(results, sub_dir, "list_expected_1.yaml")
	end

	it "returns a role as a string" do
    expect(Role.to_display("sysAdmin")).to eq("AAA")
  end

	it "returns a role as a string for an invalid role" do
    expect(Role.to_display("notUsed")).to eq("")
  end

	it "provides a role description" do
    expect(Role.description("reader")).to eq("Reader role")
  end

	it "provides a role description, invalid role" do
    expect(Role.description("reader_x")).to eq("")
  end

	it "detects if role can be combined with sys admin, no" do
    expect(Role.with_sys_admin("reader")).to eq(false)
  end

	it "detects if role can be combined with sys admin, yes" do
    @roles[0].system_admin = true
    @roles[0].save
    @roles[1].combined_with_push(@roles[0].uri)
    @roles[1].save
    expect(Role.with_sys_admin("contentAdmin")).to eq(true)
  end

end
