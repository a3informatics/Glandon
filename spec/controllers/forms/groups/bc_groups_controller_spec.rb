require 'rails_helper'

describe Forms::Groups::BcGroupsController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Update" do
  	
    login_curator

    def sub_dir
      return "controllers/forms/groups"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/CRF TEST 1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      @bc = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_BCG2"))
    end

    it "update" do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc.id, bc_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      @bc = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_BCG2"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc.id, bc_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @bc.id, bc_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc.id, bc_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc.id, bc_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down" do
    
    login_curator

    def sub_dir
      return "controllers/forms/groups"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Move up I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_group: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
    end

    it "Move up I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG1"))
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_group: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_bc_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      parent = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_group: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_bc_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Destroy" do
    
    login_curator

    def sub_dir
      return "controllers/forms/groups"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/CRF TEST 1.ttl", "forms/FN000150.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..38)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Destroy" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      group = Form::Group::Bc.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_BCG3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: group.id, bc_group: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "destroy_bc_group_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end