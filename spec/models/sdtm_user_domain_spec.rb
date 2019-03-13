require 'rails_helper'

describe SdtmUserDomain do

  include DataHelpers
  include PublicFileHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_user_domain"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_ds.ttl")
    load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
    load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "allows a domain to be found" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  #write_yaml_file(item.to_json, sub_dir, "find_expected.yaml")  
    expected = read_yaml_file(sub_dir, "find_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows a domain to be found, not found error" do
    expect{SdtmUserDomain.find("D-ACME_VSDomainx", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")}.to raise_error(Exceptions::NotFoundError)
  end

  it "allows all domains to be found" do
    result = SdtmUserDomain.all 
    expect(result.count).to eq(3)
    expect(result.map{ |x| x.identifier }).to match_array(["DM Domain", "VS Domain", "DS Domain"])
  end
  
  it "allows all unique domains to be found" do
    result = SdtmUserDomain.unique 
    expect(result.count).to eq(3)
    expect(result[0][:identifier]).to eq("DM Domain")
    expect(result[1][:identifier]).to eq("DS Domain")
    expect(result[2][:identifier]).to eq("VS Domain")
  end

  it "allows all released domains to be found" do
    result = SdtmUserDomain.list
    expect(result.count).to eq(0)    
  end
  
  it "allows an item's history to be found" do
    owner = IsoRegistrationAuthority.owner
    result = SdtmUserDomain.history({:identifier => "DM Domain", :scope_id => owner.namespace.id})
    expect(result.count).to eq(1)
  end
  
  it "allows a clone of an IG domain to be created, VS" do
    ig_domain = SdtmIgDomain.find("IG-CDISC_SDTMIGVS", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    new_domain = SdtmUserDomain.create_clone_ig({:prefix => "XX", :label => "Clone VS as XX"}, ig_domain)
    expect(new_domain.errors.count).to eq(0)
  #write_yaml_file(new_domain.to_json, sub_dir, "clone_ig_expected.yaml")  
    expected = read_yaml_file(sub_dir, "clone_ig_expected.yaml")
    expected[:last_changed_date] = date_check_now(new_domain.lastChangeDate).iso8601
    expected[:creation_date] = date_check_now(new_domain.creationDate).iso8601
    expect(new_domain.to_json).to eq(expected)
  end
  
  it "allows a clone of an IG domain to be created, AE" do
    ig_domain = SdtmIgDomain.find("IG-CDISC_SDTMIGAE", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    new_domain = SdtmUserDomain.create_clone_ig({:prefix => "XY", :label => "Clone AE as XY"}, ig_domain)
    expect(new_domain.errors.count).to eq(0)
  #write_yaml_file(new_domain.to_json, sub_dir, "clone_ig_expected_2.yaml")  
    expected = read_yaml_file(sub_dir, "clone_ig_expected_2.yaml")
    expected[:last_changed_date] = date_check_now(new_domain.lastChangeDate).iso8601
    expected[:creation_date] = date_check_now(new_domain.creationDate).iso8601
    expect(new_domain.to_json).to eq(expected)
  end
  
  it "allows a domain to be created" do
    params = read_yaml_file(sub_dir, "create_input.yaml")
    new_domain = SdtmUserDomain.create(params[:data])
  #write_yaml_file(new_domain.to_json, sub_dir, "create_expected.yaml")  
    expected = read_yaml_file(sub_dir, "create_expected.yaml")
    expected[:last_changed_date] = date_check_now(new_domain.lastChangeDate).iso8601
    expect(new_domain.to_json).to eq(expected)
  end      
  
  it "allows a domain to be updated" do
    params = read_yaml_file(sub_dir, "create_input.yaml")
    new_domain = SdtmUserDomain.update(params[:data])
  #write_yaml_file(new_domain.to_json, sub_dir, "update_expected.yaml")
    expected = read_yaml_file(sub_dir, "update_expected.yaml")
    expected[:last_changed_date] = date_check_now(new_domain.lastChangeDate).iso8601
    expect(new_domain.to_json).to eq(expected)
  end      
  
  it "allows a domain to be destroyed" do
    ig_domain = SdtmIgDomain.find("IG-CDISC_SDTMIGVS", "http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3")
    new_domain = SdtmUserDomain.create_clone_ig({:prefix => "AA", :label => "Clone VS as AA"}, ig_domain)
    domain = SdtmUserDomain.find("D-ACME_AADomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    expect(domain.exists?).to eq(true)
    domain.destroy
    expect(domain.exists?).to eq(false)
  end
  
  it "allows the domain to be exported as JSON" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
  #write_yaml_file(item.to_json, sub_dir, "to_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "to_json_expected.yaml")
    expect(item.to_json).to eq(expected)
  end
  
  it "allows a domain to be created from JSON" do
    json = read_yaml_file(sub_dir, "sdtm_user_domain.yaml")
    item = SdtmUserDomain.from_json(json)
  #write_yaml_file(item.to_json, sub_dir, "from_json_expected.yaml")
    expected = read_yaml_file(sub_dir, "from_json_expected.yaml")
    expect(item.to_json).to eq(expected)
  end
  
  it "allows the domain to be exported as SPARQL" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    sparql = item.to_sparql_v2
  #write_text_file_2(sparql.to_s, sub_dir, "to_sparql_expected.txt")
    #expected = read_text_file_2(sub_dir, "to_sparql_expected.txt")
    #expect(sparql.to_s).to eq(expected)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
  end
  
  it "allows BC to be associated with a domain" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    bc_count = item.bc_refs.count
    params = { :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677", "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C16358"] }
    item.add(params)
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    expect(item.bc_refs.count).to eq(bc_count + 2)
  #write_yaml_file(item.to_json, sub_dir, "add_1_expected.yaml")
    expected = read_yaml_file(sub_dir, "add_1_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows BC to be associated with a domain, won't allow repeats" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    bc_count = item.bc_refs.count
    params = { :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677"] }
    item.add(params)
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    expect(item.bc_refs.count).to eq(bc_count)
  #write_yaml_file(item.to_json, sub_dir, "add_2_expected.yaml")
    expected = read_yaml_file(sub_dir, "add_2_expected.yaml")
    expect(item.to_json).to eq(expected)
  end

  it "allows the BC association to be deleted, multiple" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    bc_count = item.bc_refs.count
    params = { :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C49677", "http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C16358"] }
    item.remove(params)
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    expect(item.bc_refs.count).to eq(bc_count - 2)
  #write_yaml_file(item.to_json, sub_dir, "add_3_expected.yaml")
    expected = read_yaml_file(sub_dir, "add_3_expected.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expect(item.to_json).to eq(expected)
  end
  
  it "allows the BC association to be deleted, single" do
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    params = { :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347"] }
    item.add(params)
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    bc_count = item.bc_refs.count
    params = { :bcs => ["http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C25347"] }
    item.remove(params)
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    expect(item.bc_refs.count).to eq(bc_count - 1)
  #write_yaml_file(item.to_json, sub_dir, "add_4_expected.yaml")
    expected = read_yaml_file(sub_dir, "add_4_expected.yaml")
    expected[:children].sort_by! {|u| u[:ordinal]} # Use old results file, re-order before comparison
    expect(item.to_json).to eq(expected)
  end
  
  it "allows a domain report to be generated"

  it "exports the domain as a SAS XPT file - WILL CURRENTLY FAIL (TimeDate Stamp Issue)" do
    delete_all_public_export_files
    item = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
    full_path = item.to_xpt
    filename = File.basename(full_path)
  #Xcopy_file_from_public_files("test", filename, sub_dir)
    expected = read_text_file_2(sub_dir, filename)
    result = read_public_text_file("test", filename)
    expect(result).to eq(expected)
  end
  
end