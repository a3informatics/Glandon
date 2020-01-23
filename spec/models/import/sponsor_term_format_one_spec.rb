require 'rails_helper'

describe "Import::SponsorTermFormatOne" do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers

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
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_concept_systems_baseline.ttl", "iso_concept_systems_process.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..62)
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
    expect(object.format({date: "01/06/2019"})).to eq(:version_3)
    expect(object.format({date: DateTime.now.to_date})).to eq(:version_3)
    expect(object.format({date: DateTime.now.to_date+100})).to eq(:version_3) # Future date
  end

  it "import, no errors, version 2, short I" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = {version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_3.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_3.ttl")
    check_ttl_fix(filename, "import_expected_3.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, no errors, version 2, short II" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_4.xlsx")
    params = {version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_4.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_4.ttl")
    check_ttl_fix(filename, "import_expected_4.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 2, short III" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V62#TH"))
    full_path = test_file_path(sub_dir, "import_input_6.xlsx")
    params = {version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_6.yaml")
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_6.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_6.ttl")
    check_ttl_fix(filename, "import_expected_6.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 2.1" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_1_v2-1_CDISC_v43.xlsx")
    params = {version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2-1 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_1_2-1.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1_2-1.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_1_2-1.ttl")
    check_ttl_fix(filename, "import_expected_1_2-1.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, no errors, version 2.6" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V43#TH"))
    full_path = test_file_path(sub_dir, "import_input_5_v2-6_CDISC_v43.xlsx")
    params = {version: "1", date: "2019-11-22", files: [full_path], version_label: "1.1.1", label: "Version 2-6 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_5_2-6.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_5_2-6.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_5_2-6.ttl")
    check_ttl_fix(filename, "import_expected_5_2-6.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end
 
  it "import, no errors, version 3.0" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V53#TH"))
    full_path = test_file_path(sub_dir, "import_input_2_v3-0_CDISC_v53.xlsx")
    params = {version: "1", date: "2019-11-22", files: [full_path], version_label: "1.1.1", label: "Version 3-0 Test", semantic_version: "1.1.1", job: @job, uri: ct.uri}
    result = @object.import(params)
    filename = "sponsor_term_format_one_#{@object.id}_errors.yml"
    #expect(public_file_does_not_exist?("test", filename)).to eq(true)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_errors_expected_2_3-0.yaml")
    #copy_file_from_public_files("test", filename, sub_dir)
    filename = "sponsor_term_format_one_#{@object.id}_load.ttl"
    #expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_2_3-0.ttl")
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_load_2_3-0.ttl")
    check_ttl_fix(filename, "import_expected_2_3-0.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, exception" do
    ct = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V47#TH"))
    expect_any_instance_of(Excel).to receive(:execute).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = { version: "1", version_label: "1.1.1", date: "2018-11-22", files: [full_path], label: "ADAM IG", 
      semantic_version: "1.2.4", job: @job, uri: ct.uri}
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

  # it "import, CDISC Version 2 Format, errors detected" do
  #   full_path = test_file_path(sub_dir, "SDTM Terminology 2007-03-06.xlsx")
  #   params = 
  #   {
  #     version: "1", date: "2007-03-06", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
  #   }
  #   result = @object.import(params)
  #   filename = "sponsor_term#{@object.id}_load.ttl"
  #   expect(public_file_does_not_exist?("test", filename)).to eq(true)
  #   filename = "sponsor_term#{@object.id}_errors.yml"
  #   expect(public_file_exists?("test", filename)).to eq(true)
  #   copy_file_from_public_files("test", filename, sub_dir)
  #   actual = read_yaml_file(sub_dir, filename)
  #   check_file_actual_expected(actual, sub_dir, "import_version_2007-03-06.yaml", equate_method: :hash_equal)
  #   expect(@job.status).to eq("Complete")
  #   delete_data_file(sub_dir, filename)
  # end

  # it "import, CDISC Version 3 Format, errors detected" do
  #   full_path = test_file_path(sub_dir, "SDTM Terminology 2007-05-31.xlsx")
  #   params = 
  #   {
  #     version: "1", date: "2007-05-31", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
  #   }
  #   result = @object.import(params)
  #   filename = "sponsor_term#{@object.id}_load.ttl"
  #   expect(public_file_does_not_exist?("test", filename)).to eq(true)
  #   filename = "sponsor_term#{@object.id}_errors.yml"
  #   expect(public_file_exists?("test", filename)).to eq(true)
  #   copy_file_from_public_files("test", filename, sub_dir)
  #   actual = read_yaml_file(sub_dir, filename)
  #   check_file_actual_expected(actual, sub_dir, "import_version_2007-05-31.yaml", equate_method: :hash_equal)
  #   expect(@job.status).to eq("Complete")
  #   delete_data_file(sub_dir, filename)
  # end

end