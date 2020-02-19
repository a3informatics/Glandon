require 'rails_helper'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  
	def sub_dir
    return "models/import/data/sponsor_one/ct"
  end

  def setup
    @object = Import.new(:type => "Import::SponsorTermFormatOne") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :each do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    load_cdisc_term_versions(1..62)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "1000")
    NameValue.create(name: "thesaurus_child_identifier", value: "10000")
    Import.destroy_all
    delete_all_public_test_files
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "import version 2.6" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = db_load_file_path("sponsor_one/ct", "global_v2-6_CDISC_v43.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v2-6.yaml")
    params = {identifier: "Q3 2019", version: "1", date: "2019-08-08", files: [full_path], fixes: fixes, version_label: "1.0.0", label: "Version 2-6, Q3 2019", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_2-6.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_2-6.yaml", equate_method: :hash_equal)
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_2-6.ttl")
    check_ttl_fix_v2(filename, "import_expected_2-6.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end
 
  it "import version 3.0", :speed => 'slow' do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
    load_local_file_into_triple_store(sub_dir, "import_expected_2-6.ttl")
    full_path = db_load_file_path("sponsor_one/ct", "global_v3-0_CDISC_v53.xlsx")
    fixes = db_load_file_path("sponsor_one/ct", "fixes_v3-0.yaml")
    params = {identifier: "Q1 2020", version: "1", date: "2020-01-01", files: [full_path], fixes: fixes, version_label: "1.0.0", label: "Version 3-0, Q1 2020", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3-0.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_3-0.yaml", equate_method: :hash_equal)
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_3-0.ttl")
    check_ttl_fix_v2(filename, "import_load_3-0.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

end