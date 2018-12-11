require 'rails_helper'

describe Excel::TabularReader do
	
	include DataHelpers

	def sub_dir
    return "models/concerns/excel/tabular_reader"
  end

	before :each do
    clear_triple_store
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
      @children = []
      @ordinal = 0
    end

    def to_hash
      result = {ct: self.ct, ct_notes: self.ct_notes, label: self.label, ordinal: self.ordinal}
      result[:datatype] = datatype.to_json
      result[:compliance] = compliance.to_json
      return result
    end

  end

  class TrsParentClass < IsoManaged

    attr_accessor :children

    def initialize
      super
      @children = []
    end

    def to_hash
      result = super
      children.each {|c| result[:children] << c.to_hash}
      return result
    end

  end

  class TopClass < IsoManaged

    attr_accessor :children

    def initialize
      super
      @children = []
    end

    def to_hash
      result = super
      children.each {|c| result[:children] << c.to_hash}
      return result
    end

  end

      
  it "initialize object, success" do
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::TabularReader.new(full_path) 
    expect(object.errors.count).to eq(0)
  end

  it "process engine, no errors" do
    params = 
    {
      label: "label", identifier: "XXX", semantic_version: "1.1.1", version_label: "version label", version: 1, date: "2018-01-01", 
      excel: {import: :test_1, sheet: :sheet_1}
    }
    full_path = test_file_path(sub_dir, "read_input_1.xlsx")
    object = Excel::TabularReader.new(full_path) 
    result = object.read(TopClass, params)
  #Xwrite_yaml_file(result, sub_dir, "read_expected_1.yaml")
    expected = read_yaml_file(sub_dir, "read_expected_1.yaml")
    expect(result).to operation_hash_equal(expected)
    expect(object.errors.count).to eq(0)
  end

end