require 'rails_helper'

describe Import::ChangeInstruction do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers
  include CdiscCtHelpers

	def sub_dir
    return "models/import/change_instruction"
  end

  class CIWorker
  
    extend ActiveModel::Naming

    attr_reader   :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end
  
  end

  def simple_setup
    @object = Import::ChangeInstruction.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(CdiscCtHelpers.version_range)
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
      parent_klass: Import::ChangeInstruction::Instruction,
      import_type: :cdisc_change_instructions,
      reader_klass: Excel,
      format: :format
    }
    object = Import::ChangeInstruction.new
    expect(object.configuration).to eq(expected)
  end

  it "create" do
    object = Import::ChangeInstruction.new
    id = Uri.new(uri: "http://www.cdisc.org/CT/V59#TH").to_id
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      files: [full_path], current_id: id, job: @job, auto_load: false
    }
    expect(object).to receive(:import).with({current_id: id, files: [full_path], auto_load: false, job: an_instance_of(Background)})
    result = object.create(params)
    expect(params[:job].status).to eq("Starting ...")
    expect(params[:job].complete).to eq(false)
  end

  it "create, exception" do
    object = Import::ChangeInstruction.new
    id = Uri.new(uri: "http://www.cdisc.org/CT/V59#TH").to_id
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      files: [full_path], current_id: id, job: @job, auto_load: true
    }
    expect(object).to receive(:import).with({current_id: id, files: [full_path], auto_load: true, job: an_instance_of(Background)}).and_raise(Errors::ApplicationLogicError)
    expect(object).to receive(:save_error_file).with({parent: object, children:[]})
    result = object.create(params)
    expect(params[:job].status.start_with?("An exception was detected during the import processes.")).to eq(true)
    expect(params[:job].complete).to eq(true)
  end

  it "Import simple" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      files: [full_path], current_id: Uri.new(uri: "http://www.cdisc.org/CT/V59#TH").to_id, job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.ttl")
    check_ttl_fix(filename, "import_expected_1.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

  it "Import simple, errors" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_2.xlsx")
    params = 
    {
      files: [full_path], current_id: Uri.new(uri: "http://www.cdisc.org/CT/V59#TH").to_id, job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    results = read_yaml_file(sub_dir, filename)
    check_file_actual_expected(results, sub_dir, "import_expected_2.yaml", equate_method: :hash_equal)
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "Import full, errors with TC" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_3.xlsx")
    params = 
    {
      files: [full_path], current_id: Uri.new(uri: "http://www.cdisc.org/CT/V59#TH").to_id, job: @job
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

  it "Import full, errors with CDISC CT" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_1.xlsx")
    params = 
    {
      files: [full_path], current_id: "aaa", job: @job
    }
    result = @object.import(params)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
    results = read_yaml_file(sub_dir, filename)
    check_file_actual_expected(results, sub_dir, "import_expected_5.yaml")
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
  end

  it "Import full example" do
    simple_setup
    full_path = test_file_path(sub_dir, "import_input_4.xlsx")
    params = 
    {
      # Note, need to use the right CDISC term versions  
      files: [full_path], current_id: Uri.new(uri: "http://www.cdisc.org/CT/V53#TH").to_id, job: @job
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

  it "saves the load file"

  it "saves the error file"
  
end