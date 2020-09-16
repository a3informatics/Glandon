require 'rails_helper'

describe Form::Group::Normal do
  
  include DataHelpers
  include SparqlHelpers

  def sub_dir
    return "models/form/group/bc"
  end

  describe "Add child" do
    
    before :each do
      data_files = ["forms/FN000150.ttl", "forms/VSTADIABETES.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
    end

    it "add child I, add common group" do
      bc_group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2"))
      result = bc_group.add_child({type:"common_group"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_1.yaml", equate_method: :hash_equal)
      bc_group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2"))
      result = bc_group.add_child({type:"common_group"})
      check_file_actual_expected(result.to_h, sub_dir, "add_child_expected_2.yaml", equate_method: :hash_equal)
    end

    # it "add child II, error" do
    #   bc_group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG2"))
    #   expect{bc_group.add_child({type:"x_group"})}.to raise_error(Errors::ApplicationLogicError, "Attempting to add an invalid child type")
    # end

  end
  
end
  