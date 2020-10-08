require 'rails_helper'

describe Forms::Items::MappingsController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Update" do
  	
    login_curator

    def sub_dir
      return "controllers/forms/items"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000120.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      @mapping = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12_MA1"))
    end

    it "update" do
      update_params = {form_id: @form.id, label:"label u", mapping:"mapping u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @mapping.id, mapping: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      @mapping = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12_MA1"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_mapping_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, label:"label u", mapping:"mapping u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @mapping.id, mapping: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @mapping.id, mapping: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_mapping_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, label:"label u", mapping:"mapping u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @mapping.id, mapping: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_mapping_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, label:"label u", mapping:"mapping ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @mapping.id, mapping: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_mapping_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up" do
    
    login_curator

    def sub_dir
      return "controllers/forms/items"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Move up I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_mapping_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Move up I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      put :move_up, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      put :move_up, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_mapping_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_mapping_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move down" do
    
    login_curator

    def sub_dir
      return "controllers/forms/items"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Move up I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_mapping_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Move up I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      put :move_down, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      put :move_down, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_mapping_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Mapping.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_MA3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, mapping: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_mapping_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end