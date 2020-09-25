require 'rails_helper'

describe Form::Group do
  
  include DataHelpers
  include OdmHelpers

  def sub_dir
    return "models/form/group"
  end

  describe "Validations" do 

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
    end

    it "validates a valid object" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123"
      result.ordinal = 1
      expect(result.valid?).to eq(true)
    end

    it "does not validate an invalid object, completion" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK"
      result.completion = "Draft 123€"
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, note" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.note = "OK€"
      result.completion = "Draft 123"
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, optional" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.ordinal = 1
      result.optional = ""
      expect(result.valid?).to eq(false)
    end

    it "does not validate an invalid object, ordinal" do
      result = Form::Group.new
      result.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      result.ordinal = 0
      result.optional = true
      expect(result.valid?).to eq(false)
    end

  end

  describe "Destroy" do
    
    before :each do
      data_files = ["forms/FN000150.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "Delete Normal group" do
      group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      parent = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      expect(parent.has_group.count).to eq(1)
      result = group.delete(parent)
      parent = Form.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      expect(parent.has_group.count).to eq(0)
      expect{Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))}.to raise_error(Errors::NotFoundError, "Failed to find http://www.s-cubed.dk/FN000150/V1#F_NG1 in Form::Group::Normal.")
    end

    it "Delete Normal group" do
      group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      parent = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(parent.to_h[:has_group], sub_dir, "delete_expected_1.yaml", equate_method: :hash_equal)
      result = group.delete(parent)
      parent = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      check_file_actual_expected(parent.to_h[:has_group], sub_dir, "delete_expected_2.yaml", equate_method: :hash_equal)
    end

  end
  
end
  