require 'rails_helper'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include NameValueHelpers
  
	def sub_dir
    return "models/import/sponsor_term_format_one"
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
    nv_destroy
    nv_create(parent: "1000", child: "10000")
    Import.destroy_all
    delete_all_public_test_files
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "returns the configuation" do
    expected =
    {
      description: "Import of Sponsor Terminology",
      parent_klass: Import::STFOClasses::STFOThesaurus,
      reader_klass: Excel,
      import_type: :sponsor_term_format_one,
      version_label: :date,
      format: :format,
      label: "Controlled Terminology"
    }
    expect(Import::SponsorTermFormatOne.new.configuration).to eq(expected)
  end

  it "sets the correct format" do
    object = Import::SponsorTermFormatOne.new
    expect(object.format({date: "01/01/2000"})).to eq(:version_2)
    expect(object.format({date: "30/05/2019"})).to eq(:version_2)
    expect(object.format({date: "01/09/2019"})).to eq(:version_2)
    expect(object.format({date: "01/01/2100"})).to eq(:version_3)
    expect(object.format({date: DateTime.now.to_date})).to eq(:version_2)
    expect(object.format({date: DateTime.now.to_date+100})).to eq(:version_2) # Future date
  end

  it "import, no errors, version 2, short I" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    fixes = test_file_path(sub_dir, "import_fixes_3.yaml")
    params = {identifier: "V2 I", version: "1", date: "2018-11-22", files: [full_path], fixes: fixes, version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #public_file_does_not_exist?("test", filename)
    public_file_exists?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_3.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3.ttl")
    check_ttl_fix_v2(filename, "import_expected_3.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, no errors, version 2, short II" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_4.xlsx")
    params = {identifier: "V2 II", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #public_file_does_not_exist?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_4.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_4.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4.ttl")
    check_ttl_fix_v2(filename, "import_expected_4.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 2, short III" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_6.xlsx")
    params = {identifier: "V2 III", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #public_file_does_not_exist?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_6.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_6.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_6.ttl")
    check_ttl_fix_v2(filename, "import_expected_6.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 2, short IV" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_8.xlsx")
    fixes = test_file_path(sub_dir, "import_fixes_8.yaml")
    params = {identifier: "V2 I", version: "1", date: "2018-11-22", files: [full_path], fixes: fixes, version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    public_file_exists?("test", filename)
    #public_file_does_not_exist?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_8.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_8.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    public_file_exists?("test", filename)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_8.ttl")
    check_ttl_fix_v2(filename, "import_expected_8.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, multiple files, version 3, short V" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path_a = test_file_path(sub_dir, "import_input_9a.xlsx")
    full_path_b = test_file_path(sub_dir, "import_input_9b.xlsx")
    params = {identifier: "V2 I", version: "1", date: "2100-01-01", files: [full_path_a, full_path_b], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    public_file_exists?("test", filename)
    #public_file_does_not_exist?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_9.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_9.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    public_file_exists?("test", filename)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_9.ttl")
    check_ttl_fix_v2(filename, "import_expected_9.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

#   it "import, no errors, partial version 3.0 with base" do
#     ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
# puts colourize("Load 2.6 excel ...", "blue")
#     full_path = test_file_path(sub_dir, "import_input_7_v2-6_CDISC_v43.xlsx")
#     params = {identifier: "Q4 2019", version: "1", date: "2018-11-22", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
#     result = @object.import(params)
#     filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
#     #expect(public_file_does_not_exist?("test", filename)).to eq(true)
#     actual = read_public_yaml_file("test", filename)
#   #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_7a.yaml")
#     check_file_actual_expected(actual, sub_dir, "import_errors_expected_7a.yaml")
#     #copy_file_from_public_files("test", filename, sub_dir)
#     filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
#   #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_input_7a.ttl")
#     expect(@job.status).to eq("Complete")
#     delete_data_file(sub_dir, filename)
#     ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
# puts colourize("Load 2.6 triples ...", "blue")
#     load_local_file_into_triple_store(sub_dir, "import_input_7a.ttl")
# puts colourize("Load 3.0 excel ...", "blue")
#     full_path = test_file_path(sub_dir, "import_input_7_v3-0_CDISC_v53.xlsx")
#     params = {identifier: "Q1 2020", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 3-0 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
#     result = @object.import(params)
#     filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
#     #expect(public_file_does_not_exist?("test", filename)).to eq(true)
#     actual = read_public_yaml_file("test", filename)
#   #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_7b.yaml")
#     check_file_actual_expected(actual, sub_dir, "import_errors_expected_7b.yaml")
#     #copy_file_from_public_files("test", filename, sub_dir)
#     filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
#     #expect(public_file_exists?("test", filename)).to eq(true)
#     copy_file_from_public_files("test", filename, sub_dir)
#   #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_7b.ttl")
#     check_ttl_fix_v2(filename, "import_expected_7b.ttl", {last_change_date: true})
#     expect(@job.status).to eq("Complete")
#     delete_data_file(sub_dir, filename)
#   end

  it "paths test" do
    tc = Thesaurus::ManagedConcept.find_full(Uri.new(uri: "http://www.cdisc.org/C66767/V35#C66767"))
    check_file_actual_expected(tc.to_h, sub_dir, "find_full_paths_expected_1.yaml", equate_method: :hash_equal)
  end

  it "import, no errors, full version 3.0 with base, bug issue I" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
puts colourize("Load 2.6 triples ...", "blue")
    load_local_file_into_triple_store(sub_dir, "import_load_10.ttl")
puts colourize("Load 3.0 excel ...", "blue")
    full_path = test_file_path(sub_dir, "import_input_10.xlsx")
    params = {identifier: "Q1 2020", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 3-0 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_10.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_10.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_10.ttl")
    check_ttl_fix_v2(filename, "import_expected_10.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, full version 3.0 with base, bug issue II" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
puts colourize("Load 2.6 triples ...", "blue")
    load_local_file_into_triple_store(sub_dir, "import_load_11.ttl")
puts colourize("Load 3.0 excel ...", "blue")
    full_path = test_file_path(sub_dir, "import_input_11.xlsx")
    params = {identifier: "Q1 2020", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 3-0 Test Upgrade", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_11.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_11.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_11.ttl")
    check_ttl_fix_v2(filename, "import_expected_11.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue III" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_12.xlsx")
    params = {identifier: "Q2 2019", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_12.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_12.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_12.ttl")
    check_ttl_fix_v2(filename, "import_expected_12.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue IV" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_14.xlsx")
    params = {identifier: "Q2 2019", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_14.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_14.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_14.ttl")
    check_ttl_fix_v2(filename, "import_expected_14.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue V" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_15.xlsx")
    params = {identifier: "TEST 15", version: "1", date: "2100-01-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_15.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_15.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_15.ttl")
    check_ttl_fix_v2(filename, "import_expected_15.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue VI" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_16.xlsx")
    params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_16.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_16.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_16.ttl")
    check_ttl_fix_v2(filename, "import_expected_16.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue VII" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_17.xlsx")
    params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_17.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_17.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_17.ttl")
    check_ttl_fix_v2(filename, "import_expected_17.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, bug issue VIII" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_18.xlsx")
    params = {identifier: "TEST 16", version: "1", date: "2019-06-01", files: [full_path], version_label: "1.0.0", label: "Version 2-6 Test", semantic_version: "1.0.0", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_18.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_18.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_18.ttl")
    check_ttl_fix_v2(filename, "import_expected_18.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, exception" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
    expect_any_instance_of(Excel).to receive(:execute).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = { version: "1", version_label: "1.1.1", date: "2018-11-22", files: [full_path], label: "ADAM IG", 
      semantic_version: "1.2.4", job: @job, uri: ct.uri}
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

end