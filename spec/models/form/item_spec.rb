require 'rails_helper'

describe Form::Item do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/item"
  end

  describe "Validations" do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, completion" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123§"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, note" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK§"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, ordinal" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = ""
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, optional" do
      result = Form::Item.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      result.optional = ""
      expect(result.valid?).to eq(false)
    end
    
  end
  
end
  