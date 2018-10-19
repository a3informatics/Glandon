require 'rails_helper'

describe Import::Crf do
	
	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers
  include TurtleHelpers
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
    load_test_file_into_triple_store("CT_V49.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    th = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V49")
    IsoRegistrationState.make_current(th.registrationState.id)
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
    import_type(Import::Crf::C_IMPORT_TYPE)
  end

  it "gets form list, odm" do
    full_path = test_file_path(sub_dir, "odm_1.xml")
    object = Import::Crf.new
    expect(object.errors.count).to eq(0)
    result = object.list({filename: full_path, file_type: "1"})
  #write_yaml_file(result, sub_dir, "list_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_1.yaml")
		expect(result).to eq(expected)
	end

  it "gets form list, excel" do
    full_path = test_file_path(sub_dir, "als_1.xlsx")
    object = Import::Crf.new
    expect(object.errors.count).to eq(0)
    result = object.list({filename: full_path, file_type: "2"})
  #write_yaml_file(result, sub_dir, "list_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "list_expected_2.yaml")
    expect(result).to eq(expected)
  end

  it "gets form, AE example, ODM" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_AE", filename: full_path, file_type: "1"}, @job)
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_1.yaml")
    compare_import_hash(result, expected, output_file: true)
    copy_file_from_public_files("test", File.basename(result.output_file), sub_dir)
    expected = read_sparql_file("import_expected_1.ttl")
    actual = read_sparql_file(File.basename(result.output_file))
    fix_last_change_date(actual, expected)
    fix_creation_date(actual, expected)
    expect(actual).to sparql_results_equal(expected)
    delete_data_file(sub_dir, File.basename(result.output_file))
  end

  it "gets form, BASELINE example" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_BASELINE", filename: full_path, file_type: "1"}, @job)
    result = Import.find(@object.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "import_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "import_expected_2.yaml")
    compare_import_hash(result, expected, output_file: true)
    copy_file_from_public_files("test", File.basename(result.output_file), sub_dir)
    expected = read_sparql_file("import_expected_2.ttl")
    actual = read_sparql_file(File.basename(result.output_file))
    fix_last_change_date(actual, expected)
    fix_creation_date(actual, expected)
    expect(actual).to sparql_results_equal(expected)
    delete_data_file(sub_dir, File.basename(result.output_file))
  end

  it "gets form, fail" do
    simple_setup
    full_path = test_file_path(sub_dir, "odm_1.xml")
    @object.import({identifier: "F_DM", filename: full_path, file_type: "1"}, @job)
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