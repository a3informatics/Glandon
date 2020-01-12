require 'rails_helper'

describe "CDISC Library API" do
	
	include DataHelpers

  before :all do
    clear_triple_store
  end

  def sub_dir
    return "models/concerns/cdisc_library_api"
  end
    
  it "mdr products" do
    object = CDISCLibraryAPI.new
    result_1 = object.request("mdr/products")
    result_2 = object.request("/mdr/products")
    expect(result_1).to eq(result_2)
    check_file_actual_expected(result_1, sub_dir, "products_expected_1.yaml", equate_method: :hash_equal)
  end

  it "ct packages" do
    object = CDISCLibraryAPI.new
    result = object.ct_packages
    check_file_actual_expected(result, sub_dir, "ct_packages_expected_1.yaml", equate_method: :hash_equal)
	end

  it "ct packages, not enabled" do
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    object = CDISCLibraryAPI.new
    expect{object.ct_packages}.to raise_error(Errors::ApplicationLogicError, "The CDISC Library API is not enabled.")
  end

  it "ct packages by date" do
    object = CDISCLibraryAPI.new
    result = object.ct_packages_by_date('2019-03-29')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_1.yaml", equate_method: :hash_equal)
    result = object.ct_packages_by_date('2019-06-28')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_2.yaml", equate_method: :hash_equal)
    result = object.ct_packages_by_date('2019-09-27')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_3.yaml", equate_method: :hash_equal)
  end

  it "ct packages by date, no date found" do
    object = CDISCLibraryAPI.new
    expect{object.ct_packages_by_date("201-11-11")}.to raise_error(Errors::ApplicationLogicError, "No CT release found matching requested date '201-11-11'.")
  end

  it "ct packages by date, not enabled" do
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    object = CDISCLibraryAPI.new
    expect{object.ct_packages_by_date("")}.to raise_error(Errors::ApplicationLogicError, "The CDISC Library API is not enabled.")
  end

  it "api enabled" do
    object = CDISCLibraryAPI.new
    expect(object.enabled?).to eq(true)
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    expect(object.enabled?).to eq(false)
  end

end