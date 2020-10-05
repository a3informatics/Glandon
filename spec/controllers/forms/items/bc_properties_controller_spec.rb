require 'rails_helper'

describe Forms::Items::BcPropertiesController do

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

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/CRF TEST 1.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
      @bc_property = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "update" do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u", enabled: false, optional: true} 
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      bc_property = Form::Item::BcProperty.find_full(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
      check_file_actual_expected(bc_property.to_h, sub_dir, "update_bc_property_expected_1a.yaml", equate_method: :hash_equal)
      put :update, params:{id: bc_property.id, bc_property: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_property_expected_1b.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc_property.id, bc_property: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @bc_property.id, bc_property: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_property_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc_property.id, bc_property: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_property_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @bc_property.id, bc_property: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_bc_property_expected_4.yaml", equate_method: :hash_equal)
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
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Move up I, BcProperty" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
    end

    it "Move up I, BcProperty, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_bc_property_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, BcProperty, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_bc_property_error_expected_2.yaml", equate_method: :hash_equal)
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
      data_files = ["forms/FN000150.ttl","forms/FN000120.ttl", "forms/CRF TEST 1.ttl","biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl" ]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..62)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F"))
    end

    it "Move down I, BcProperty" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
    end

    it "Move down I, BcProperty, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_bc_property_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move down I, BcProperty, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3_BP3"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG3"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_down, params:{id: item.id, bc_property: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_down_bc_property_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Make common item" do
    
    login_curator

    def sub_dir
      return "controllers/forms/items"
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

    it "Make common I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG1_BCG2_BP2"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      post :make_common, params:{id: item.id, bc_property: {form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
    end

    it "Make common I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::BcProperty.find(Uri.new(uri: "http://www.s-cubed.dk/CRF_TEST_1/V1#F_NG2_BCG1_BP3"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      post :make_common, params:{id: item.id, bc_property: {form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
    end

  end

end