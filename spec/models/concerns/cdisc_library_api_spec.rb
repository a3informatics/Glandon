require 'rails_helper'

describe "CDISC Library API" do
	
	include DataHelpers

  before :all do
    clear_triple_store
  end

  def sub_dir
    return "models/concerns/cdisc_library_api"
  end
    
  it "sends ct package list request" do
    object = CDISCLibraryAPI.new
    result = object.ct_packages
    check_file_actual_expected(result, sub_dir, "ct_packages_expected_1.yaml", equate_method: :hash_equal)
	end

  it "sends ct package list request, not enabled" do
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    object = CDISCLibraryAPI.new
    expect{object.ct_packages}.to raise_error(Errors::ApplicationLogicError, "The CDISC Library API is not enabled.")
  end

  it "api enabled" do
    object = CDISCLibraryAPI.new
    expect(object.enabled?).to eq(true)
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    expect(object.enabled?).to eq(false)
  end

end