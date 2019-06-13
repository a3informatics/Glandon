require 'rails_helper'

describe Import::CdiscTerm do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/cdisc_term"
  end

  def setup
    #@object = Import::CdiscTerm.new
    @object = Import.new(:type => "Import::CdiscTerm") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :each do
    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
      "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
    ]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "iso_scoped_identifier.ttl"]
    load_files(schema_files, data_files)
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
      description: "Import of CDISC Terminology",
      parent_klass: ::CdiscTerm,
      reader_klass: Excel::CdiscTermReader,
      import_type: :cdisc_term,
      sheet_name: :sheet,
      version_label: :date,
      label: "Controlled Terminology"
    }
    expect(Import::CdiscTerm.configuration).to eq(expected)
  end

  it "sets the correct format" do
    object = Import::CdiscTerm.new
    expect(object.sheet({date: "01/01/2000"})).to eq(:version_1)
    expect(object.sheet({date: "30/04/2007"})).to eq(:version_1)
    expect(object.sheet({date: "01/05/2007"})).to eq(:version_2)
    expect(object.sheet({date: "31/03/2010"})).to eq(:version_2)
    expect(object.sheet({date: "01/04/2010"})).to eq(:version_3)
    expect(object.sheet({date: DateTime.now.to_date})).to eq(:version_3)
    expect(object.sheet({date: DateTime.now.to_date+100})).to eq(:version_3) # Future date
  end

  it "import, no errors" do
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      version: "1", date: "2018-11-22", files: [full_path], version_label: "1.1.1", label: "ADaM IG", semantic_version: "1.1.1", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.txt")
    check_ttl(filename, "import_expected_1.txt")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, errors" do
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      version: "1", version_label: "1.1.1", date: "2018-11-22", 
      files: [full_path], 
      label: "ADAM IG",
      semantic_version: "1.2.3",
      job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, exception" do
    expect_any_instance_of(Excel::CdiscTermReader).to receive(:check_and_process_sheet).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      version: "1", version_label: "1.1.1", date: "2018-11-22", 
      files: [full_path], 
      label: "ADAM IG",
      semantic_version: "1.2.4",
      job: @job
    }
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

  it "import, CDISC Version 1 Format" do
    full_path = test_file_path(sub_dir, "SDTM Terminology 2007-03-06.xlsx")
    params = 
    {
      version: "1", date: "2007-03-06", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_version_2007-03-06.yaml")
    expected = read_yaml_file(sub_dir, "import_version_2007-03-06.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
byebug
    delete_data_file(sub_dir, filename)
  end

  it "import, CDISC Version 2 Format" do
    full_path = test_file_path(sub_dir, "SDTM Terminology 2007-05-31.xlsx")
    params = 
    {
      version: "1", date: "2007-05-31", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_version_2007-05-31.yaml")
    expected = read_yaml_file(sub_dir, "import_version_2007-05-31.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, CDISC Version 3 Format" do
    full_path = test_file_path(sub_dir, "SDTM Terminology 2010-04-08.xlsx")
    params = 
    {
      version: "1", date: "2010-04-08", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_version_2010-04-08.yaml")
    expected = read_yaml_file(sub_dir, "import_version_2010-04-08.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, CDISC Version 3 Format" do
    full_path = test_file_path(sub_dir, "SDTM Terminology 2012-06-29.xlsx")
    params = 
    {
      version: "1", date: "2012-06-29", files: [full_path], version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_version_2012-06-29.txt")
    check_ttl(filename, "import_version_2012-06-29.txt")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, Multiple Version 3 Format" do
    full_path_1 = test_file_path(sub_dir, "SDTM Terminology 2018-12-21.xlsx")
    full_path_2 = test_file_path(sub_dir, "CDASH Terminology 2018-12-21.xlsx")
    full_path_3 = test_file_path(sub_dir, "ADaM Terminology 2018-12-21.xlsx")
    full_path_4 = test_file_path(sub_dir, "SEND Terminology 2018-12-21.xlsx")
    full_path_5 = test_file_path(sub_dir, "Protocol Terminology 2018-09-28.xlsx")
    params = 
    {
      version: "1", date: "2018-12-21", files: [full_path_1, full_path_2, full_path_3, full_path_4, full_path_5], 
      version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_version_2018-12-21.yaml")
    expected = read_yaml_file(sub_dir, "import_version_2018-12-21.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, Duplicates I" do
    full_path_1 = test_file_path(sub_dir, "SDTM Terminology Duplicate 1.xlsx")
    full_path_2 = test_file_path(sub_dir, "SDTM Terminology Duplicate 2.xlsx")
    params = 
    {
      version: "1", date: "2018-12-21", files: [full_path_1, full_path_2], 
      version_label: "1.0.0", label: "CDISC Term", semantic_version: "1.0.0", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "duplicates_expected_1.txt")
    check_ttl(filename, "duplicates_expected_1.txt")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, CDISC Compare with previous method" do
    load_test_file_into_triple_store("CT_V38.ttl")
    full_path_1 = test_file_path(sub_dir, "SDTM Terminology 2014-12-19.xlsx")
    full_path_2 = test_file_path(sub_dir, "COA Terminology 2014-12-19.xlsx")
    params = {version: "39", date: "2014-12-19", files: [full_path_1, full_path_2], version_label: "2014-12-19", label: "CDISC Terminology 2014-12-19", semantic_version: "39.0.0", job: @job}
    result = @object.import(params)
    filename = "cdisc_term_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_term_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl(filename, "import_version_2014-12-19.ttl")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

end