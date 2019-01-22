require 'rails_helper'

describe Background do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/background"
  end

  def check_ttl_local(actual, expected)
    copy_file_from_public_files("test", actual, sub_dir)
    check_ttl(actual, expected)
    delete_data_file(sub_dir, actual)
  end

  def save_results(actual, expected)
    results = read_public_text_file("test", actual)
    write_text_file_2(results, sub_dir, expected)
  end

  def check_model(results)
    model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V#{results[:version]}")
    expect(model.class_refs.count).to eq(results[:class_refs])
    expect(model.children.count).to eq(results[:variables][:count])
    results[:variables][:content].each do |c|
      variable = model.children.find { |x| x.name == c[:name]}
      expect(variable.nil?).to eq(false)
      c[:properties].each do |v|
        v.each do |k, i|
          expect(variable.instance_variable_get("@#{k}")).to eq(i)
        end
      end
      c[:references].each do |v|
        v.each do |k, i|
          expect(variable.instance_variable_get("@#{k}").label).to eq(i)
        end
      end
    end
  end

  def check_ig(results)
    ig = SdtmIg.find("IG-CDISC_SDTMIG", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V#{results[:version]}")
    expect(ig.domain_refs.count).to eq(results[:domain_refs])
    results[:domains].each do |d|
      domain = SdtmIgDomain.find("IG-CDISC_SDTMIG#{d[:domain]}", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V#{results[:version]}")
      expect(domain.children.count).to eq(d[:variables][:count])
        d[:variables][:content].each do |c|
          variable = domain.children.find { |x| x.name == c[:name]}
          expect(variable.nil?).to eq(false)
          c[:properties].each do |v|
            v.each do |k, i|
              expect(variable.instance_variable_get("@#{k}")).to eq(i)
            end
          c[:references].each do |v|
            v.each do |k, i|
              expect(variable.instance_variable_get("@#{k}").label).to eq(i)
            end
          end
        end
      end
    end
  end

  describe "Background Jobs" do

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

	  after :all do
	    delete_all_public_files
	  end

	  it "compares CDISC terminology" do
	  	terms = []
	    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V35")
	    terms << CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V36")
	    job = Background.create
	    job.compare_cdisc_term(terms)
	    results = CdiscCtChanges.read(CdiscCtChanges::C_TWO_CT, {new_version: 36, old_version: 35})
    #Xwrite_yaml_file(results, sub_dir, "cdisc_compare_two_expected.yaml")
      expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_compare_two_expected.yaml")
	    expect(results).to eq(expected)
	  end

	  it "compares all CDISC terminology" do
	    job = Background.create
	    job.changes_cdisc_term()
	    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_CT)
    #Xwrite_yaml_file(results, sub_dir, "cdisc_compare_all_expected.yaml")
      expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_compare_all_expected.yaml")
	    expect(results).to eq(expected)
	  end

	  it "compares all CDISC terminology submission values" do
	    job = Background.create
	    job.submission_changes_cdisc_term()
	    expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_submission_difference_expected.yaml")
	    results = CdiscCtChanges.read(CdiscCtChanges::C_ALL_SUB)
    #Xwrite_yaml_file(results, sub_dir, "cdisc_submission_difference_expected.yaml")
      expected = read_yaml_file_to_hash_2(sub_dir, "cdisc_submission_difference_expected.yaml")
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

	  it "imports sdtm model, 1.2" do
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
	  	params = {version: "1", version_label: "1.2", date: "2008-11-12", files: ["#{filename}"]}
	  	job.import_cdisc_sdtm_model(params)
    #save_results("SDTM_Model_1-2.txt", "SDTM_Model_V1.txt")
      check_ttl_local("SDTM_Model_1-2.txt", "SDTM_Model_V1.txt")
      expect(job.status).to eq("Complete. Successful import.")
      model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
      check = read_yaml_file(sub_dir, "sdtm_model_v1_check.yaml")
      check_model(check)
	  end

	  it "imports sdtm ig, 3.1.2" do
	  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V1")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
	  	params = {version: "1", version_label: "3.1.2", date: "2008-11-12", files: ["#{filename}"], model_uri: model.uri.to_s}
	  	job.import_cdisc_sdtm_ig(params)
    #save_results("SDTM_IG_3-1-2.txt", "SDTM_IG_V1.txt")
      check_ttl_local("SDTM_IG_3-1-2.txt", "SDTM_IG_V1.txt")
      expect(job.status).to eq("Complete. Successful import.")
      check = read_yaml_file(sub_dir, "sdtm_ig_v1_check.yaml")
      check_ig(check)
	  end

	  it "imports sdtm model, 1.3" do
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-1-3-excel.xlsx")
	  	params = {version: "2", version_label: "1.3", date: "2012-07-16", files: ["#{filename}"]}
	  	job.import_cdisc_sdtm_model(params)
    #save_results("SDTM_Model_1-3.txt", "SDTM_Model_V2.txt")
      check_ttl_local("SDTM_Model_1-3.txt", "SDTM_Model_V2.txt")
      expect(job.status).to eq("Complete. Successful import.")
      check = read_yaml_file(sub_dir, "sdtm_model_v2_check.yaml")
      check_model(check)
	  end

	  it "imports sdtm ig, 3.1.3" do
	  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V2")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-1-3-excel.xlsx")
	  	params = {version: "2", version_label: "3.1.3", date: "2012-07-16", files: ["#{filename}"], model_uri: model.uri.to_s}
	  	job.import_cdisc_sdtm_ig(params)
    #save_results("SDTM_IG_3-1-3.txt", "SDTM_IG_V2.txt")
      check_ttl_local("SDTM_IG_3-1-3.txt", "SDTM_IG_V2.txt")
      expect(job.status).to eq("Complete. Successful import.")
      check = read_yaml_file(sub_dir, "sdtm_ig_v2_check.yaml")
      check_ig(check)
	  end

	  it "imports sdtm model, 1.4" do
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
	  	params = {version: "3", version_label: "1.4", date: "2013-11-26", files: ["#{filename}"]}
	  	job.import_cdisc_sdtm_model(params)
    #save_results("SDTM_Model_1-4.txt", "SDTM_Model_V3.txt")
      check_ttl_local("SDTM_Model_1-4.txt", "SDTM_Model_V3.txt")
      expect(job.status).to eq("Complete. Successful import.")
      check = read_yaml_file(sub_dir, "sdtm_model_v3_check.yaml")
      check_model(check)
	  end

	  it "imports sdtm ig, 3.2" do
	  	model = SdtmModel.find("M-CDISC_SDTMMODEL", "http://www.assero.co.uk/MDRSdtmM/CDISC/V3")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "sdtm-3-2-excel.xlsx")
	  	params = {version: "3", version_label: "3.2", date: "2013-11-26", files: ["#{filename}"], model_uri: model.uri.to_s}
	  	job.import_cdisc_sdtm_ig(params)
    #save_results("SDTM_IG_3-2.txt", "SDTM_IG_V3.txt")
      check_ttl_local("SDTM_IG_3-2.txt", "SDTM_IG_V3.txt")
      expect(job.status).to eq("Complete. Successful import.")
      check = read_yaml_file(sub_dir, "sdtm_ig_v3_check.yaml")
      check_ig(check)
	  end

	end

  describe "CDISC Term Change Instructions" do

  	before :each do
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
			clear_iso_concept_object
	    clear_iso_namespace_object
	    clear_iso_registration_authority_object
	    clear_iso_registration_state_object
	  end

	  after :each do
      delete_all_public_files
    end

    it "import cdisc term changes, March 2016" do
	  	load_test_file_into_triple_store("CT_V43.ttl")
			load_test_file_into_triple_store("CT_V44.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V44")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2016-03-25.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
		#puts job.status
	  	expect(job.status).to eq("Complete. Successful import.")  
	  #results = read_public_text_file("test", "CDISC_CT_Instructions_V44.txt")
	  #write_text_file_2(results, sub_dir, "cdisc_term_changes_expected_2.txt")
      check_ttl_local("CDISC_CT_Instructions_V44.txt", "cdisc_term_changes_expected_2.txt")
	  end

	  it "import cdisc term changes, June 2017" do
	    load_test_file_into_triple_store("CT_V48.ttl")
	    load_test_file_into_triple_store("CT_V49.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2017-06-30.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
		#puts job.status
	  	expect(job.status).to eq("Complete. Successful import.")  
	  #results = read_public_text_file("test", "CDISC_CT_Instructions_V49.txt")
	  #write_text_file_2(results, sub_dir, "cdisc_term_changes_expected_1.txt")
      check_ttl_local("CDISC_CT_Instructions_V49.txt", "cdisc_term_changes_expected_1.txt")
	  end

	  it "import cdisc term changes, September 2017" do
	    load_test_file_into_triple_store("CT_V49.ttl")
			load_test_file_into_triple_store("CT_V50.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V50")
	  	job = Background.create
	  	filename = db_load_file_path("cdisc", "SDTM Terminology Changes 2017-09-29.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
		#puts job.status
	  	expect(job.status).to eq("Complete. Successful import.")  
	  #results = read_public_text_file("test", "CDISC_CT_Instructions_V50.txt")
	  #write_text_file_2(results, sub_dir, "cdisc_term_changes_expected_3.txt")
      check_ttl_local("CDISC_CT_Instructions_V50.txt", "cdisc_term_changes_expected_3.txt")
	  end

	  it "import cdisc term changes, errors 1" do
	    load_test_file_into_triple_store("CT_V49.ttl")
			load_test_file_into_triple_store("CT_V50.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V50")
	  	job = Background.create
	  	filename = test_file_path(sub_dir, "cdisc_term_changes_error_1.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
	  	expect(job.status).to eq("Complete. Unsuccessful import. Failed to find terminology item [3] with identifier: C1018422222.")  
	  end

	  it "import cdisc term changes, errors 2" do
	    load_test_file_into_triple_store("CT_V49.ttl")
			load_test_file_into_triple_store("CT_V50.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V50")
	  	job = Background.create
	  	filename = test_file_path(sub_dir, "cdisc_term_changes_error_2.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
	  	expect(job.status).to eq("Complete. Unsuccessful import. Failed to child find terminology item [2] with identifier: C130.")  
	  end

	  it "import cdisc term changes, errors 3" do
	    load_test_file_into_triple_store("CT_V49.ttl")
			load_test_file_into_triple_store("CT_V50.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V50")
	  	job = Background.create
	  	filename = test_file_path(sub_dir, "cdisc_term_changes_error_3.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
	  	expect(job.status).to eq("Complete. Unsuccessful import. Failed to find terminology item [4] with identifier: C10184611111111.")  
	  end

	  it "import cdisc term changes, errors 4" do
	    load_test_file_into_triple_store("CT_V49.ttl")
			load_test_file_into_triple_store("CT_V50.ttl")
	  	ct = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V50")
	  	job = Background.create
	  	filename = test_file_path(sub_dir, "cdisc_term_changes_error_4.xlsx")
	  	params = {files: ["#{filename}"], uri: ct.uri.to_s, version: ct.version}
	  	job.import_cdisc_term_changes(params)
	  	expect(job.status).to eq("Complete. Unsuccessful import. Failed to find child terminology item [1] with identifier: C1353763333.")  
	  end

	end

end