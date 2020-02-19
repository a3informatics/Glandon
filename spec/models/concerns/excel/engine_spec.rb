require 'rails_helper'

describe Excel::Engine do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/engine"
  end

	before :each do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    @child_object = ChildClass.new
  end

  # Local Classes
  #
  # Care needs to be taken when doing this. DO NOT USE production rdf_types from the schemas
  # Declare new types in the test.ttl file if necessary 
  class DefinitionClass < Fuseki::Base

    configure rdf_type: "http://www.assero.co.uk/Fake" # This is OK. Not declared in schema .ttl files
    data_property :label

    # Need to fake this as we are not loading any schema triples for this test
    full_path = Rails.root.join "spec/fixtures/files/models/concerns/excel/engine/schema.yaml"
    schema = YAML.load_file(full_path)
    Fuseki::Base.class_variable_set(:@@schema, Fuseki::Schema::SchemaMap.new(schema))
    
    def to_hash
      {label: self.label}
    end

    def to_json
      to_hash
    end

  end

  class EET1Class < IsoConceptV2

    object_property :collection, cardinality: :many, model_class: "DefinitionClass"
    object_property :tagged, cardinality: :many, model_class: "DefinitionClass"

    def to_hash
      {label: self.label}
    end

    def property_target(name)
      return DefinitionClass
    end

  end

  class EET2Class < IsoConceptV2

    object_property :collection, cardinality: :many, model_class: "DefinitionClass"

    def to_hash
      {label: self.label}
    end

  end

  class ChildClass < IsoConceptV2
    
    object_property :compliance, cardinality: :one, model_class: "DefinitionClass"
    object_property :datatype, cardinality: :one, model_class: "DefinitionClass"
    attr_accessor :ct
    attr_accessor :ct_notes
    attr_accessor :label
    attr_accessor :ordinal
    attr_accessor :tagged

    def initialize
      @ct = ""
      @ct_notes = ""
      @label = ""
      @ordinal = 0
      @children = []
      @tagged = []
      super
    end

    def to_hash
      result = {ct: self.ct, ct_notes: self.ct_notes, label: self.label, ordinal: self.ordinal}
      result[:datatype] = datatype.to_json
      result[:compliance] = compliance.to_json
      return result
    end

    def add_tag_no_save(tag)
      @tagged << tag
    end

  end

  class ParentClass < IsoManagedV2

    attr_accessor :label
    attr_accessor :children
    attr_accessor :has_identifier

    def initialize
      @label = ""
      @children = []
      @has_identifier = nil
      super
    end

    def to_hash
      result = {label: self.label, children: [], scoped_identifier: has_identifier.to_h}
      children.each {|c| result[:children] << c.to_hash}
      return result
    end

    def property_target(name)
      return DefinitionClass
    end

  end

  def parent_set_hash(object)
    result = []
    object.parent_set.each {|k,c| result << c.to_hash}
    return result
  end

  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "new_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(object.parent_set). to eq({})
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, empty, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 2, true)
    expect(result).to eq("")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, empty, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 2, false)
    expect(result).to eq("")
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Empty cell detected in row 4 column 2.")    
  end

  it "checks a cell, full, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 1, true)
    expect(result).to eq("3")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, full, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 1, false)
    expect(result).to eq("3")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell for empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.cell_empty?(4, 1)
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(0)
    result = object.cell_empty?(4, 2)
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell for blank and not blank" do
    full_path = test_file_path(sub_dir, "check_values_input_4.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.column_blank?({row: 4, col: 1})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(0)
    result = object.column_not_blank?({row: 4, col: 1})
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
    result = object.column_blank?({row: 4, col: 2})
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
    result = object.column_not_blank?({row: 4, col: 2})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(0)
    result = object.column_blank?({row: 2, col: [2, 3]})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(0)
    result = object.column_blank?({row: 3, col: [2, 3]})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(0)
    result = object.column_blank?({row: 4, col: [2, 3]})
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell for affirmative" do
    full_path = test_file_path(sub_dir, "check_values_input_3.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    (2..7).each do |row|
      result = object.column_affirmative?({row: row, col: 3})
      expected = row <= 4 ? true : false
      expect(result).to eq(expected)
      expect(parent.errors.count).to eq(0)
    end
  end

  it "checks a cell for smart quotes" do
    full_path = test_file_path(sub_dir, "check_values_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(2 ,8)
    expect(result).to eq("During Phase 1, sufficient information about the drug's pharmacokinetics")
    result = object.check_value(3 ,8)
    expect(result).to eq("'ll'")
    result = object.check_value(4 ,8)
    expect(result).to eq("\"xxx\"")    
    result = object.check_value(5 ,8)
    expect(result).to eq("")    
  end

  it "checks a cell for integer" do
    full_path = test_file_path(sub_dir, "check_values_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(6 ,8)
    expect(result).to eq("1")
    result = object.check_value(7 ,8)
    expect(result).to eq("2")
  end

  it "checks a cell, empty, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 2, true)
    expect(result).to eq("")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a C code" do
    full_path = test_file_path(sub_dir, "check_values_input_5.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(object.c_code?(row: 2, col: 1)).to eq(true)
    expect(parent.errors.count).to eq(0)
    expect(object.c_code?(row: 11, col: 1)).to eq(false)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("C Code 'C12X' error detected in row 11 column 1.")
  end

  it "checks regex" do
    full_path = test_file_path(sub_dir, "check_values_input_5.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(object.regex?(row: 2, col: 1, additional: {regex: "\\AC[0-9]{3,6}\\z"})).to eq(true)
    expect(parent.errors.count).to eq(0)
    expect(object.regex?(row: 11, col: 1, additional: {regex: "\\AC[0-9]{3,6}\\z"})).to eq(false)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages[0]).to eq("Format of 'C12X' error detected in row 11 column 1.")
    expect(object.regex?(row: 9, col: 1, additional: {regex: "\\AS[0-9]{6}\\z"})).to eq(false)
    expect(parent.errors.count).to eq(2)
    expect(parent.errors.full_messages[1]).to eq("Format of 'S1234567' error detected in row 9 column 1.")
    expect(object.regex?(row: 3, col: 1, additional: {regex: "\\ASN[0-9]{6}|C[0-9]{3,6}\\z"})).to eq(true)
    expect(object.regex?(row: 5, col: 1, additional: {regex: "\\ASN[0-9]{6}|C[0-9]{3,6}\\z"})).to eq(true)
    expect(object.regex?(row: 10, col: 1, additional: {regex: "\\ASN[0-9]{6}|C[0-9]{3,6}\\z"})).to eq(false)
    expect(parent.errors.count).to eq(3)
    expect(parent.errors.full_messages[2]).to eq("Format of 'SN123' error detected in row 10 column 1.")
    expect(object.regex?(row: 11, col: 1, additional: {regex: "\\ASN[0-9]{6}|C[0-9]{3,6}\\z"})).to eq(false)
    expect(parent.errors.count).to eq(4)
    expect(parent.errors.full_messages[3]).to eq("Format of 'C12X' error detected in row 11 column 1.")
  end

  it "checks row condition" do
    full_path = test_file_path(sub_dir, "check_values_input_3.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook)
    logic = Rails.configuration.imports[:processing][:test_8][:sheets][:sheet_1]
    (2..4).each do |row|
      result = object.process_row?(logic, row)
      expect(result).to eq(true)
      expect(parent.errors.count).to eq(0)
    end
    (5..7).each do |row|
      result = object.process_row?(logic, row)
      expect(result).to eq(false)
      expect(parent.errors.count).to eq(0)
    end
  end

  it "checks sheet condition, I" do
    full_path = test_file_path(sub_dir, "process_sheet_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook)
    logic = 
    {
      sheet: 
      { 
        actions: 
        [ 
          { method: :tag_from_sheet_name,
            additional: { path: ["CDISC"] },
            map: { ADaM: ["ADaM"], CDASH: ["CDASH", "XXX"], SDTM: ["SDTM"] }
          }
        ]
      }
    }
    tag_a = IsoConceptSystem::Node.new(pref_label: "SDTM TAG", uri: Uri.new(uri: "http://www.example.com/path#a"))
    tag_b = IsoConceptSystem::Node.new(pref_label: "OTHER TAG", uri: Uri.new(uri: "http://www.example.com/path#b"))
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "CDASH"]).and_return(tag_a)
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "XXX"]).and_return(tag_b)
    object.process_sheet(logic)
    expect(object.tags).to match_array([tag_a, tag_b])
  end

  it "checks sheet condition, II" do
    full_path = test_file_path(sub_dir, "process_sheet_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook)
    logic = 
    {
      sheet: 
      { 
        actions: 
        [ 
          { method: :tag_from_sheet_name,
            additional: { path: ["CDISC"] },
            map: { ADaM: ["ADaM"], CDash: ["CDASH"], SDTM: ["SDTM"] }
          }
        ]
      }
    }
    object.process_sheet(logic)
    expect(object.tags).to eq([])
  end

  it "tag from sheet name, I" do
    full_path = test_file_path(sub_dir, "process_sheet_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "CDASH"]).and_return({tag: "A"})
    result = object.tag_from_sheet_name({additional: { path: ["CDISC"] }, map: {CDASH: ["CDASH"], x: ["X"]}})
    expect(result).to eq([{:tag=>"A"}])
    result = object.tag_from_sheet_name({additional: { path: ["CDISC"] }, map: {cdash: ["XXX"], x: ["X"]}})
    expect(result).to eq([])
  end

  it "tag from sheet name, II" do
    full_path = test_file_path(sub_dir, "process_sheet_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "QS"]).and_return({tag: "QS"})
    result = object.tag_from_sheet_name({additional: { path: ["CDISC"] }, map: {"QS T": ["QS"], "QS FT T": ["QS-FT"]}})
    expect(result).to eq([{:tag=>"QS"}])
  end

  it "tag from sheet name, III" do
    full_path = test_file_path(sub_dir, "process_sheet_input_3.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "QS-FT"]).and_return({tag: "QS-FT"})
    result = object.tag_from_sheet_name({additional: { path: ["CDISC"] }, map: {"QS T": ["QS"], "QS-FT T": ["QS-FT"]}})
    expect(result).to eq([{:tag=>"QS-FT"}])
  end

  it "set tagged property" do
    full_path = test_file_path(sub_dir, "process_sheet_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(IsoConceptSystem).to receive(:path).with(["CDISC", "CDASH"]).and_return({tag: "A"})
    result = object.tag_from_sheet_name({additional: { path: ["CDISC"] }, map: {CDASH: ["CDASH"], x: ["X"]}})
    expect(result).to eq([{:tag=>"A"}])
    result = object.set_tags({object: parent})
    expect(parent.tagged).to eq([{:tag=>"A"}])
  end

  it "set column tag" do
    full_path = test_file_path(sub_dir, "set_column_tag_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    child = ChildClass.new
    expect(IsoConceptSystem).to receive(:path).with(["X", "Y", "tag_1"]).and_return({tag: "A"})
    expect(IsoConceptSystem).to receive(:path).with(["X", "Y", "tag_2"]).and_return(nil)
    result = object.set_column_tag({row: 2, col: 1, object: child, map: {Y: "tag_1"}, additional: {path: ["X", "Y"]}})
    expect(parent.errors.count).to eq(0)
    expect(child.tagged).to eq([{:tag=>"A"}])
    child = ChildClass.new
    result = object.set_column_tag({row: 2, col: 1, object: child, map: {Y: "tag_2"}, additional: {path: ["X", "Y"]}})
    expect(parent.errors.count).to eq(0)
    expect(child.tagged).to eq([])
    child = ChildClass.new
    result = object.set_column_tag({row: 3, col: 1, object: child, map: {Y: "tag_1"}, additional: {path: ["X", "Y"]}})
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'Yes' error detected in row 3 column 1.")
    expect(child.tagged).to eq([])
    parent.errors.clear
    child = ChildClass.new
    result = object.set_column_tag({row: 4, col: 1, object: child, map: {Y: "tag_1"}, additional: {path: ["X", "Y"]}})
    expect(parent.errors.count).to eq(3)
    expect(parent.errors.full_messages.to_sentence).to eq("Empty cell detected in row 4 column 1., Empty cell detected in row 4 column 1., and Mapping of '' error detected in row 4 column 1.")
    expect(child.tagged).to eq([])
    parent.errors.clear
    child = ChildClass.new
    result = object.set_column_tag({row: 4, col: 1, object: child, can_be_empty: true, map: {Y: "tag_2"}, additional: {path: ["X", "Y"]}})
    expect(parent.errors.count).to eq(0)
    expect(child.tagged).to eq([])
  end

  it "creates parent" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent({row: 2, col: 1, map: {P1: "IDENT_1", P2: "IDENT_2"}, klass: "ParentClass"}) {|result| the_result = result}
    expect(the_result).to be_a(ParentClass)
    result = parent_set_hash(object)
    check_file_actual_expected(result, sub_dir, "process_parent_expected_1.yaml", equate_method: :hash_equal)
    expect(parent.errors.count).to eq(0)
  end

  it "creates parent, no mapping" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent({row: 2, col: 1, map: {}, klass: "ParentClass"}) {|result| the_result = result}
    result = parent_set_hash(object)
    check_file_actual_expected(result, sub_dir, "process_parent_expected_2.yaml", equate_method: :hash_equal)
    expect(parent.errors.count).to eq(0)
  end

  it "creates parent, mapping error" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent({row: 2, col: 1, map: {PX: "IDENT_1", PY: "IDENT_2"}, klass: "ParentClass"}) {|result| the_result = result}
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_parent_expected_4.yaml")
    expected = read_yaml_file(sub_dir, "process_parent_expected_4.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'P1' error detected in row 2 column 1.")
  end

  it "creates parent, identifier error" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent({row: 6, col: 1, map: {P1: "IDENT_1", P2: "IDENT_2"}, klass: "ParentClass"}) {|result| the_result = result}
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_parent_expected_3.yaml")
    expected = read_yaml_file(sub_dir, "process_parent_expected_3.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(2)
    expect(parent.errors.full_messages.to_sentence).to eq("Empty cell detected in row 6 column 1. and Mapping of '' error detected in row 6 column 1.")
  end

  it "creates child" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_child({row: 2, col: 1, map: {}, klass: "ChildClass"}) {|result| the_result = result}
    expect(the_result).to be_a(ChildClass)
    expect(parent.errors.count).to eq(0)
  end

  it "creates definition, non exists" do
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(parent.collection.count).to eq(0)
    object.create_definition(parent, "collection", "Expected")
    expect(parent.collection.count).to eq(1)
    expect(parent.collection.first).to be_a(DefinitionClass)
    expect(parent.collection.first.label).to eq("Expected")
    expect(parent.errors.count).to eq(0)
  end

  it "creates definition, exists" do
    DefinitionClass.create(label: "Expected", uri: Uri.new(uri: "http://www.example.com/temp#expected"))
    result = DefinitionClass.all
    expect(result.count).to eq(1)
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(parent.collection.count).to eq(0)
    object.create_definition(parent, "collection", "Expected")
    expect(parent.collection.count).to eq(1)
    expect(parent.collection.first).to be_a(DefinitionClass)
    expect(parent.collection.first.label).to eq("Expected")
    expect(parent.collection.first.uri).to eq(result.first.uri)
    expect(parent.errors.count).to eq(0)
  end

  it "create classification, non exists" do
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_classification({row: 2, col: 1, object: parent, map: {A: "This is A", B: "This is B", C: "This is C"}, property: "collection"})
    expect(parent.collection.count).to eq(1)
    result = parent.collection[0]
    expect(result).to be_a(DefinitionClass)
    expect(result.label).to eq("This is A")
    expect(parent.errors.any?).to eq(false)
    object.create_classification({row: 4, col: 1, object: parent, map: {A: "This is A", B: "This is B", C: "This is C"}, property: "collection"})
    expect(parent.collection.count).to eq(2)
    result = parent.collection[0]
    expect(result).to be_a(DefinitionClass)
    expect(result.label).to eq("This is A")
    expect(parent.errors.any?).to eq(false)
    expect(parent.errors.any?).to eq(false)
    object.create_classification({row: 5, col: 1, object: parent, map: {A: "This is A", B: "This is B", C: "This is C"}, property: "collection"})
    expect(parent.collection.count).to eq(2)
    expect(parent.errors.any?).to eq(true)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'ERROR' error detected in row 5 column 1.")
  end

  it "returns the classification, exists" do
    exists_1 = DefinitionClass.create(label: "This is X", uri: Uri.new(uri: "http://www.example.com/temp#X"))
    exists_2 = DefinitionClass.create(label: "This is Y", uri: Uri.new(uri: "http://www.example.com/temp#Y"))
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(2)
    expect(parent.collection.count).to eq(0)
    object.create_classification({row: 2, col: 2, object: parent, map: {X: "This is X", Y: "This is Y"}, property: "collection"})
    expect(parent.collection.count).to eq(1)
    result = parent.collection[0]
    expect(result).to be_a(DefinitionClass)
    expect(result.label).to eq("This is X")
    expect(result.uri).to eq(exists_1.uri)
    expect(parent.errors.any?).to eq(false)
    object.create_classification({row: 3, col: 2, object: parent, map: {X: "This is X", Y: "This is Y"}, property: "collection"})
    expect(parent.collection.count).to eq(2)
    result = parent.collection[1]
    expect(result).to be_a(DefinitionClass)
    expect(result.label).to eq("This is Y")
    expect(result.uri).to eq(exists_2.uri)
    expect(parent.errors.any?).to eq(false)
    object.create_classification({row: 4, col: 2, object: parent, map: {X: "This is X", Y: "This is Y"}, property: "collection"})
    expect(parent.collection.count).to eq(2)
    expect(parent.errors.any?).to eq(true)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'NONE' error detected in row 4 column 2.")
  end

  it "tokenize to property" do
    full_path = test_file_path(sub_dir, "tokenize_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.tokenize_and_set_property({row: 2, col: 1, object: parent, map: {}, property: "collection", additional: {token: ","}})
    expect(parent.collection.count).to eq(2)
    expect(parent.collection[0]).to eq("C12345")
    expect(parent.collection[1]).to eq("C12346")
    object.tokenize_and_set_property({row: 4, col: 1, object: parent, map: {}, property: "collection", additional: {token: ","}})
    expect(parent.collection.count).to eq(7) # Results are combined
    expect(parent.collection[2]).to eq("C1234")
    expect(parent.collection[3]).to eq("")
    expect(parent.collection[4]).to eq("C12354")
    expect(parent.collection[5]).to eq("C1234")
    expect(parent.collection[6]).to eq("C124456")
  end

  it "property with default" do
    full_path = test_file_path(sub_dir, "property_with_default_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    child = ChildClass.new
    object.set_property_with_default({row: 2, col: 1, object: child, map: {}, property: "label", additional: {default: "default"}})
    expect(child.label).to eq("A set string")
    object.set_property_with_default({row: 3, col: 1, object: child, map: {}, property: "label", additional: {default: "default"}})
    expect(child.label).to eq("default")
  end

  it "checks valid" do
    full_path = test_file_path(sub_dir, "tokenize_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    other = EET2Class.new
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    expect(parent.errors.count).to eq(0)
    
    expect(other).to receive(:valid?).and_return(true)
    object.check_valid({object: other})
    expect(parent.errors.count).to eq(0)
    
    other.errors.add(:base, "Error added.")
    expect(other).to receive(:valid?).and_return(false)
    object.check_valid({object: other})
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Row . Error added.")  
  end

  it "checks c codes" do
    full_path = test_file_path(sub_dir, "tokenize_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    result = object.c_codes?({row: 2, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
    result = object.c_codes?({row: 3, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(true)
    expect(parent.errors.count).to eq(0)
    result = object.c_codes?({row: 4, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages[0]).to eq("C Code ' ' error detected in row 4 column 1.")
    result = object.c_codes?({row: 5, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(2)
    expect(parent.errors.full_messages[1]).to eq("C Code 'C12E' error detected in row 5 column 1.")
    result = object.c_codes?({row: 6, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(3)
    expect(parent.errors.full_messages[2]).to eq("C Code 'C1234 C4567' error detected in row 6 column 1.")
    result = object.c_codes?({row: 7, col: 1, object: parent, additional: {token: ","}, can_be_empty: false})
    expect(result).to eq(false)
    expect(parent.errors.count).to eq(4)
    expect(parent.errors.full_messages[3]).to eq("Empty cell detected in row 7 column 1.")
  end

  it "can create multiple shared definitions, I" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.tokenize_and_create_shared({row: 2, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}})
    expect(parent.collection.count).to eq(3)
    expect(parent.collection[0].label).to eq("A")
    expect(parent.collection[1].label).to eq("B")
    expect(parent.collection[2].label).to eq("C")
  end

  it "can create multiple shared definitions, II" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.tokenize_and_create_shared({row: 4, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}})
    expect(parent.collection.count).to eq(4)
    expect(parent.collection[0].label).to eq("C")
    expect(parent.collection[1].label).to eq("D:E:F")
    expect(parent.collection[2].label).to eq("G")
    expect(parent.collection[3].label).to eq("H")
  end

  it "can create multiple shared definitions, III" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.tokenize_and_create_shared({row: 5, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}})
    expect(parent.collection.count).to eq(0)
  end

  it "can create multiple shared definitions, IV" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.tokenize_and_create_shared({row: 7, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}})
    object.tokenize_and_create_shared({row: 8, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}})
    expect(parent.collection.count).to eq(2)
    expect(parent.collection[0].label).to eq("A")
    expect(parent.collection[1].label).to eq("B")
  end
  
  it "can create shared definitions, I" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.create_shared({row: 4, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}, can_be_empty: true})
    expect(parent.collection.count).to eq(1)
    expect(parent.collection[0].label).to eq("C;D:E:F ;  G ; H;")
  end

  it "can create shared definitions, II" do
    full_path = test_file_path(sub_dir, "tokenize_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET2Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = DefinitionClass.all
    expect(result.count).to eq(0)
    object.create_shared({row: 5, col: 1, object: parent, map: {X: "This is X", Y: "This is Y"}, 
      property: "collection", additional: {token: ";"}, can_be_empty: true})
    expect(parent.collection.count).to eq(0)
  end

  it "returns the CT Reference" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.ct_reference({row: 2, col: 3, object: @child_object, map: {}, property: "ct"})
    expect(@child_object.ct).to eq("X1X")
    object.ct_reference({row: 3, col: 3, object: @child_object, map: {}, property: "ct"})
    expect(@child_object.ct).to eq("")
    object.ct_reference({row: 4, col: 3, object: @child_object, map: {}, property: "ct"})
    expect(@child_object.ct).to eq("")
    object.ct_reference({row: 5, col: 3, object: @child_object, map: {}, property: "ct"})
    expect(@child_object.ct).to eq("")
    object.ct_reference({row: 6, col: 3, object: @child_object, map: {}, property: "ct"})
    expect(@child_object.ct).to eq("")
  end

  it "returns the CT Other information" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.ct_other({row: 2, col: 3, object: @child_object, map: {}, property: "ct_notes"})
    expect(@child_object.ct_notes).to eq("")
    object.ct_other({row: 3, col: 3, object: @child_object, map: {}, property: "ct_notes"})
    expect(@child_object.ct_notes).to eq("(X1")
    object.ct_other({row: 4, col: 3, object: @child_object, map: {}, property: "ct_notes"})
    expect(@child_object.ct_notes).to eq("X1)")
    object.ct_other({row: 5, col: 3, object: @child_object, map: {}, property: "ct_notes"})
    expect(@child_object.ct_notes).to eq("X1")
  end

  it "returns the sheet info, I" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.sheet_info(:cdisc_adam_ig, :main)
    check_file_actual_expected(result, sub_dir, "sheet_info_expected_1.yaml", equate_method: :hash_equal)
  end

  it "returns the sheet info, II" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.sheet_info(:sponsor_term_format_one, :version_2)
    check_file_actual_expected(result, sub_dir, "sheet_info_expected_2.yaml", equate_method: :hash_equal)
  end

  it "returns the sheet info, III" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.sheet_info(:sponsor_term_format_one, :version_3)
    check_file_actual_expected(result, sub_dir, "sheet_info_expected_3.yaml", equate_method: :hash_equal)
  end

  it "process engine, no errors" do
    full_path = test_file_path(sub_dir, "process_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.process(:test_1, :sheet_1)
    result = parent_set_hash(object)
    check_file_actual_expected(result, sub_dir, "process_expected_1.yaml", equate_method: :hash_equal)
    expect(parent.errors.count).to eq(0)
  end

  it "process engine, parent map missing" do
    full_path = test_file_path(sub_dir, "process_input_2.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.process(:test_2, :sheet_1)
    result = parent_set_hash(object)
    check_file_actual_expected(result, sub_dir, "process_expected_2.yaml", equate_method: :hash_equal)
    expect(parent.errors.count).to eq(20)
    check_file_actual_expected(parent.errors.full_messages.to_yaml, sub_dir, "process_errors_2.yaml", equate_method: :hash_equal)
  end

  it "process engine, no errors with conditional" do
    full_path = test_file_path(sub_dir, "process_input_3.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = EET1Class.new
    object = Excel::Engine.new(parent, workbook) 
    object.process(:test_3, :sheet_1)
    result = parent_set_hash(object)
    check_file_actual_expected(result, sub_dir, "process_expected_3.yaml", equate_method: :hash_equal)
    expect(parent.errors.count).to eq(0)
  end

end