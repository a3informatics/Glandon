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

  it "list CT" do
    object = CDISCLibraryAPI.new
    result = object.request(CDISCLibraryAPI::C_CT_PACKAGES_URL)
    puts colourize("+++++ CT List +++++\n#{result}\n+++++", "blue")
    check_file_actual_expected(result, sub_dir, "ct_list_expected_1.yaml", equate_method: :hash_equal)
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
    result = object.ct_packages_by_date('2014-09-26')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_4.yaml", equate_method: :hash_equal)
    result = object.ct_packages_by_date('2015-09-25')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_5.yaml", equate_method: :hash_equal)
    result = object.ct_packages_by_date('2015-12-18')
    check_file_actual_expected(result, sub_dir, "ct_package_by_date_expected_6.yaml", equate_method: :hash_equal)
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

  it "ct package" do
    object = CDISCLibraryAPI.new
    result = object.ct_package("/mdr/ct/packages/protocolct-2019-03-29")
    check_file_actual_expected(result, sub_dir, "ct_package_expected_1.yaml", equate_method: :hash_equal)
  end

  it "ct package tags" do
    object = CDISCLibraryAPI.new
    result = object.ct_package("/mdr/ct/packages/protocolct-2019-03-29")
    expect(object.ct_tags(result[:label])).to eq(["Protocol"])
  end

  it "ct package, not enabled" do
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    object = CDISCLibraryAPI.new
    expect{object.ct_package("/mdr/ct/packages/protocolct-2019-03-29")}.to raise_error(Errors::ApplicationLogicError, "The CDISC Library API is not enabled.")
  end

  it "api enabled" do
    object = CDISCLibraryAPI.new
    expect(object.enabled?).to eq(true)
    expect(EnvironmentVariable).to receive(:read).and_return("false")
    expect(object.enabled?).to eq(false)
    expect(EnvironmentVariable).to receive(:read).and_return(StandardError.new("Error"))
    expect{object.enabled?}.to raise_error(Errors::ApplicationLogicError, "Error detected determining if CDISC Library API enabled.")
  end

end