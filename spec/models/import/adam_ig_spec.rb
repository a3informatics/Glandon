require 'rails_helper'

describe Import::AdamIg do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include TurtleHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/adam_ig"
  end

  def setup
    @object = Import::AdamIg.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

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
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    Import.destroy_all
    delete_all_public_test_files
    setup
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "import, no errors" do
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      version: "1", date: "2018-11-22", filename: full_path, files: [full_path], version_label: "1.1.1", label: "ADaM IG", semantic_version: "1.1.1", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_adam_ig_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_adam_ig_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.txt")
    #actual = read_sparql_file(filename)
    #expected = read_sparql_file("import_expected_1.txt")
    #expect(actual).to sparql_results_equal(expected)
    check_ttl(filename, "import_expected_1.txt")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "import, errors" do
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      version: "1", version_label: "1.1.1", date: "2018-11-22", 
      filename: full_path, files: [full_path], 
      label: "ADAM IG",
      semantic_version: "1.2.3",
      job: @job
    }
    result = @object.import(params)
    filename = "cdisc_adam_ig_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?(sub_dir, filename)).to eq(true)
    filename = "cdisc_adam_ig_#{@object.id}_errors.yml"
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
    expect_any_instance_of(Excel::AdamIgReader).to receive(:check_and_process_sheet).and_raise(StandardError.new("error"))
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      version: "1", version_label: "1.1.1", date: "2018-11-22", 
      filename: full_path, files: [full_path], 
      label: "ADAM IG",
      semantic_version: "1.2.4",
      job: @job
    }
    @object.import(params)
    expect(@job.status).to include("An exception was detected during the import processes.\nDetails: error.\nBacktrace: ")
  end

end