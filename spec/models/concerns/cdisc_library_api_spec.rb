require 'rails_helper'

describe "CDISC Library API" do
	
	include DataHelpers
  include CdiscCtHelpers

  def sub_dir
    return "models/concerns/cdisc_library_api"
  end
    
  def dig_property(data, cl, cli, property)
    data.dig(:codelists).select{|x| x[:conceptId] == cl}.first[:terms].select{|x| x[:conceptId] == cli}.first[property]
  end

  describe "Basic Tests" do

    before :all do
      load_files(schema_files, [])
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
      puts colourize("CT List\n#{result}\n+++++", "blue")
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

    it "ct package, error" do
      object = CDISCLibraryAPI.new
      expect{object.ct_package("/mdr/ct/packages/protocolct-2019-03-XX")}.to raise_error(Errors::NotFoundError, "Request to CDISC API https://library.cdisc.org/api/mdr/ct/packages/protocolct-2019-03-XX failed, HTTP error: 404.")
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

  describe "Data Mismatch Tests" do

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
      load_cdisc_term_versions(CdiscCtHelpers.version_range)
    end

    it "ct package, mismatched data" do
      date = "2017-03-31"
      version = "51"
      code_list = "C65047"
      code_list_item = "C132367"
      puts colourize("\nChecking mismatched definition, SDTM v SEND, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      result_2 = object.ct_package("/mdr/ct/packages/sendct-#{date}")
      check_file_actual_expected(result_1, sub_dir, "ct_package_expected_2017-03-31_1.yaml", equate_method: :hash_equal)
      check_file_actual_expected(result_2, sub_dir, "ct_package_expected_2017-03-31_2.yaml", equate_method: :hash_equal)
      def_1 = dig_property(result_1, "C65047", "C132367", :definition)
      def_2 = dig_property(result_2, "C65047", "C132367", :definition)
      puts colourize("SDTM: '#{def_1}'", "blue")
      puts colourize("SEND: '#{def_2}'", "blue")
      expect(def_1).to eq("A measurement of the folate hydrolase mRNA in a biological specimen.")
      expect(def_2).to eq("A measurement of the folate hydrolase mRNA gin a biological specimen.")
      expect(def_1).to_not eq(def_2)
      #expect(result_1).to hash_equal(result_2)
    end

    it "ct package, mismatched data" do
      date = "2017-09-29"
      version = "53"
      code_list = "C66736"
      code_list_item = "C139174"
      puts colourize("\nChecking mismatched definition, SDTM v Protocol, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      result_2 = object.ct_package("/mdr/ct/packages/protocolct-#{date}")
      check_file_actual_expected(result_1, sub_dir, "ct_package_expected_2017-09-29_1.yaml", equate_method: :hash_equal)
      check_file_actual_expected(result_2, sub_dir, "ct_package_expected_2017-09-29_2.yaml", equate_method: :hash_equal)
      def_1 = dig_property(result_1, "C66736", "C139174", :definition)
      def_2 = dig_property(result_2, "C66736", "C139174", :definition)
      puts colourize("SDTM: '#{def_1}'", "blue")
      puts colourize("Protocol: '#{def_2}'", "blue")
      expect(def_1).to eq("An intervention of a device product is being evaluated to determine the feasibility of the product or to test a prototype device and not health outcomes. Such studies are conducted to confirm the design and operating specifications of a device before beginning a full clinical trial. (ClinicalTrials.gov)")
      expect(def_2).to eq("An intervention of a device product is being evaluated to determine the feasibility of the product or to test a prototype device and not health outcomes. Such studies are conducted to confirm the design and operating specifications of a device before beginning a full clinical trial. (clinicaltrials.gov)")
      expect(def_1).to_not eq(def_2)
      #expect(result_1).to hash_equal(result_2)
    end

    it "ct package, mismatched data" do
      date = "2017-12-22"
      version = "54"
      code_list = "C128689"
      code_list_item = "C17998"
      puts colourize("\nChecking mismatched definition, SDTM v Protocol, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      result_2 = object.ct_package("/mdr/ct/packages/protocolct-2017-09-29")
      check_file_actual_expected(result_1, sub_dir, "ct_package_expected_#{date}_1.yaml", equate_method: :hash_equal)
      check_file_actual_expected(result_2, sub_dir, "ct_package_expected_#{date}_2.yaml", equate_method: :hash_equal)
      def_1 = dig_property(result_1, "C66736", "C139174", :definition)
      def_2 = dig_property(result_2, "C66736", "C139174", :definition)
      puts colourize("SDTM: '#{def_1}'", "blue")
      puts colourize("Protocol: '#{def_2}'", "blue")
      expect(def_1).to eq("An intervention of a device product is being evaluated to determine the feasibility of the product or to test a prototype device and not health outcomes. Such studies are conducted to confirm the design and operating specifications of a device before beginning a full clinical trial. (ClinicalTrials.gov)")
      expect(def_2).to eq("An intervention of a device product is being evaluated to determine the feasibility of the product or to test a prototype device and not health outcomes. Such studies are conducted to confirm the design and operating specifications of a device before beginning a full clinical trial. (clinicaltrials.gov)")
      expect(def_1).to_not eq(def_2)
      #expect(result_1).to hash_equal(result_2)
    end

    it "ct package, mismatched data" do
      date = "2018-03-30"
      version = "55"
      code_list = "C120525"
      code_list_item = "C147273"
      puts colourize("\nChecking mismatched preferred term, SDTM, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      def_1 = dig_property(result_1, code_list, code_list_item, :preferredTerm)
      ct = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
      ref = ct.find_by_identifiers([code_list, code_list_item])
      tc = Thesaurus::UnmanagedConcept.find(ref[code_list_item])
      tc.preferred_term_objects
      def_2 = tc.preferred_term.label
      puts colourize("API: '#{def_1}'", "blue")
      puts colourize("MDR: '#{def_2}'", "blue")
      expect(def_1).to_not eq(def_2)
    end

    it "ct package, mismatched data" do
      date = "2018-03-30"
      version = "55"
      code_list = "C120526"
      code_list_item = "C147273"
      puts colourize("\nChecking mismatched preferred term, SDTM, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      def_1 = dig_property(result_1, code_list, code_list_item, :preferredTerm)
      ct = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
      ref = ct.find_by_identifiers([code_list, code_list_item])
      tc = Thesaurus::UnmanagedConcept.find(ref[code_list_item])
      tc.preferred_term_objects
      def_2 = tc.preferred_term.label
      puts colourize("API: '#{def_1}'", "blue")
      puts colourize("MDR: '#{def_2}'", "blue")
      expect(def_1).to_not eq(def_2)
    end

    it "ct package, mismatched data" do
      date = "2018-03-30"
      version = "55"
      code_list = "C147069"
      code_list_item = "C147144"
      puts colourize("\nChecking mismatched definition, Protocol, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/protocolct-#{date}")
      def_1 = dig_property(result_1, code_list, code_list_item, :definition)
      ct = Thesaurus.find_full(Uri.new(uri: "http://www.cdisc.org/CT/V#{version}#TH"))
      ref = ct.find_by_identifiers([code_list, code_list_item])
      tc = Thesaurus::UnmanagedConcept.find(ref[code_list_item])
      def_2 = tc.definition
      puts colourize("API: '#{def_1}'", "blue")
      puts colourize("MDR: '#{def_2}'", "blue")
      expect(def_1).to_not eq(def_2)
    end

    it "ct package, mismatched data" do
      date = "2018-06-29"
      version = "56"
      code_list = "C128689"
      code_list_item = "C17998"
      puts colourize("\nChecking mismatched synonym, SDTM v CDASH, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      result_2 = object.ct_package("/mdr/ct/packages/cdashct-#{date}")
      check_file_actual_expected(result_1, sub_dir, "ct_package_expected_#{date}_1.yaml", equate_method: :hash_equal)
      check_file_actual_expected(result_2, sub_dir, "ct_package_expected_#{date}_2.yaml", equate_method: :hash_equal)
      def_1 = dig_property(result_1, "C128689", "C17998", :synonyms)
      def_2 = dig_property(result_2, "C128689", "C17998", :synonyms)
      puts colourize("SDTM: '#{def_1}'", "blue")
      puts colourize("CDASH: '#{def_2}'", "blue")
      expect(def_1).to eq(["U", "UNK", "Unknown"])
      expect(def_2).to eq(["U", "Unknown"])
      expect(def_1).to_not eq(def_2)
      #expect(result_1).to hash_equal(result_2)
    end

    it "ct package, mismatched data" do
      date = "2018-12-21"
      version = "58"
      code_list = "C66770"
      code_list_item = "C44277"
      puts colourize("\nChecking mismatched definition (one example), SDTM v SEND, V#{version}, #{date}, code list #{code_list}, item #{code_list_item}", "green")
      object = CDISCLibraryAPI.new
      result_1 = object.ct_package("/mdr/ct/packages/sdtmct-#{date}")
      result_2 = object.ct_package("/mdr/ct/packages/sendct-#{date}")
      check_file_actual_expected(result_1, sub_dir, "ct_package_expected_#{date}_1.yaml", equate_method: :hash_equal)
      check_file_actual_expected(result_2, sub_dir, "ct_package_expected_#{date}_2.yaml", equate_method: :hash_equal)
      def_1 = dig_property(result_1, "C66770", "C44277", :definition)
      def_2 = dig_property(result_2, "C66770", "C44277", :definition)
      puts colourize("SDTM: '#{def_1}'", "blue")
      puts colourize("SEND: '#{def_2}'", "blue")
      expect(def_1).to eq("The Fahrenheit temperature scale is named after the German physicist Gabriel Fahrenheit (1686-1736), who proposed it in 1724. In this scale, the freezing point of water is 32 degrees Fahrenheit and the boiling point is 212 degrees, placing the boiling and melting points of water 180 degrees apart. In this scale a degree Fahrenheit is 5/9ths of a Kelvin (or of a degree Celsius), and minus 40 degrees Fahrenheit is equal to minus 40 degrees Celsius. (NCI)")
      expect(def_2).to eq("\"The Fahrenheit temperature scale is named after the German physicist Gabriel Fahrenheit (1686-1736), who proposed it in 1724. In this scale, the freezing point of water is 32 degrees Fahrenheit and the boiling point is 212 degrees, placing the boiling and melting points of water 180 degrees apart. In this scale a degree Fahrenheit is 5/9ths of a Kelvin (or of a degree Celsius), and minus 40 degrees Fahrenheit is equal to minus 40 degrees Celsius. (NCI)\"")
      expect(def_1).to_not eq(def_2)
      #expect(result_1).to hash_equal(result_2)
    end

  end    

end