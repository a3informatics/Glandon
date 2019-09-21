require 'rails_helper'

describe Thesaurus::Search do

  include DataHelpers

  def sub_dir
    return "models/thesaurus/search"
  end

  def standard_params
    params = 
    {
      :draw => "1", 
      :columns =>
      {
        "0" => {:data  => "parentIdentifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "1" => {:data  => "identifier", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "2" => {:data  => "notation", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "3" => {:data  => "preferredTerm", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "4" => {:data  => "synonym", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false" }}, 
        "5" => {:data  => "definition", :name => "", :searchable => "true", :orderable => "true", :search => { :value => "", :regex => "false"}}
      }, 
      :order => { "0" => { :column => "0", :dir => "asc" }}, 
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

  before :all do
    IsoHelpers.clear_cache
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..50)
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    ct.has_state.make_current
  end

  after :all do
  end

  it "checks for empty search" do
    params = standard_params
    expect(Thesaurus.empty_search?(params)).to eq(true)
    params = standard_params
    params[:columns]["0"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:columns]["1"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:columns]["2"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:columns]["3"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:columns]["4"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:columns]["5"][:search][:value] = "C66770"
    expect(Thesaurus.empty_search?(params)).to eq(false)
    params = standard_params
    params[:search][:value] = "nitrogen"
    expect(Thesaurus.empty_search?(params)).to eq(false)
  end

  it "allows a terminology to be searched, no search parameters" do
    params = standard_params
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_1.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, code list identifier" do
    params = standard_params
    params[:columns]["0"][:search][:value] = "C66770"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_2.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, item identifier" do
    params = standard_params
    params[:columns]["1"][:search][:value] = "C66770"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_3.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, submission value" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "TEMP"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_4.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, preferred term"  do
    params = standard_params
    params[:columns]["3"][:search][:value] = "brain"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_5.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, synonym" do
    params = standard_params
    params[:columns]["4"][:search][:value] = "Category"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_6.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, definition" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cerebral"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_7.yaml", equate_method: :hash_equal)
  end 

  it "allows a terminology to be searched, overall" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_8.yaml", equate_method: :hash_equal)
  end 

  it "allows a terminology to be searched, combination column and overall" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cerebral"
    params[:search][:value] = "Temporal"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_9.yaml", equate_method: :hash_equal)
  end  

  it "allows a terminology to be searched, combination columns" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "VST"
    params[:columns]["3"][:search][:value] = "Test"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_10.yaml", equate_method: :hash_equal)
  end  

  it "allows a terminology to be searched, overall, column order 2" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    params[:order]["0"][:column] = "2"
    params[:order]["0"][:dir] = "desc"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_11.yaml", equate_method: :hash_equal)
  end 

  it "allows the current terminologies to be searched, initial search, no parameters" do
    params = standard_params
    results = Thesaurus.search_current(params)
    check_file_actual_expected(results, sub_dir, "search_1.yaml", equate_method: :hash_equal)
  end

  it "allows the current terminologies to be searched, several terminologies returning results" do
    params = standard_params
    params[:columns]["0"][:search][:value] = "C66770"
    results = Thesaurus.search_current(params)
    check_file_actual_expected(results, sub_dir, "search_2.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, overall, case sensitivity" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results1 = ct.search(params)
    params[:search][:value] = "NITROGEN"
    results2 = ct.search(params)
    check_file_actual_expected(results1, sub_dir, "search_15.yaml", equate_method: :hash_equal)
    check_file_actual_expected(results2, sub_dir, "search_15.yaml", equate_method: :hash_equal)
  end 

  it "allows a terminology to be searched, item identifier, case sensitivity" do
    params = standard_params
    params[:columns]["1"][:search][:value] = "c66770"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_3.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, submission value, case sensitivity" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "temp"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_4.yaml", equate_method: :hash_equal)
  end

  it "allows a terminology to be searched, combination column and overall, case sensitivity" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cERebral"
    params[:search][:value] = "TEMPoral"
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V45#TH"))
    results = ct.search(params)
    check_file_actual_expected(results, sub_dir, "search_9.yaml", equate_method: :hash_equal)
  end  

end