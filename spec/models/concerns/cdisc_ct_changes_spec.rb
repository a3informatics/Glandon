require 'rails_helper'

describe CdiscCtChanges do

  include PublicFileHelpers
	
  test_json = { a: "A string", b: "B String", c: { c1: "child 1", c2: "child 2" } }
  
  before :all do
    delete_all_public_files
  end

	after :all do
    delete_all_public_files
  end

  it "returns the directory path" do
		expect(CdiscCtChanges.dir_path()).to eq("public/test/")
	end

  it "saves a file" do
    CdiscCtChanges.save(CdiscCtChanges::C_ALL_CT, test_json)
    expect(CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)).to match(test_json)
  end

  it "saves a file with parameters" do
    CdiscCtChanges.save(CdiscCtChanges::C_TWO_CT, test_json, {new_version: "2", old_version: 1})
    expect(CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {new_version: "2", old_version: 1})).to match(test_json)
  end

  it "detects the existance of a file I" do
    expect(CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_CT)).to eq(true)
  end

  it "detects the existance of a file II" do
    expect(CdiscCtChanges.exists?(CdiscCtChanges::C_TWO_CT, {new_version: 2, old_version: "1"})).to eq(true)
  end

  it "reads a file" do
    expect(CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)).to match(test_json)
  end

  it "does not detect the existance of a missing file" do
    expect(CdiscCtChanges.exists?(CdiscCtChanges::C_ALL_SUB)).to eq(false)
  end

  it "detects a type error" do
    expect(CdiscCtChanges.exists?("BAD")).to eq(false)
  end

end