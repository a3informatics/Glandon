require 'rails_helper'

describe "Import::SponsorTermFormatTwo" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include ThesauriHelpers
  include NameValueHelpers
  include CdiscCtHelpers
  
	def sub_dir
    return "models/import/sponsor_term_format_two"
  end

  def setup
    @object = Import.new(:type => "Import::SponsorTermFormatTwo")
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.auto_load = true
    @object.save
  end

	before :all do
    load_files(schema_files, [])
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_process.ttl")
    #load_cdisc_term_versions(CdiscCtHelpers.version_range)
  end

  before :each do
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
      description: "Import of New Sponsor Code List(s)",
      parent_klass: Import::STFOClasses::STFOThesaurus,
      reader_klass: Excel,
      import_type: :sponsor_term_format_two,
      version_label: :date,
      format: :format,
      label: "Controlled Terminology"
    }
    expect(Import::SponsorTermFormatTwo.new.configuration).to eq(expected)
  end

  it "sets the correct format" do
    object = Import::SponsorTermFormatTwo.new
    expect(object.format({date: "01/01/2000"})).to eq(:version_1)
    expect(object.format({date: "30/05/2019"})).to eq(:version_1)
    expect(object.format({date: "01/09/2019"})).to eq(:version_1)
    expect(object.format({date: "01/01/2100"})).to eq(:version_1)
    expect(object.format({date: DateTime.now.to_date})).to eq(:version_1)
    expect(object.format({date: DateTime.now.to_date+100})).to eq(:version_1) # Future date
  end

  it "import, no errors, version 1, short I" do
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = {files: [full_path], job: @job}
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_errors.yml"
    public_file_does_not_exist?("test", filename)
    filename = "sponsor_term_format_two_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.ttl")
    check_ttl_fix_v2(filename, "import_expected_1.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, no errors, version 1, empty" do
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = {files: [full_path], job: @job}
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_errors.yml"
    public_file_exists?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_2.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_2.yaml")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 1, errors" do
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = {files: [full_path], job: @job}
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_errors.yml"
    public_file_exists?("test", filename)
    actual = read_public_yaml_file("test", filename)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3.yaml")
    check_file_actual_expected(actual, sub_dir, "import_errors_expected_3.yaml")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, exception" do
    expect_any_instance_of(Excel).to receive(:execute).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = {files: [full_path], job: @job}
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

  it "import, no errors, version 1, short I" do
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = {files: [full_path], job: @job}
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_load.ttl"
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4a.ttl")
    check_ttl_fix_v2(filename, "import_expected_4a.ttl", {last_change_date: true})
    delete_data_file(sub_dir, filename)
    setup
    @object.auto_load = false
    @object.save
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_load.ttl"
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4b.ttl")
    check_ttl_fix_v2(filename, "import_expected_4b.ttl", {last_change_date: true})
    delete_data_file(sub_dir, filename)
    setup
    result = @object.import(params)
    filename = "sponsor_term_format_two_#{@object.id}_load.ttl"
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4c.ttl")
    check_ttl_fix_v2(filename, "import_expected_4c.ttl", {last_change_date: true})
    delete_data_file(sub_dir, filename)
  end

end