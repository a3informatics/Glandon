require 'rails_helper'

describe "Environment Variable" do
	
	include DataHelpers

  before :all do
    clear_triple_store
  end

  def sub_dir
    return "models/concerns/environment_variable"
  end
    
  it "read" do
    expect(EnvironmentVariable.read("organization_navbar")).to eq("TEST ")
	end

  it "exception if missing" do
    expect{EnvironmentVariable.read("organization_navbar_xxx")}.to raise_error(Errors::ApplicationLogicError, "Error reading environment variable 'organization_navbar_xxx'.")
  end

end