require 'rails_helper'

describe "CDISC Library API" do
	
	include DataHelpers

  before :all do
    clear_triple_store
  end

  def sub_dir
    return "models/concerns/cdisc_library_api"
  end
    
  def dig_property(data, cl, cli, property)
    data.dig(:codelists).select{|x| x[:conceptId] == cl}.first[:terms].select{|x| x[:conceptId] == cli}.first[property]
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

  it "ct package, mismatched definitions, 2017-03-31, code list C65047, item C132367, SDTM v SEND" do
    object = CDISCLibraryAPI.new
    result_1 = object.ct_package("/mdr/ct/packages/sdtmct-2017-03-31")
    result_2 = object.ct_package("/mdr/ct/packages/sendct-2017-03-31")
    check_file_actual_expected(result_1, sub_dir, "ct_package_expected_2_1.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result_2, sub_dir, "ct_package_expected_2_2.yaml", equate_method: :hash_equal)
    def_1 = dig_property(result_1, "C65047", "C132367", :definition)
    def_2 = dig_property(result_2, "C65047", "C132367", :definition)
    puts colourize("+++++ SDTM Def: #{def_1} +++++", "blue")
    puts colourize("+++++ SEND Def: #{def_2} +++++", "blue")
    expect(def_1).to eq("A measurement of the folate hydrolase mRNA in a biological specimen.")
    expect(def_2).to eq("A measurement of the folate hydrolase mRNA gin a biological specimen.")
    expect(def_1).to_not eq(def_2)
    #expect(result_1).to hash_equal(result_2)
  end

  it "ct package, mismatched definitions, 2018-06-29, code list C128689, item C17998, SDTM v CDASH" do
    object = CDISCLibraryAPI.new
    result_1 = object.ct_package("/mdr/ct/packages/sdtmct-2018-06-29")
    result_2 = object.ct_package("/mdr/ct/packages/cdashct-2018-06-29")
    check_file_actual_expected(result_1, sub_dir, "ct_package_expected_3_1.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result_2, sub_dir, "ct_package_expected_3_2.yaml", equate_method: :hash_equal)
    def_1 = dig_property(result_1, "C128689", "C17998", :synonyms)
    def_2 = dig_property(result_2, "C128689", "C17998", :synonyms)
    puts colourize("+++++ SDTM Def: #{def_1} +++++", "blue")
    puts colourize("+++++ CDASH Def: #{def_2} +++++", "blue")
    expect(def_1).to eq(["U", "UNK", "Unknown"])
    expect(def_2).to eq(["U", "Unknown"])
    expect(def_1).to_not eq(def_2)
    #expect(result_1).to hash_equal(result_2)
  end

  it "ct package, mismatched definitions, 2018-12-21, code list C66770, item C44277, SDTM v SEND" do
    object = CDISCLibraryAPI.new
    result_1 = object.ct_package("/mdr/ct/packages/sdtmct-2018-12-21")
    result_2 = object.ct_package("/mdr/ct/packages/sendct-2018-12-21")
    check_file_actual_expected(result_1, sub_dir, "ct_package_expected_4_1.yaml", equate_method: :hash_equal)
    check_file_actual_expected(result_2, sub_dir, "ct_package_expected_4_2.yaml", equate_method: :hash_equal)
    def_1 = dig_property(result_1, "C66770", "C44277", :definition)
    def_2 = dig_property(result_2, "C66770", "C44277", :definition)
    puts colourize("+++++ SDTM Def: #{def_1} +++++", "blue")
    puts colourize("+++++ SEND Def: #{def_2} +++++", "blue")
    expect(def_1).to eq("The Fahrenheit temperature scale is named after the German physicist Gabriel Fahrenheit (1686-1736), who proposed it in 1724. In this scale, the freezing point of water is 32 degrees Fahrenheit and the boiling point is 212 degrees, placing the boiling and melting points of water 180 degrees apart. In this scale a degree Fahrenheit is 5/9ths of a Kelvin (or of a degree Celsius), and minus 40 degrees Fahrenheit is equal to minus 40 degrees Celsius. (NCI)")
    expect(def_2).to eq("\"The Fahrenheit temperature scale is named after the German physicist Gabriel Fahrenheit (1686-1736), who proposed it in 1724. In this scale, the freezing point of water is 32 degrees Fahrenheit and the boiling point is 212 degrees, placing the boiling and melting points of water 180 degrees apart. In this scale a degree Fahrenheit is 5/9ths of a Kelvin (or of a degree Celsius), and minus 40 degrees Fahrenheit is equal to minus 40 degrees Celsius. (NCI)\"")
    expect(def_1).to_not eq(def_2)
    #expect(result_1).to hash_equal(result_2)
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