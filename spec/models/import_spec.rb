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

  class Owner

    def short_name
      return "OWNER"
    end

  end

  class Other
  
    def self.owner
      return Owner.new
    end
  
    def self.configuration
      {identifier: "XXX"}
    end

  end

  class ImportTest < Import
    
    def import(params)
    end

    def self.configuration
      {
        description: "Import of Something",
        parent_klass: Other,
        reader_klass: Excel::AdamIgReader,
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
        reader_klass: Excel::AdamIgReader,
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
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    Import.destroy_all
    delete_all_public_test_files
  end

  after :each do
    Import.destroy_all
    delete_all_public_test_files
  end

  it "generates the import list" do
    results = Import.list
  #Xwrite_yaml_file(results, sub_dir, "import_list_1.yaml")
    expected = read_yaml_file(sub_dir, "import_list_1.yaml")
    expect(results).to hash_equal(expected)
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
    item.save_error_file({parent: worker, children: []})
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_1.yaml")
    compare_import_hash(result, expected, error_file: true)
  end

  it "loads the error file" do
    worker = Worker.new
    worker.errors.add(:base, "Bad things happened!")
    item = simple_import
    item.save_error_file({parent: worker, children:[]})
    result = item.load_error_file
  #Xwrite_yaml_file(result, sub_dir, "load_error_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "load_error_file_expected_1.yaml")
    expect(result).to hash_equal(expected, error_file: true)
  end

  it "saves the load file, auto load" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    #object.scopedIdentifier.namespace.id = 111
    item = simple_import
    item.auto_load = true
    item.save
    expect(TypePathManagement).to receive(:history_url).with(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    expect(object).to receive(:to_sparql_v2).and_return(SparqlUpdateV2.new)
    expect(CRUD).to receive(:file)
    item.save_load_file({parent: object, children: []})
    result = Import.find(item.id)
  #write_yaml_file(import_hash(result), sub_dir, "save_load_file_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "save_load_file_expected_1.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the load file, no auto load" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    #object.scopedIdentifier.namespace.id = 111
    item = simple_import
    expect(TypePathManagement).to receive(:history_url).with(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    expect(object).to receive(:to_sparql_v2).and_return(SparqlUpdateV2.new)
    item.save_load_file({parent: object, children: []})
    result = Import.find(item.id)
  #Xwrite_yaml_file(import_hash(result), sub_dir, "save_error_file_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "save_error_file_expected_2.yaml")
    compare_import_hash(result, expected, output_file: true)
  end

  it "saves the result" do
    object = Thesaurus.new
    object.rdf_type = "XXX"
    object.scopedIdentifier.identifier = "YYY"
    #object.scopedIdentifier.namespace.id = 111
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

end