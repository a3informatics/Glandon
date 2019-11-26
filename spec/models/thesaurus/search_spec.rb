require 'rails_helper'

describe "Thesaurus::Search" do

  include DataHelpers

  C_TS_PI = "0"
  C_TS_PL = "1"
  C_TS_ID = "2"
  C_TS_NOT = "3"
  C_TS_PT = "4"
  C_TS_SYN = "5"
  C_TS_DEF = "6"
  C_TS_TAG = "7"

  def sub_dir
    return "models/thesaurus/search"
  end

  def standard_params
    params = 
    {
      :draw => "1", 
      :columns =>
      {
        C_TS_PI => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_PL => {:data  => "parentLabel", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_ID => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_NOT => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_PT => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_SYN => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        C_TS_DEF => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}},
        C_TS_TAG => {:data  => "tags", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
      }, 
      :order => { C_TS_PI => { :column => C_TS_PI, :dir => "asc" }}, 
      :start => "0", 
      :length => "15", 
      :search => { :value => "", :regex => "false" }, 
    }
    return params
  end

  def map_results(original_results)
  	results = {}
  	results[:count] = original_results[:count]
    results[:items] = []
    original_results[:items].each {|x| results[:items] << x.to_json}
    return results
  end

  describe "Instance Search" do

    before :all do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..61)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    end

    after :all do
    end

    it "checks for empty search" do
      params = standard_params
      expect(Thesaurus.empty_search?(params)).to eq(true)
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_PL][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_ID][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_NOT][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_PT][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_SYN][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_DEF][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:columns][C_TS_TAG][:search][:value] = "C66770"
      expect(Thesaurus.empty_search?(params)).to eq(false)
      params = standard_params
      params[:search][:value] = "nitrogen"
      expect(Thesaurus.empty_search?(params)).to eq(false)
    end

    it "allows a terminology to be searched, no search parameters" do
      params = standard_params
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_1.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, code list identifier" do
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C66770"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_2.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, code list label" do
      params = standard_params
      params[:columns][C_TS_PL][:search][:value] = "Units for Vital Signs Results"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_3b.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, item identifier" do
      params = standard_params
      params[:columns][C_TS_ID][:search][:value] = "C66770"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_3a.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, submission value" do
      params = standard_params
      params[:columns][C_TS_NOT][:search][:value] = "TEMP"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_4.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, preferred term"  do
      params = standard_params
      params[:columns][C_TS_PT][:search][:value] = "brain"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_5.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, synonym" do
      params = standard_params
      params[:columns][C_TS_SYN][:search][:value] = "Category"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_6.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, definition" do
      params = standard_params
      params[:columns][C_TS_DEF][:search][:value] = "cerebral"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_7.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, tag" do
      params = standard_params
      params[:columns][C_TS_TAG][:search][:value] = "SDTM"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16a.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, tag, lower case" do
      params = standard_params
      params[:columns][C_TS_TAG][:search][:value] = "sdtm"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16a.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, tag" do
      params = standard_params
      params[:columns][C_TS_TAG][:search][:value] = "SEND"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16b.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, tag" do
      params = standard_params
      params[:columns][C_TS_TAG][:search][:value] = "SENDX"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16c.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, tags" do
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C99076"
      params[:columns][C_TS_TAG][:search][:value] = "Protocol; SDTM"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V61#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16d.yaml", equate_method: :hash_equal)
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C99076"
      params[:columns][C_TS_TAG][:search][:value] = "SDTM; Protocol"
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_16d.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, overall" do
      params = standard_params
      params[:search][:value] = "nitrogen"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_8.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, combination column and overall" do
      params = standard_params
      params[:columns][C_TS_DEF][:search][:value] = "cerebral"
      params[:search][:value] = "Temporal"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_9.yaml", equate_method: :hash_equal)
    end  

    it "allows a terminology to be searched, combination columns" do
      params = standard_params
      params[:columns][C_TS_NOT][:search][:value] = "VST"
      params[:columns][C_TS_PT][:search][:value] = "Test"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_10.yaml", equate_method: :hash_equal)
    end  

    it "allows a terminology to be searched, overall, column order 2" do
      params = standard_params
      params[:search][:value] = "nitrogen"
      params[:order][C_TS_PI][:column] = "2"
      params[:order][C_TS_PI][:dir] = "desc"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_11.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, overall, case sensitivity" do
      params = standard_params
      params[:search][:value] = "nitrogen"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results1 = ct.search(params)
      params[:search][:value] = "NITROGEN"
      results2 = ct.search(params)
      check_file_actual_expected(results1, sub_dir, "search_15.yaml", equate_method: :hash_equal)
      check_file_actual_expected(results2, sub_dir, "search_15.yaml", equate_method: :hash_equal)
    end 

    it "allows a terminology to be searched, item identifier, case sensitivity" do
      params = standard_params
      params[:columns][C_TS_ID][:search][:value] = "c66770"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_3.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, submission value, case sensitivity" do
      params = standard_params
      params[:columns][C_TS_NOT][:search][:value] = "temp"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_4.yaml", equate_method: :hash_equal)
    end

    it "allows a terminology to be searched, combination column and overall, case sensitivity" do
      params = standard_params
      params[:columns][C_TS_DEF][:search][:value] = "cERebral"
      params[:search][:value] = "TEMPoral"
      ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
      results = ct.search(params)
      check_file_actual_expected(results, sub_dir, "search_9.yaml", equate_method: :hash_equal)
    end  

  end

  describe "Current Search" do

    before :each do
      IsoHelpers.clear_cache
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..50)
      load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
      @ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V46#TH"))
    end

    after :all do
    end

    it "allows the current terminologies to be searched, initial search, no parameters" do
      @ct.has_state.make_current
      params = standard_params
      results = Thesaurus.search_current(params)
      check_file_actual_expected(results, sub_dir, "search_1.yaml", equate_method: :hash_equal)
    end

    it "allows the current terminologies to be searched, several terminologies returning results" do
      @ct.has_state.make_current
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C66770"
      results = Thesaurus.search_current(params)
      check_file_actual_expected(results, sub_dir, "search_2.yaml", equate_method: :hash_equal)
    end

    it "allows the current terminologies to be searched, several terminologies returning results" do
      params = standard_params
      params[:columns][C_TS_PI][:search][:value] = "C66770"
      results = Thesaurus.search_current(params)
      check_file_actual_expected(results, sub_dir, "search_12.yaml", equate_method: :hash_equal)
    end

  end

end