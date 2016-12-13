require 'rails_helper'

describe Background do

  include DataHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCTerm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V34.ttl")
    load_test_file_into_triple_store("CT_V35.ttl")
    load_test_file_into_triple_store("CT_V36.ttl")
    #load_test_file_into_triple_store("CT_V42.ttl")
    #load_test_file_into_triple_store("CT_V43.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
  end

  it "compares CDISC terminology" do
    terms = []
    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    job = Background.create
    job.compare_cdisc_term(terms)
    expected = read_yaml_file_to_hash("background_cdisc_compare_two.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {new_version: 36, old_version: 35})
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology" do
    job = Background.create
    job.changes_cdisc_term()
    expected = read_yaml_file_to_hash("background_cdisc_compare_all.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology submission values" do
    job = Background.create
    job.submission_changes_cdisc_term()
    expected = read_yaml_file_to_hash("background_cdisc_submission_difference.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology submission values" #do
    #job = Background.create
    #params = {}
    #params[:old_id] = "TH-CDISC_CDISCTerminology"
    #params[:old_ns] = "http://www.assero.co.uk/MDRThesaurus/CDISC/V42"
    #params[:new_id] = "TH-CDISC_CDISCTerminology" 
    #params[:new_ns] = "http://www.assero.co.uk/MDRThesaurus/CDISC/V43"
    #job.submission_changes_impact(params)
    #expected = read_yaml_file_to_hash("background_cdisc_submission_impact.yaml")
    #results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT_IMPACT)
    #expect(results).to eq([])
  #end

end