require 'rails_helper'

describe Excel do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/engine"
  end

	before :each do
    clear_triple_store
    @child_object = ChildClass.new
  end

  class ScopedIdentifierClass
    extend ActiveModel::Naming
    attr_accessor :identifier

    def initialize
      @identifier = ""
    end

    def to_hash
      return {identifier: self.identifier}
    end

  end

  class ChildClass
    extend ActiveModel::Naming
    attr_accessor :compliance
    attr_accessor :datatype
    attr_accessor :ct
    attr_accessor :ct_notes
    attr_accessor :label
    attr_accessor :ordinal

    def initialize
      @compliance = nil
      @datatype = nil
      @ct = ""
      @ct_notes = ""
      @label = ""
      @ordinal = 0
      @children = []
    end

    def to_hash
      result = {ct: self.ct, ct_notes: self.ct_notes, label: self.label, ordinal: self.ordinal}
      result[:datatype] = datatype.to_json
      result[:compliance] = compliance.to_json
      return result
    end

  end

  class ParentClass
    extend ActiveModel::Naming
    attr_accessor :label
    attr_accessor :children
    attr_accessor :scopedIdentifier

    def initialize
      @label = ""
      @children = []
      @scopedIdentifier = ScopedIdentifierClass.new
    end

    def to_hash
      result = {label: self.label, children: [], scoped_identifier: scopedIdentifier.to_hash}
      children.each {|c| result[:children] << c.to_hash}
      return result
    end

  end

  class Test
    extend ActiveModel::Naming
    attr_reader :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
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
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    expect(object.parent_set). to eq({})
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, empty, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 2, true)
    expect(result).to eq("")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, empty, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 2, false)
    expect(result).to eq("")
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Empty cell detected in row 4 column 2.")    
  end

  it "checks a cell, full, permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 1, true)
    expect(result).to eq("3")
    expect(parent.errors.count).to eq(0)
  end

  it "checks a cell, full, not permitted to be empty" do
    full_path = test_file_path(sub_dir, "check_values_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.check_value(4, 1, false)
    expect(result).to eq("3")
    expect(parent.errors.count).to eq(0)
  end

  it "creates parent" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent(2, 1, nil, {P1: "IDENT_1", P2: "IDENT_2"}, "ParentClass") {|result| the_result = result}
    expect(the_result).to be_a(ParentClass)
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_parent_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "process_parent_expected_1.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(0)
  end

  it "creates parent, mapping error" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent(2, 1, nil, {}, "ParentClass") {|result| the_result = result}
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_parent_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "process_parent_expected_2.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("No create map detected in row 2 column 1.")
  end

  it "creates parent, identifier error" do
    the_result = nil
    full_path = test_file_path(sub_dir, "create_parent_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_parent(6, 1, nil, {P1: "IDENT_1", P2: "IDENT_2"}, "ParentClass") {|result| the_result = result}
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
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.create_child(2, 1, nil, {}, "ChildClass") {|result| the_result = result}
    expect(the_result).to be_a(ChildClass)
    expect(parent.errors.count).to eq(0)
  end

  it "returns the compliance" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.core_classification(2, 1, @child_object, {A: "This is A", B: "This is B", C: "This is C"}, "compliance")
    expect(@child_object.compliance).to be_a(SdtmModelCompliance)
    expect(@child_object.compliance.label).to eq("This is A")
    expect(parent.errors.any?).to eq(false)
    object.core_classification(4, 1, @child_object, {A: "This is A", B: "This is B", C: "This is C"}, "compliance")
    expect(@child_object.compliance).to be_a(SdtmModelCompliance)
    expect(@child_object.compliance.label).to eq("This is C")
    expect(parent.errors.any?).to eq(false)
    object.core_classification(5, 1, @child_object, {A: "This is A", B: "This is B", C: "This is C"}, "compliance")
    expect(@child_object.compliance).to be_nil
    expect(parent.errors.any?).to eq(true)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'ERROR' error detected in row 5 column 1.")
  end

  it "returns the datatype" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.datatype_classification(2, 2, @child_object, {X: "This is X", Y: "This is Y"}, "datatype")
    expect(result).to be_a(SdtmModelDatatype)
    expect(result.label).to eq("This is X")
    expect(parent.errors.any?).to eq(false)
    result = object.datatype_classification(3, 2, @child_object, {X: "This is X", Y: "This is Y"}, "datatype")
    expect(result).to be_a(SdtmModelDatatype)
    expect(result.label).to eq("This is Y")
    expect(parent.errors.any?).to eq(false)
    result = object.datatype_classification(4, 2, @child_object, {X: "This is X", Y: "This is Y"}, "datatype")
    expect(result).to be_nil
    expect(parent.errors.any?).to eq(true)
    expect(parent.errors.count).to eq(1)
    expect(parent.errors.full_messages.to_sentence).to eq("Mapping of 'NONE' error detected in row 4 column 2.")
  end

  it "returns the CT Reference" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.ct_reference(2, 3, @child_object, {}, "ct")
    expect(@child_object.ct).to eq("X1X")
    object.ct_reference(3, 3, @child_object, {}, "ct")
    expect(@child_object.ct).to eq("")
    object.ct_reference(4, 3, @child_object, {}, "ct")
    expect(@child_object.ct).to eq("")
    object.ct_reference(5, 3, @child_object, {}, "ct")
    expect(@child_object.ct).to eq("")
    object.ct_reference(6, 3, @child_object, {}, "ct")
    expect(@child_object.ct).to eq("")
  end

  it "returns the CT Other information" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.ct_other(2, 3, @child_object, {}, "ct_notes")
    expect(@child_object.ct_notes).to eq("")
    object.ct_other(3, 3, @child_object, {}, "ct_notes")
    expect(@child_object.ct_notes).to eq("(X1")
    object.ct_other(4, 3, @child_object, {}, "ct_notes")
    expect(@child_object.ct_notes).to eq("X1)")
    object.ct_other(5, 3, @child_object, {}, "ct_notes")
    expect(@child_object.ct_notes).to eq("X1")
  end

  it "returns the sheet info" do
    full_path = test_file_path(sub_dir, "datatypes_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    result = object.sheet_info(:adam_ig, :main)
  #Xwrite_yaml_file(result, sub_dir, "sheet_info_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "sheet_info_expected_1.yaml")
    expect(result).to eq(expected)
  end

  it "process engine, no errors" do
    full_path = test_file_path(sub_dir, "process_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.process(:test_1, :sheet_1)
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "process_expected_1.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(0)
  end

  it "process engine, parent map missing" do
    full_path = test_file_path(sub_dir, "process_input_1.xlsx")
    workbook = Roo::Spreadsheet.open(full_path.to_s, extension: :xlsx) 
    parent = Test.new
    object = Excel::Engine.new(parent, workbook) 
    object.process(:test_2, :sheet_1)
    result = parent_set_hash(object)
  #Xwrite_yaml_file(result, sub_dir, "process_expected_2.yaml")
    expected = read_yaml_file(sub_dir, "process_expected_2.yaml")
    expect(result).to eq(expected)
    expect(parent.errors.count).to eq(16)
  #Xwrite_yaml_file(parent.errors.full_messages.to_yaml, sub_dir, "process_errors_2.yaml")
    expected = read_yaml_file(sub_dir, "process_errors_2.yaml")
    expect(parent.errors.full_messages.to_yaml).to eq(expected)
  end

end