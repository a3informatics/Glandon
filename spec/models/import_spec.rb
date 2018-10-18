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
    params = {filename: "xxx.txt", auto_load: false, identifier: "AAA", file_type: "1"}
    expect(item).to receive(:import).with(params, an_instance_of(Background)).and_raise(StandardError.new("error"))
    item.create(params)
    return item
  end

  class ImportTest < Import
    C_IMPORT_OWNER = "OWNER"
    C_IMPORT_TYPE = "TYPE"
    C_IMPORT_DESC = "DESCRIPTION"
    def import(params, test)
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
    clear_triple_store
    Import.destroy_all
    delete_all_public_test_files
    import_type(ImportTest::C_IMPORT_TYPE)
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "generates the import list" do
    results = Import.list
  #write_yaml_file(results, sub_dir, "import_list_1.yaml")
    expected = read_yaml_file(sub_dir, "import_list_1.yaml")
    expect(results).to hash_equal(expected)
  end
  
  it "creates an import" do
    item = ImportTest.new
    params = {filename: "xxx.txt", auto_load: false, identifier: "AAA", file_type: "1"}
    expect(item).to receive(:import).with(params, an_instance_of(Background))
    item.create(params)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "create_import_1.yaml")
    expected = read_yaml_file(sub_dir, "create_import_1.yaml")
    compare_import_hash(result, expected)
    background = Background.find(item.background_id)
    expect(background.description).to eq("DESCRIPTION from ODM. Identifier: AAA, Owner: OWNER")
    expect(background.complete).to eq(false)    
  end
  
  it "creates an import, exception" do
    item = ImportTest.new
    params = {filename: "xxx.txt", auto_load: false, identifier: "AAA", file_type: "1"}
    expect(item).to receive(:import).with(params, an_instance_of(Background)).and_raise(StandardError.new("error"))
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
    item.save_error_file(worker)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_1.yaml")
    compare_import_hash(result, expected, error_file: true)
  end

  it "loads the error file" do
    worker = Worker.new
    worker.errors.add(:base, "Bad things happened!")
    item = simple_import
    item.save_error_file(worker)
    result = item.load_error_file
  #Xwrite_yaml_file(result, sub_dir, "load_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "load_error_file_expected_1.yaml")
    expect(result).to hash_equal(expected, error_file: true)
  end

  it "saves the load file, auto load" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    object.scopedIdentifier.namespace.id = 111
    item = simple_import
    item.auto_load = true
    item.save
    expect(TypePathManagement).to receive(:history_url).with(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    expect(object).to receive(:to_sparql_v2).and_return({s: "subject", p: "predicate", o: "object"})
    expect(CRUD).to receive(:update).with("{:s=>\"subject\", :p=>\"predicate\", :o=>\"object\"}")
    item.save_load_file(object)
    result = Import.find(item.id)
  #write_yaml_file(import_hash(result), sub_dir, "save_load_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_load_file_expected_1.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the load file, no auto load" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    object.scopedIdentifier.namespace.id = 111
    item = simple_import
    expect(TypePathManagement).to receive(:history_url).with(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    expect(object).to receive(:to_sparql_v2).and_return({s: "subject", p: "predicate", o: "object"})
    item.save_load_file(object)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_2.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the result" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    object.scopedIdentifier.namespace.id = 111
    item = simple_import
    expect(TypePathManagement).to receive(:history_url).with(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    item.save_result(object)
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_result_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_result_expected_1.yaml")
    compare_import_hash(result, expected)
  end

  it "provides a description" do
    item = simple_import
    expect(item.description).to eq("DESCRIPTION from ODM. Identifier: AAA, Owner: OWNER")
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

end