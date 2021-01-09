require 'rails_helper'
require 'tabulation/column'

describe Import::SdtmModel do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  
	def sub_dir
    return "models/import/sdtm_model"
  end

  def setup
    #@object = Import::SdtmModel.new
    @object = Import.new(:type => "Import::SdtmModel") # Use this rather than above.
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :each do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_1.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_2.ttl")
    load_data_file_into_triple_store("mdr_iso_concept_systems_migration_3.ttl")
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
      description: "Import of CDISC SDTM Model",
      parent_klass: ::SdtmModel,
      reader_klass: Excel,
      import_type: :cdisc_sdtm_model,
      format: :format,
      version_label: :semantic_version,
      label: "CDISC SDTM Model"
    }
    expect(Import::SdtmModel.new.configuration).to eq(expected)
  end

  it "import, no errors" do
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = {version: "1", date: "2016-11-22", files: [full_path], version_label: "1.1.1", label: "SDTM Model", semantic_version: "1.1.1", job: @job}
    result = @object.import(params)
    filename = "cdisc_sdtm_model_#{@object.id}_errors.yml"
    public_file_does_not_exist?("test", filename)
    filename = "cdisc_sdtm_model_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.txt")
    check_ttl(filename, "import_expected_1.txt")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, errors"  do
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = {version: "1", date: "2016-11-22", files: [full_path], version_label: "1.1.1", label: "SDTM Model", semantic_version: "1.2.3", job: @job}
    result = @object.import(params)
    filename = "cdisc_sdtm_model_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_sdtm_model_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    actual = read_yaml_file(sub_dir, filename)
  #Xwrite_yaml_file(actual, sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    expect(actual).to eq(expected)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import bug fix"  do
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = {version: "1", date: "2016-11-22", files: [full_path], version_label: "1.1.1", label: "SDTM Model", semantic_version: "1.1.1", job: @job}
    result = @object.import(params)
    filename = "cdisc_sdtm_model_#{@object.id}_errors.yml"
    public_file_does_not_exist?("test", filename)
    filename = "cdisc_sdtm_model_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_3.ttl")
    check_ttl(filename, "import_expected_3.ttl")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "import, exception" do
    expect_any_instance_of(Excel).to receive(:execute).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = {version: "1", date: "2016-11-22", files: [full_path], version_label: "1.1.1", label: "SDTM Model", semantic_version: "1.2.3", job: @job}
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

end