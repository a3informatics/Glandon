require 'rails_helper'

describe Import::ChangeInstructions do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers

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

	before :each do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "BusinessOperational.ttl", "cross_reference.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..59)
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "returns the configuration" do
    expected = {
      description: "Import of CDISC Change Instructions",
      parent_klass: Import::ChangeInstructions::Instruction,
      import_type: :cdisc_change_instructions
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
byebug
    filename = "cdisc_change_instructions_#{@object.id}_errors.yml"
    expect(public_file_does_not_exist?("test", filename)).to eq(true)
    filename = "cdisc_change_instructions_#{@object.id}_load.ttl"
    expect(public_file_exists?("test", filename)).to eq(true)
    copy_file_from_public_files("test", filename, sub_dir)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1a.ttl")
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_load_1b.ttl")
    check_ttl_fix(filename, "import_expected_1a.ttl", {last_change_date: true})
    expect(@job.status).to eq("Complete")
    delete_data_file(sub_dir, filename)
	end

end