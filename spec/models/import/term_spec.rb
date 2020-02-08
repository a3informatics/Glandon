require 'rails_helper'

describe Import::Term do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers

	def sub_dir
    return "models/import/term"
  end

  def simple_setup
    @object = Import::Term.new
    @job = Background.new
    @job.save
    @object.background_id = @job.id
    @object.save
  end

	before :all do
    IsoHelpers.clear_cache
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..49)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    @th = Thesaurus.find_minimum(Uri.new(uri: "http://www.cdisc.org/CT/V49#TH"))
    @th.has_state.make_current
  end

  before :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "returns the configuration" do
    expected = {
      description: "Import of Terminology",
      parent_klass: ::Thesaurus,
      import_type: :term
    }
    object = Import::Term.new
    expect(object.configuration).to eq(expected)
  end

  it "gets term list, odm" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = Import::Term.new
    expect(object.errors.count).to eq(0)
    result = object.list({files: [full_path], file_type: "1"})
  #write_yaml_file(result, sub_dir, "list_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_1.yaml")
		expect(result).to eq(expected)
	end

  it "gets term list, excel" do
    full_path = test_file_path(sub_dir, "term_1.xlsx")
    object = Import::Term.new
    expect(object.errors.count).to eq(0)
    result = object.list({files: [full_path], file_type: "0"})
  #write_yaml_file(result, sub_dir, "list_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_2.yaml")
    expect(result).to eq(expected)
  end

  it "gets code list, AE example, ODM - WILL CURRENTLY FAIL - Allocation of identifiers" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "CL_SMOKING", files: [full_path], file_type: "1", uri: @th.uri.to_s, job: @job})
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_1.yaml")
    compare_import_hash(result, expected)
    tcs = @th.find_by_property({identifier: "CLSMOKING"})
    expect(tcs.count).to eq(1)
  #Xwrite_yaml_file(tcs[0].to_json, sub_dir, "import_expected_result_1.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_result_1.yaml")
    expect(tcs[0].to_json).to eq(expected)
    delete_data_file(sub_dir, File.basename(result.output_file))
  end

  it "gets code list, fail" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "CL_SMOKINGx", files: [full_path], file_type: "1", uri: @th.uri.to_s, job: @job})
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    compare_import_hash(result, expected, error_file: true)
    copy_file_from_public_files("test", File.basename(result.error_file), sub_dir)
    expected = read_yaml_file(sub_dir, "import_expected_errors_2.yaml")
    actual = read_yaml_file(sub_dir, File.basename(result.error_file))
    expect(actual).to hash_equal(expected)
    delete_data_file(sub_dir, File.basename(result.error_file))
  end

end