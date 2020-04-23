require 'rails_helper'

describe Import do

	include DataHelpers
  include ImportHelpers
  include PublicFileHelpers

  def sub_dir
    return "models/import"
  end

  def simple_import
    item = ImportTest.new
    params = {files: ["xxx.txt"], auto_load: false, identifier: "AAA", file_type: "1"}
    #expect(item).to receive(:import).with(params, an_instance_of(Background)).and_raise(StandardError.new("error"))
    expect(item).to receive(:import).with(params).and_raise(StandardError.new("error"))
    item.create(params)
    return item
  end

  class NS

    def short_name
      return "OWNER"
    end

  end

  class Owner

    def ra_namespace
      return NS.new
    end

  end

  class Other

    def self.owner
      return Owner.new
    end

    def self.identifier
      "XXX"
    end

  end

  class ImportTest < Import

    def import(params)
    end

    def self.configuration
      {
        description: "Import of Something",
        parent_klass: Other,
        reader_klass: Excel,
        import_type: :TYPE,
        sheet_name: :main,
        version_label: :semantic_version,
        label: "XXX Implementation Guide"
      }
    end

    def configuration
      self.class.configuration
    end

  end

  class ImportTest2 < Import

    def import(params)
    end

    def self.configuration
      {
        description: "Import of Something",
        parent_klass: Other,
        reader_klass: Excel,
        import_type: :TYPE,
        sheet_name: :main,
        version_label: :date,
        label: "XXX Implementation Guide"
      }
    end

    def configuration
      self.class.configuration
    end

  end

  class Worker

    extend ActiveModel::Naming

    attr_reader   :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end

  end

  before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus.ttl"]
    load_files(schema_files, data_files)
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "distinguishes API" do
    expect(Import.api?({file_type: 0})).to be(false)
    expect(Import.api?({file_type: 1})).to be(false)
    expect(Import.api?({file_type: 2})).to be(false)
    expect(Import.api?({file_type: 3})).to be(true)
    expect(Import.api?({file_type: 4})).to be(false)
  end

  it "import params" do
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: ["fred.txt"], semantic_version: "1.0.0", file_type: "0")
    expect(object.errors.count).to eq(0)
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: ["fred.txt"], semantic_version: "1.0.0", file_type: "1")
    expect(object.errors.count).to eq(0)
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: ["fred.txt"], semantic_version: "1.0.0", file_type: "2")
    expect(object.errors.count).to eq(0)
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: [], semantic_version: "1.0.0", file_type: "3")
    expect(object.errors.count).to eq(0)
    object = Import.params_valid?(version: "1xx", date: "2019-12-01", files: ["something"], semantic_version: "1.0.0", file_type: "1")
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Version contains invalid characters, must be an integer")
    object = Import.params_valid?(version: "1", date: "crap", files: ["something"], semantic_version: "1.0.0", file_type: "1")
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Date contains invalid characters")
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: ["something"], semantic_version: "1.X", file_type: "1")
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Semantic version contains invalid characters")
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: [], semantic_version: "1.0.0", file_type: "1")
    expect(object.errors.count).to eq(1)
    expect(object.errors.full_messages.to_sentence).to eq("Files is empty, at least one file is required")
    object = Import.params_valid?(version: "1", date: "2019-12-01", files: [], semantic_version: "1.0.0", file_type: "3") # Empty files for API ok.
    expect(object.errors.count).to eq(0)
  end

  it "returns configuration" do
    expect(Import.configuration).to eq({})
  end

  it "generates the import list" do
    results = Import.list
    check_file_actual_expected(results, sub_dir, "import_list_1.yaml", equate_method: :hash_equal)
  end

  it "creates an import I" do
    item = ImportTest.new
    params = {files: ["xxx.txt"], auto_load: false, identifier: "AAA", file_type: "1", semantic_version: "3.3.3"}
    expected = params.dup
    expected[:version_label] = "3.3.3"
    expected[:label] = "XXX Implementation Guide"
    expected[:job] = an_instance_of(Background)
    expect(item).to receive(:import).with(expected) #, an_instance_of(Background))
    item.create(params)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "create_import_1.yaml")
    expected = read_yaml_file(sub_dir, "create_import_1.yaml")
    compare_import_hash(result, expected)
    background = Background.find(item.background_id)
    expect(background.description).to eq("Import of Something from ODM. Identifier: AAA, Owner: OWNER")
    expect(background.complete).to eq(false)
  end

  it "creates an import II" do
    item = ImportTest2.new
    params = {files: ["xxx.txt"], auto_load: false, identifier: "AAA", file_type: "1", semantic_version: "3.3.3", date: "2018-11-11"}
    expected = params.dup
    expected[:version_label] = "2018-11-11"
    expected[:label] = "XXX Implementation Guide"
    expected[:job] = an_instance_of(Background)
    expect(item).to receive(:import).with(expected) #, an_instance_of(Background))
    item.create(params)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "create_import_3.yaml")
    expected = read_yaml_file(sub_dir, "create_import_3.yaml")
    compare_import_hash(result, expected)
    background = Background.find(item.background_id)
    expect(background.description).to eq("Import of Something from ODM. Identifier: AAA, Owner: OWNER")
    expect(background.complete).to eq(false)
  end

  it "creates an import, exception" do
    item = ImportTest.new
    params = {files: ["xxx.txt"], auto_load: false, identifier: "AAA", file_type: "1"}
    #expect(item).to receive(:import).with(params, an_instance_of(Background)).and_raise(StandardError.new("error"))
    expect(item).to receive(:import).with(params).and_raise(StandardError.new("error"))
    item.create(params)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "create_import_2.yaml")
    expected = read_yaml_file(sub_dir, "create_import_2.yaml")
    compare_import_hash(result, expected, error_file: true)
    background = Background.find(item.background_id)
    expect(background.complete).to eq(true)
  end

  it "saves the error file" do
    worker = Worker.new
    worker.errors.add(:base, "Bad things happened!")
    item = simple_import
    item.save_error_file({parent: worker, managed_children: []})
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_1.yaml")
    compare_import_hash(result, expected, error_file: true)
  end

  it "loads the error file" do
    worker = Worker.new
    worker.errors.add(:base, "Bad things happened!")
    item = simple_import
    item.save_error_file({parent: worker, managed_children:[]})
    result = item.load_error_file
  #Xwrite_yaml_file(result, sub_dir, "load_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "load_error_file_expected_1.yaml")
    expect(result).to hash_equal(expected, error_file: true)
  end

  it "saves the load file, auto load - WILL CURRENTLY FAIL, NEEDS UPDATING" do
    object = Thesaurus.new
    object.has_identifier = IsoScopedIdentifierV2.new
    object.has_identifier.has_scope = IsoNamespace.find_by_short_name("CDISC")
    object.has_identifier.identifier = "YYY"
    object.uri = Uri.new(uri: "http://www.example.com/A#A")
    item = simple_import
    item.auto_load = true
    item.save
    expect(TypePathManagement).to receive(:history_url_v2).with(object)
    expect(object).to receive(:to_sparql).and_return([])
    expect(CRUD).to receive(:file)
    item.save_load_file({parent: object, managed_children: [], tags: []})
    result = Import.find(item.id)
  #write_yaml_file(import_hash(result), sub_dir, "save_load_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_load_file_expected_1.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the load file, no auto load" do
    object = Thesaurus.new
    object.has_identifier = IsoScopedIdentifierV2.new
    object.has_identifier.has_scope = IsoNamespace.find_by_short_name("CDISC")
    object.has_identifier.identifier = "YYY"
    object.uri = Uri.new(uri: "http://www.example.com/A#A")
    item = simple_import
    expect(TypePathManagement).to receive(:history_url_v2).with(object)
    expect(object).to receive(:to_sparql).and_return(SparqlUpdateV2.new)
    item.save_load_file({parent: object, managed_children: [], tags: []})
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_2.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the result" do
    object = Thesaurus.new
    object.has_identifier = IsoScopedIdentifierV2.new
    object.has_identifier.has_scope = IsoNamespace.find_by_short_name("CDISC")
    object.has_identifier.identifier = "YYY"
    object.uri = Uri.new(uri: "http://www.example.com/A#A")
    item = simple_import
    expect(TypePathManagement).to receive(:history_url_v2).with(object)
    item.save_result(object)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_result_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_result_expected_1.yaml")
    compare_import_hash(result, expected)
  end

  it "provides a description" do
    item = simple_import
    expect(item.description({identifier: "XXX"})).to eq("Import of Something from ODM. Identifier: XXX, Owner: OWNER")
  end

  it "indicates if the background job is complete" do
    item = simple_import
    expect(item.complete).to eq(true)
    background = Background.find(item.background_id)
    background.complete = false
    background.save
    expect(item.complete).to eq(false)
  end

  it "Provides a human readable form of the file type" do
    expect(ImportTest.file_type_humanize(0)).to eq("Excel")
    expect(ImportTest.file_type_humanize(1)).to eq("ODM")
    expect(ImportTest.file_type_humanize(2)).to eq("ALS")
    item = ImportTest.new
    item.file_type = :excel
    expect(item.file_type_humanize).to eq("Excel")
    item.file_type = :odm
    expect(item.file_type_humanize).to eq("ODM")
    item.file_type = :als
    expect(item.file_type_humanize).to eq("ALS")
  end

	it "Show data hash" do
		object = Import.new(:type => "Import::CdiscTerm") # Use this rather than above.
    job = Background.new
		job.complete = true
    job.save
    object.background_id = job.id
    object.save

		import_data = object.show_data
		expect(import_data.keys).to eq([:import, :errors, :job])
		expect(import_data[:import][:id]).to eq(object.id)
		expect(import_data[:job][:id]).to eq(job.id)
		expect(import_data[:errors]).to eq([])
		expect(import_data[:import][:complete]).to eq(true)
		expect(import_data[:job][:complete]).to eq(true)
	end

	it "Show data hash, errors" do
		worker = Worker.new
    worker.errors.add(:base, "Bad things happened!")
		item = simple_import
		item.save_error_file({parent: worker, managed_children:[]})

		import_data = item.show_data
		expect(import_data.keys).to eq([:import, :errors, :job])
		expect(import_data[:errors]).to eq(["Bad things happened!"])
		expect(import_data[:job][:id]).to eq(item.background_id)
		expect(import_data[:import][:id]).to eq(item.id)
	end

end
