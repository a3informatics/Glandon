require 'rails_helper'

describe Thesaurus do

  include DataHelpers

  def sub_dir
    return "models"
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
      :id => "TH-CDISC_CDISCTerminology", 
      :namespace => "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
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
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("CT_ACME_V1.ttl")
    load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V41.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a terminology to be searched, no search parameters" do
    params = standard_params
  	results = map_results(Thesaurus.search(params))
  #write_yaml_file(results, sub_dir, "thesaurus_search_1.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_1.yaml")
    expect(results).to eq(expected)
  end

  it "allows a terminology to be searched, code list identifier" do
    params = standard_params
    params[:columns]["0"][:search][:value] = "C66770"
  	results = map_results(Thesaurus.search(params))
  #write_yaml_file(results, sub_dir, "thesaurus_search_2.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_2.yaml")
    expect(results).to eq(expected)
  end

  it "allows a terminology to be searched, item identifier" do
    params = standard_params
    params[:columns]["1"][:search][:value] = "C66770"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_3.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_3.yaml")
    expect(results.to_json).to eq(expected)
  end

  it "allows a terminology to be searched, submission value" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "TEMP"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_4.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_4.yaml")
    expect(results.to_json).to eq(expected)
  end

  it "allows a terminology to be searched, preferred term"  do
    params = standard_params
    params[:columns]["3"][:search][:value] = "brain"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_5.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_5.yaml")
    expect(results.to_json).to eq(expected)
  end

  it "allows a terminology to be searched, synonym" do
    params = standard_params
    params[:columns]["4"][:search][:value] = "Category"
    results = map_results(Thesaurus.search(params))
  write_yaml_file(results, sub_dir, "thesaurus_search_6.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_6.yaml")
    expect(results).to eq(expected)
  end

  it "allows a terminology to be searched, definition" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cerebral"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_7.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_7.yaml")
    expect(results.to_json).to eq(expected)
  end 

  it "allows a terminology to be searched, overall" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_8.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_8.yaml")
    expect(results.to_json).to eq(expected)
  end 

  it "allows a terminology to be searched, combination column and overall" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cerebral"
    params[:search][:value] = "Temporal"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_9.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_9.yaml")
    expect(results.to_json).to eq(expected)
  end  

  it "allows a terminology to be searched, combination columns" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "VST"
    params[:columns]["3"][:search][:value] = "Test"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_10.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_10.yaml")
    expect(results.to_json).to eq(expected)
  end  

  it "allows a terminology to be searched, overall, column order 2" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    params[:order]["0"][:column] = "2"
    params[:order]["0"][:dir] = "desc"
    results = Thesaurus.search(params)
  #write_yaml_file(results.to_json, sub_dir, "thesaurus_search_11.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_11.yaml")
    expect(results.to_json).to eq(expected)
  end 

  it "allows the current terminologies to be searched, initial search, no parameters" do
    params = standard_params
    params[:id] = ""
    params[:namespace] = ""
    results = map_results(Thesaurus.search(params))
  write_yaml_file(results, sub_dir, "thesaurus_search_12.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_12.yaml")
    expect(results).to eq(expected)
  end

  it "allows the current terminologies to be searched, several terminologies returning results" do
    params = standard_params
    params[:id] = ""
    params[:namespace] = ""
    params[:search][:value] = "RACE"
    results = map_results(Thesaurus.search(params))
  write_yaml_file(results, sub_dir, "thesaurus_search_14.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_14.yaml")
    expect(results).to eq(expected)
  end

  it "allows a terminology to be searched, overall, case sensitivity" do
    params = standard_params
    params[:search][:value] = "nitrogen"
    results1 = Thesaurus.search(params)
    params[:search][:value] = "NITROGEN"
    results2 = Thesaurus.search(params)
  #write_yaml_file(results1.to_json, sub_dir, "thesaurus_search_15.yaml")
    expected = read_yaml_file(sub_dir, "thesaurus_search_15.yaml")
    expect(results1.to_json).to eq(expected)
    expect(results2.to_json).to eq(expected)
  end 

  it "allows a terminology to be searched, item identifier, case sensitivity" do
    params = standard_params
    params[:columns]["1"][:search][:value] = "c66770"
    results = Thesaurus.search(params)
    expected = read_yaml_file(sub_dir, "thesaurus_search_3.yaml")
    expect(results.to_json).to eq(expected)
  end

  it "allows a terminology to be searched, submission value, case sensitivity" do
    params = standard_params
    params[:columns]["2"][:search][:value] = "temp"
    results = Thesaurus.search(params)
    expected = read_yaml_file(sub_dir, "thesaurus_search_4.yaml")
    expect(results.to_json).to eq(expected)
  end

  it "allows a terminology to be searched, combination column and overall, case sensitivity" do
    params = standard_params
    params[:columns]["5"][:search][:value] = "cERebral"
    params[:search][:value] = "TEMPoral"
    results = Thesaurus.search(params)
    expected = read_yaml_file(sub_dir, "thesaurus_search_9.yaml")
    expect(results.to_json).to eq(expected)
  end  

end