require 'rails_helper'

describe Form::Crf do
  
  sub_dir = "models/form"

  include DataHelpers

  def sub_dir
    return "models/form"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("form_example_crf.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "save data as YAML" do
    form = Form.find("F-ACME_CRFTest" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    write_hash_to_yaml_file_2(form.to_json, sub_dir, "example_crf.yaml")
  end

  it "displays a CRF as HTML" do
    form = Form.find("F-ACME_CRFTest" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form::Crf.create(form.to_json, nil, {:annotate => false})
    write_text_file_2(result, sub_dir, "example_crf.txt")
    expected = read_text_file_2(sub_dir, "example_crf.txt")
    expect(result).to eq(expected)
  end

  it "displays a aCRF as HTML" do
    form = Form.find("F-ACME_CRFTest" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
    write_text_file_2(result, sub_dir, "example_acrf.txt")
    expected = read_text_file_2(sub_dir, "example_acrf.txt")
    expect(result).to eq(expected)
    expect(true).to eq(false)
  end

end
  