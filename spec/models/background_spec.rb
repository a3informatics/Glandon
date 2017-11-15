require 'rails_helper'

describe Background do

  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/background"
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
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
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
    expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_compare_two_expected.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {new_version: 36, old_version: 35})
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology" do
    job = Background.create
    job.changes_cdisc_term()
    expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_compare_all_expected.yaml")
    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    expect(results).to eq(expected)
  end

  it "compares all CDISC terminology submission values" do
    job = Background.create
    job.submission_changes_cdisc_term()
    expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_submission_difference_expected.yaml")
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
  #write_yaml_file(results, sub_dir, "ad_hoc_report_expected.yaml")
    expected = read_yaml_file(sub_dir, "ad_hoc_report_expected.yaml")
    expect(results).to eq(expected)
  end 

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

  it "imports sdtm model, 3.1.2" do
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = {version: "1", version_label: "Initial Version", date: "2017-10-18", files: ["#{filename}"]}
  	job.import_cdisc_sdtm_model(params)
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "imports sdtm ig, 3.1.2" do
  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
  	params = {version: "1", version_label: "Initial Version", date: "2017-10-18", files: ["#{filename}"], model_uri: model.uri.to_s}
  	job.import_cdisc_sdtm_ig(params)
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "imports sdtm model, 3.1.3" do
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-1-3-excel.xlsx")
  	params = {version: "2", version_label: "Second Version", date: "2017-10-18", files: ["#{filename}"]}
  	job.import_cdisc_sdtm_model(params)
  #puts job.status
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "imports sdtm ig, 3.1.3" do
  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-1-3-excel.xlsx")
  	params = {version: "2", version_label: "Second Version", date: "2017-10-18", files: ["#{filename}"], model_uri: model.uri.to_s}
  	job.import_cdisc_sdtm_ig(params)
  #puts job.status
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "imports sdtm model, 3.2" do
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
  	params = {version: "3", version_label: "Third Version", date: "2017-10-18", files: ["#{filename}"]}
  	job.import_cdisc_sdtm_model(params)
  #puts job.status
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "imports sdtm ig, 3.2" do
  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
  	job = Background.create
  	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
  	params = {version: "3", version_label: "Initial Version", date: "2017-10-18", files: ["#{filename}"], model_uri: model.uri.to_s}
  	job.import_cdisc_sdtm_ig(params)
  #puts job.status
  	expect(job.status).to eq("Complete. Successful import.")
  end

  it "import cdisc term changes, June 2017" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
		load_test_file_into_triple_store("CT_V48.ttl")
    load_test_file_into_triple_store("CT_V49.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    #delete_all_public_files
  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
  	job = Background.create
  	filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2017-06-30.xlsx")
  	params = {files: ["#{filename}"], term_uri: ct.uri.to_s}
  	job.import_cdisc_term_changes(params)
  	expect(job.status).to eq("Complete. Successful import.")  
  	results = read_public_text_file("test", "term_changes_49.txt")
  #write_text_file_2(results, sub_dir, "cdisc_term_changes_expected_1.txt")
  	expected = read_text_file_2(sub_dir, "cdisc_term_changes_expected_1.txt")
  	expect(results).to eq(expected)	
  #delete_all_public_files
  end

  it "import cdisc term changes, March 2016" do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
		load_test_file_into_triple_store("CT_V43.ttl")
		load_test_file_into_triple_store("CT_V44.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    #delete_all_public_files
  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V44")
  	job = Background.create
  	filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2016-03-25.xlsx")
  	params = {files: ["#{filename}"], term_uri: ct.uri.to_s}
  	job.import_cdisc_term_changes(params)
  	expect(job.status).to eq("Complete. Successful import.")  
  	results = read_public_text_file("test", "term_changes_44.txt")
  #write_text_file_2(results, sub_dir, "cdisc_term_changes_expected_2.txt")
  	expected = read_text_file_2(sub_dir, "cdisc_term_changes_expected_2.txt")
  	expect(results).to eq(expected)	
  #delete_all_public_files
  end

end