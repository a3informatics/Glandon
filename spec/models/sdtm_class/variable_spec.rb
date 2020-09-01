require 'rails_helper'
require 'tabulation' # Prevents circular reference in test

describe SdtmClass::Variable do

  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/sdtm_class/variable"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "sdtm/SDTM_Model_1-4.ttl"]
    load_files(schema_files, data_files)
  end

  it "validates a valid object" do
    item = SdtmClass::Variable.new
    item.uri = Uri.new(uri: "http://www.example.com/a#b")
    item.ordinal = 1
    result = item.valid?
    expect(item.rdf_type.to_s).to eq("http://www.assero.co.uk/Tabulation#SdtmClassVariable")
    expect(item.errors.empty?).to eq(true)
    expect(result).to eq(true)
  end

  it "does not validate an invalid object, ordinal" do
    item = SdtmClass::Variable.new
    item.uri = Uri.new(uri: "http://www.example.com/a#b")
    item.ordinal = -1
    result = item.valid?
    expect(item.errors.full_messages.to_sentence).to eq("Ordinal contains an invalid positive integer value")
    expect(result).to eq(false)
  end

  it "allows an object to be found" do
    item = SdtmClass::Variable.find(Uri.new(uri: "http://www.assero.co.uk/MDRSdtmMd/CDISC/V3#M-CDISC_SDTMMODELEVENTS_xxSCAT"))
    check_file_actual_expected(item.to_h, sub_dir, "find_input.yaml", equate_method: :hash_equal)
  end

end
  