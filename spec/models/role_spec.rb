require 'rails_helper'

describe Role do

	include DataHelpers
  include RoleFactory
  include SecureRandomHelpers

  def sub_dir
    return "models/role"
  end

  def setup
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

  describe "basic tests" do
    
    before :all do
      load_files(schema_files, [])
    end

    before :each do
      setup
    end

    after :each do
      @roles.each {|x| x.delete}
    end

    it "valid? I" do
      object = Role.new
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(3)
      expect(object.errors.full_messages.to_sentence).to eq("Uri can't be blank, Name is empty, and Display text is empty")
    end

    it "valid? II" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(2)
      expect(object.errors.full_messages.to_sentence).to eq("Name is empty and Display text is empty")
    end

    it "valid? III" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "aAA"
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Display text is empty")
    end

    it "valid? IV" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "aAA"
      object.display_text = "Well"
      result = object.valid?
      expect(result).to eq(true)
      expect(object.errors.full_messages.count).to eq(0)
    end

    it "valid? V" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "aAA"
      object.display_text = "Well"
      object.description = "§§§"
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Description contains invalid characters")
    end

    it "valid? VI" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "aAA"
      object.display_text = "Well"
      object.description = "eee"
      object.enabled = 1
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("Enabled is not included in the list")
    end

    it "valid? VI" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "aAA"
      object.display_text = "Well"
      object.description = "eee"
      object.system_admin = 1
      result = object.valid?
      expect(result).to eq(false)
      expect(object.errors.full_messages.count).to eq(1)
      expect(object.errors.full_messages.to_sentence).to eq("System admin is not included in the list")
    end

    it "valid? VII" do
      object = Role.new
      object.uri = Uri.new(uri: "http://www.example.com/A")
      object.name = "a_reader"
      object.display_text = "Well"
      object.description = "eee"
      object.system_admin = true
      result = object.valid?
      expect(result).to eq(true)
      expect(object.errors.full_messages.count).to eq(0)
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

end
