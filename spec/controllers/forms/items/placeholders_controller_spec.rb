require 'rails_helper'

describe Forms::Items::PlaceholdersController do

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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/CRF TEST 1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      @placeholder = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_PL5"))
    end

    it "update" do
      update_params = {form_id: @form.id, label:"label u", free_text:"placeholder u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @placeholder.id, placeholder: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      @placeholder = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG3_PL5"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_placeholder_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, label:"label u", free_text:"placeholder u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @placeholder.id, placeholder: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @placeholder.id, placeholder: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_placeholder_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, label:"label u", free_text:"placeholder u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @placeholder.id, placeholder: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_placeholder_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, label:"label u", free_text:"placeholder ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @placeholder.id, placeholder: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_placeholder_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Destroy" do
    
    login_curator

    def sub_dir
      return "controllers/forms/items"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/CRF TEST 1.ttl", "forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    end

    it "Destroy" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "destroy_placeholder_expected_1.yaml", equate_method: :hash_equal)
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
      data_files = ["forms/FN000150.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    end

    it "Move up I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_placeholder_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Move up I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      put :move_up, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_placeholder_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_placeholder_error_expected_2.yaml", equate_method: :hash_equal)
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
      data_files = ["forms/FN000150.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    end

    it "Move down I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_placeholder_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Move down I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      put :move_down, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      put :move_down, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_placeholder_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move down I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Placeholder.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, placeholder: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_placeholder_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end