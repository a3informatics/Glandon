require 'rails_helper'

describe OperationalReferenceV3::TucReferencesController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  
  describe "Update" do
  	
    login_curator

    def sub_dir
      return "controllers/operational_reference_v3"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      @tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
    end

    it "update" do
      update_params = {form_id: @form.id, label:"label u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      #@tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_1.yaml", equate_method: :hash_equal, write_file: true)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, label:"label u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_2.yaml", equate_method: :hash_equal, write_file: true)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, label:"label u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_3.yaml", equate_method: :hash_equal, write_file: true)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, label:"label ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_4.yaml", equate_method: :hash_equal, write_file: true)
    end

  end

end