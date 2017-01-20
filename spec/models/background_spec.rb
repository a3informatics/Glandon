require 'rails_helper'

describe Background do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models"
  end

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
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    delete_all_public_files
  end

  it "compares CDISC terminology" do
    terms = []
    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
    job = Background.create
    job.compare_cdisc_term(terms)
    expected = read_yaml_file_to_hash_2(sub_dir, "background_cdisc_compare_two.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {new_version: 36, old_version: 35})
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology" do
    job = Background.create
    job.changes_cdisc_term()
    expected = read_yaml_file_to_hash_2(sub_dir, "background_cdisc_compare_all.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology submission values" do
    job = Background.create
    job.submission_changes_cdisc_term()
    expected = read_yaml_file_to_hash_2(sub_dir, "background_cdisc_submission_difference.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    expect(results).to eq(expected)
  end

  it "ad-hoc report" do
    copy_file_to_public_files("models", "ad_hoc_report_test_1_sparql.yaml", "test")
    job = Background.create
    report = AdHocReport.new
    report.sparql_file = "ad_hoc_report_test_1_sparql.yaml"
    report.results_file = "ad_hoc_report_test_1_results.yaml"
    job.ad_hoc_report(report)
    results = AdHocReportFiles.read("ad_hoc_report_test_1_results.yaml")
    #write_yaml_file(results, sub_dir, "background_ad_hoc_report.yaml")
    expected = read_yaml_file(sub_dir, "background_ad_hoc_report.yaml")
    expect(results).to eq(expected)
  end 

  it "determines the impact of CDISC terminology submission value changes"

  it "imports a cdisc terminology" do
    job = Background.create
    params = 
    { 
      :date => "2016-12-22", 
      :version => "99", 
      :files => ["xxx.ttl"], 
      :ns => "http://www.assero.co.uk/MDRThesaurus/CDISC/V99", 
      :cid => "TH-CDISC_CDISCTerminology", 
      :si => "SI-CDISC_CDISCTerminology-99" , 
      :rs => "RS-CDISC_CDISCTerminology-99" 
    }
    xslt_params = 
    { 
      :UseVersion => "99", 
      :Namespace => "'http://www.assero.co.uk/MDRThesaurus/CDISC/V99'", 
      :SI => "'SI-CDISC_CDISCTerminology-99'", 
      :RS => "'RS-CDISC_CDISCTerminology-99'", 
      :CID => "'TH-CDISC_CDISCTerminology'"
    }
    expect(Xslt).to receive(:execute).with("/Users/daveih/Documents/rails/Glandon/public/upload/cdiscImportManifest.xml", 
      "thesaurus/import/cdisc/cdiscTermImport.xsl", 
      xslt_params, 
      "CT_V99.ttl")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendFile).and_return(response)
    expect(response).to receive(:success?).and_return(true)
    job.import_cdisc_term(params)
  end

end