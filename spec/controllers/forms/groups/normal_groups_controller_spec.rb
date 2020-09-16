require 'rails_helper'

describe Forms::Groups::NormalGroupsController do

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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000120.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      @normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
    end

    it "update" do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      @normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add child" do

    login_curator

    def sub_dir
      return "controllers/forms/groups"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000120.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      @normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it 'Add normal group' do
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      token = Token.obtain(@form, @user)
      post :add_child, params:{id: @normal.id, normal_group:{type: "normal_group", form_id: @form} }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual.to_h, sub_dir, "add_child_normal_group_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Add Bc group' do
      bci_1 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/WEIGHT/V1#BCI"))
      bci_2 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/BMI/V1#BCI"))
      bci_3 = BiomedicalConceptInstance.find(Uri.new(uri: "http://www.s-cubed.dk/RACE/V1#BCI"))
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      token = Token.obtain(@form, @user)
      post :add_child, params:{id: @normal.id, normal_group:{type: "bc_group", id_set: [bci_1.id,bci_2.id, bci_3.id ], form_id: @form} }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_normal_group_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end