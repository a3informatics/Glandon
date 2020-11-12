require 'rails_helper'

describe SdtmIg do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_ig"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_model/SDTM_MODEL_V1.ttl")
    load_data_file_into_triple_store("cdisc/sdtm_ig/SDTM_IG_V1.ttl")
  end

  it "allows an IG to be found" do
    item = SdtmIg.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG/V1#IG"))
    check_file_actual_expected(item.to_h, sub_dir, "find_expected.yaml", equate_method: :hash_equal)
  end

  it "allows a IG to be found, not found error" do
    expect{SdtmIg.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG/V1#IGxx"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.cdisc.org/SDTM_IG/V1#IGxx in SdtmIg.")
  end

  it "allows an IG to get children (domains)" do
    actual = []
    item = SdtmIg.find_minimum(Uri.new(uri: "http://www.cdisc.org/SDTM_IG/V1#IG"))
    children = item.managed_children_pagination({offset: 0, count: 10})
    children.each {|x| actual << x.to_h}
    check_file_actual_expected(actual, sub_dir, "find_children.yaml", equate_method: :hash_equal)
  end

 #  it "allows the IG history to be found" do
 #    result = SdtmIg.history
 #    expect(result.count).to eq(1)    
 #  end
  
 #  it "allows the model to be exported as JSON" do
 #    item = SdtmIg.find("IG-CDISC_SDTMIG", "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3")
 #    check_file_actual_expected(item.to_json, sub_dir, "to_json_expected.yaml", equate_method: :hash_equal)
 #  end

 #  it "allows for the addition of a domain" do
 #  	ig = SdtmIg.new
 #  	expect(ig.domain_refs.count).to eq(0)
 #  	domain_1 = SdtmIgDomain.new
 #  	domain_1.id = "IG-CDISC_SDTMIG_1"
 #  	domain_1.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
 #  	domain_2 = SdtmIgDomain.new
 #  	domain_2.id = "IG-CDISC_SDTMIG_2"
 #  	domain_2.namespace = "http://www.assero.co.uk/MDRSdtmIg/CDISC/V3"
 #  	ig.add_domain(domain_1)
 #  	expect(ig.domain_refs.count).to eq(1)
 #  	ig.add_domain(domain_2)
 #  	expect(ig.domain_refs.count).to eq(2)
 #  	expect(ig.domain_refs[0].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG_1")
 #  	expect(ig.domain_refs[1].subject_ref.to_s).to eq("http://www.assero.co.uk/MDRSdtmIg/CDISC/V3#IG-CDISC_SDTMIG_2")
 #  end

 #  it "creates a new version" do
 #  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
 #  	params = 
 #    { 
 #      :version => "4",
 #      :version_label => "2.0",
 #      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
 #      :date => "2017-10-14", 
 #      :files => ["#{filename}"]
	# 	}
	# 	result = SdtmIg.create(params)
	# 	expect(result[:job]).to_not eq(nil)
	# 	expect(result[:object].errors.count).to eq(0)
 #  end

 #  it "creates a new version, error I" do
 #  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
 #  	params = 
 #    { 
 #      :version => "NaN",
 #      :version_label => "2.0",
 #      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
 #      :date => "2017-10-14", 
 #      :files => ["#{filename}"]
	# 	}
	# 	result = SdtmIg.create(params)
	# 	expect(result[:job]).to eq(nil)
	# 	expect(result[:object].errors.count).to eq(1)
	# 	expect(result[:object].errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")
 #  end

 #  it "creates a new version, error II" do
 #  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
 #  	params = 
 #    { 
 #      :version => "1",
 #      :version_label => "2.0",
 #      :date => "2017-10-14", 
 #      :files => ["#{filename}"]
	# 	}
	# 	result = SdtmIg.create(params)
	# 	expect(result[:job]).to eq(nil)
	# 	expect(result[:object].errors.count).to eq(1)
	# 	expect(result[:object].errors.full_messages.to_sentence).to eq("Model uri is empty")
 #  end

 #  it "creates a new version, error III" do
 #  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
 #  	params = 
 #    { 
 #      :version_label => "2.0",
 #      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
 #      :date => "2017-10-14", 
 #      :files => ["#{filename}"]
	# 	}
	# 	result = SdtmIg.create(params)
	# 	expect(result[:job]).to eq(nil)
	# 	expect(result[:object].errors.count).to eq(1)
	# 	expect(result[:object].errors.full_messages.to_sentence).to eq("Version is empty")
 #  end

 #  it "creates a new version, error IV" do
 #  	filename = db_load_file_path("cdisc", "sdtm-3-1-2-excel.xlsx")
 #  	params = 
 #    { 
 #      :version => "4",
 #      :version_label => "2.0",
 #      :model_uri => "http://www.assero.co.uk/MDRSdtmM/CDISC/V3#M-CDISC",
 #      :files => ["#{filename}"]
	# 	}
	# 	result = SdtmIg.create(params)
	# 	expect(result[:object].errors.count).to eq(1)
	# 	expect(result[:object].errors.full_messages.to_sentence).to eq("Date is empty")
 #  end

end