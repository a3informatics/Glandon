require 'rails_helper'

describe Form::Crf do
  
  include DataHelpers

  def sub_dir
    return "models/form/crf"
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "ACME_FN000150_1.ttl", "ACME_VSTADIABETES_1.ttl","ACME_FN000120_1.ttl" ]
    load_files(schema_files, data_files)
  end

  # before :all do
  #   data_files = 
  #   [
  #     "iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl", 
  #     "form_crf_test_1.ttl", "ACME_ANNO 2_1.ttl", "ACME_ANNO 3_1.ttl", "ACME_ANNO 4_1.ttl", "ACME_ANNO_1.ttl", "form_example_fields.ttl",
  #     "ACME_BC C25298_1.ttl", "ACME_BC C25299_1.ttl", "ACME_BC C25206_1.ttl", "ACME_BC C25206_4.ttl",
  #     "ACME_BC C25208_1.ttl", "ACME_BC C25208_2.ttl", "ACME_BC C25347_1.ttl", "ACME_BC C17634_2.ttl",
  #     "ACME_BC C49677_1.ttl", "ACME_BC C81255_1.ttl",
  #     "ACME_VS Domain.ttl", "ACME_LB Domain.ttl", "ACME_Topic.ttl"
  #   ]
  #   load_files(schema_files, data_files)
  #   load_cdisc_term_versions((1..59))
  #   clear_iso_concept_object
  #   clear_iso_namespace_object
  #   clear_iso_registration_authority_object
  #   clear_iso_registration_state_object
  # end

  # it "displays a CRF as HTML" do
  #   form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   result = Form::Crf.create(form.to_json, nil, {:annotate => false})
  # #write_text_file_2(result, sub_dir, "example_crf.txt")
  #   expected = read_text_file_2(sub_dir, "example_crf.txt")
  #   expect(result).to eq(expected)
  # end

  # it "displays a aCRF as HTML" do
  #   form = Form.find("F-ACME_CRFTEST1" , "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
  # #write_text_file_2(result, sub_dir, "example_acrf_1.txt")
  #   expected = read_text_file_2(sub_dir, "example_acrf_1.txt")
  #   expect(result).to eq(expected)
  # end

  # it "displays a aCRF as HTML, all field types" do
  #   form = Form.find("F-ACME_TEST" , "http://www.assero.co.uk/MDRForms/ACME/V1")
  #   result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
  # #write_text_file_2(result, sub_dir, "example_acrf_2.txt")
  #   expected = read_text_file_2(sub_dir, "example_acrf_2.txt")
  #   expect(result).to eq(expected)
  # end

  # it "displays as aCRF as HTML, parallel processing" do
  #   ["F-ACME_ANNO", "F-ACME_ANNO2", "F-ACME_ANNO3", "F-ACME_ANNO4"].each_with_index do |f, index|
  #     file_index = index + 3
  #   puts "File index: #{file_index}"
  #     form = Form.find(f, "http://www.assero.co.uk/MDRForms/ACME/V1")
  #     result = Form::Crf.create(form.to_json, form.annotations, {:annotate => true})
  #   #write_text_file_2(result, sub_dir, "example_acrf_#{file_index}.txt")
  #     expected = read_text_file_2(sub_dir, "example_acrf_#{file_index}.txt")
  #     expect(result).to eq(expected)
  #   end
  # end

end
  