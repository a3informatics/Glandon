require 'rails_helper'

describe Import::Crf do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include SparqlHelpers

	def sub_dir
    return "models/import/crf"
  end

  def simple_setup
    @object = Import::Crf.new
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
      description: "Import of CRF",
      parent_klass: ::Form,
      import_type: :form
    }
    expect(Import::Crf.configuration).to eq(expected)
    object = Import::Crf.new
    expect(object.configuration).to eq(expected)
  end

  it "gets form list, odm" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = Import::Crf.new
    expect(object.errors.count).to eq(0)
    result = object.list({files: [full_path], file_type: "1"})
  #write_yaml_file(result, sub_dir, "list_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_1.yaml")
		expect(result).to eq(expected)
	end

  it "gets form list, excel" do
    full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = Import::Crf.new
    expect(object.errors.count).to eq(0)
    result = object.list({files: [full_path], file_type: "2"})
  #write_yaml_file(result, sub_dir, "list_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_2.yaml")
    expect(result).to eq(expected)
  end

  it "gets form, AE example, ODM" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_AE", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_1.yaml")
    compare_import_hash(result, expected, output_file: true)
    filename = File.basename(result.output_file)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_1.ttl")
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl_fix(filename, "import_expected_1.ttl", {last_change_date: true, creation_date: true})
    delete_data_file(sub_dir, filename)
  end

  it "gets form, BASELINE example" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_BASELINE", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    compare_import_hash(result, expected, output_file: true)
    filename = File.basename(result.output_file)
  #Xcopy_file_from_public_files_rename("test", filename, sub_dir, "import_expected_2.ttl")
    copy_file_from_public_files("test", filename, sub_dir)
    check_ttl_fix(filename, "import_expected_2.ttl", {last_change_date: true, creation_date: true})
    delete_data_file(sub_dir, filename)
  end

  it "gets form, fail" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_DM", files: [full_path], file_type: "1", job: @job})
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_3.yaml")
    compare_import_hash(result, expected, error_file: true)
    copy_file_from_public_files("test", File.basename(result.error_file), sub_dir)
    expected = read_yaml_file(sub_dir, "import_expected_errors_3.yaml")
    actual = read_yaml_file(sub_dir, File.basename(result.error_file))
    expect(actual).to hash_equal(expected)
    delete_data_file(sub_dir, File.basename(result.error_file))
  end

end