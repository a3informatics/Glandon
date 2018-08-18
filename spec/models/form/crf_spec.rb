require 'rails_helper'

describe Form::Crf do
  
  include DataHelpers

  def sub_dir
    return "models/form/crf"
  end

  before :all do
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
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("CT_V49.ttl")
    load_test_file_into_triple_store("form_crf_test_1.ttl")
    load_test_file_into_triple_store("form_example_fields.ttl")
    load_test_file_into_triple_store("ACME_ANNO 2_1.ttl")
    load_test_file_into_triple_store("ACME_ANNO 3_1.ttl")
    load_test_file_into_triple_store("ACME_ANNO 4_1.ttl")
    load_test_file_into_triple_store("ACME_ANNO_1.ttl")
    load_test_file_into_triple_store("ACME_BC C17634_2.ttl")
    load_test_file_into_triple_store("ACME_BC C25206_1.ttl")
    load_test_file_into_triple_store("ACME_BC C25206_4.ttl")
    load_test_file_into_triple_store("ACME_BC C25208_1.ttl")
    load_test_file_into_triple_store("ACME_BC C25208_2.ttl")
    load_test_file_into_triple_store("ACME_BC C25298_1.ttl")
    load_test_file_into_triple_store("ACME_BC C25299_1.ttl")
    load_test_file_into_triple_store("ACME_BC C25347_1.ttl")
    load_test_file_into_triple_store("ACME_BC C49677_1.ttl")
    load_test_file_into_triple_store("ACME_BC C81255_1.ttl")
    load_test_file_into_triple_store("ACME_VS Domain.ttl")
    load_test_file_into_triple_store("ACME_LB Domain.ttl")
    load_test_file_into_triple_store("ACME_Topic.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
  end

  it "displays a CRF as HTML" do
    form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form::Crf.create(form.to_json, nil, {:annotate => false})
  #write_text_file_2(result, sub_dir, "example_crf.txt")
    expected = read_text_file_2(sub_dir, "example_crf.txt")
    expect(result).to eq(expected)
  end

  it "displays a aCRF as HTML" do
    form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
  #write_text_file_2(result, sub_dir, "example_acrf_1.txt")
    expected = read_text_file_2(sub_dir, "example_acrf_1.txt")
    expect(result).to eq(expected)
  end

  it "displays a aCRF as HTML, all field types" do
    form = Form.find("F-ACME_TEST" , "http://www.assero.co.uk/MDRForms/ACME/V1")
    result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
  #write_text_file_2(result, sub_dir, "example_acrf_2.txt")
    expected = read_text_file_2(sub_dir, "example_acrf_2.txt")
    expect(result).to eq(expected)
  end

  it "displays as aCRF as HTML, parallel processing" do
    ["F-ACME_ANNO", "F-ACME_ANNO2", "F-ACME_ANNO3", "F-ACME_ANNO4"].each_with_index do |f, index|
      file_index = index + 3
    puts "File index: #{file_index}"
      form = Form.find(f, "http://www.assero.co.uk/MDRForms/ACME/V1")
      result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
    #write_text_file_2(result, sub_dir, "example_acrf_#{file_index}.txt")
      expected = read_text_file_2(sub_dir, "example_acrf_#{file_index}.txt")
      expect(result).to eq(expected)
    end
  end

end
  