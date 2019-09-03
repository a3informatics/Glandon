require 'rails_helper'

describe Import::ChangeInstructions do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/change_instructions"
  end

  def simple_setup
    @object = Import::ChangeInstructions.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "BusinessOperational.ttl", "cross_reference.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..59)
    Import.destroy_all
    delete_all_public_test_files
  end

  after :all do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "returns the configuration" do
    expected = {
      description: "Import of CDISC Change Instructions",
      parent_klass: Import::ChangeInstructions::Instruction,
      import_type: :cdisc_change_instructions,
      reader_klass: Excel,
      sheet_name: :format
    }
    expect(Import::ChangeInstructions.configuration).to eq(expected)
    object = Import::ChangeInstructions.new
    expect(object.configuration).to eq(expected)
  end

  it "Import simple" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      files: [full_path], previous_ct: Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"), current_ct: Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"), job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #copy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.ttl")
    check_ttl_fix(filename, "import_expected_1.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "Import simple, errors" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      files: [full_path], previous_ct: Uri.new(uri: "http://www.cdisc.org/CT/V58#TH"), current_ct: Uri.new(uri: "http://www.cdisc.org/CT/V59#TH"), job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    results = read_yaml_file(sub_dir, filename)
    check_file_actual_expected(results, sub_dir, "import_expected_2.yaml")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "Import full, errors with TC" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = 
    {
      files: [full_path], previous_ct: Uri.new(uri: "http://www.cdisc.org/CT/V51#TH"), current_ct: Uri.new(uri: "http://www.cdisc.org/CT/V52#TH"), job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    results = read_yaml_file(sub_dir, filename)
    check_file_actual_expected(results, sub_dir, "import_expected_3.yaml")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "Import full example" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_4.xlsx")
    params = 
    {
      # Note, need to use the right CDISC term versions  
      files: [full_path], previous_ct: Uri.new(uri: "http://www.cdisc.org/CT/V51#TH"), current_ct: Uri.new(uri: "http://www.cdisc.org/CT/V52#TH"), job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_4.ttl")
    check_ttl_fix(filename, "import_expected_4.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

end