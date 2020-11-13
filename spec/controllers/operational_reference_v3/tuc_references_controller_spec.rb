require 'rails_helper'

describe OperationalReferenceV3::TucReferencesController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers

  def make_standard(item)
    params = {}
    params[:registration_status] = "Standard"
    params[:previous_state] = "Incomplete"
    item.update_status(params)
  end
  
  describe "Update" do
  	
    login_curator

    def sub_dir
      return "controllers/operational_reference_v3"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      @tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
    end

    it "update" do
      update_params = {form_id: @form.id, local_label:"label u", enabled: false, optional: true} 
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_1.yaml", equate_method: :hash_equal)
    end

    it "update second version" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      question.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]})
      make_standard(form)
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#F"))
      check_file_actual_expected(form.to_h, sub_dir, "update_tuc_reference_expected_5a.yaml", equate_method: :hash_equal)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded_TUC1"))
      update_params = {form_id: new_form.id, local_label:"New label", enabled: false, optional: true} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(new_form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_5b.yaml", equate_method: :hash_equal)
      form = Form.find_full(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#F"))
      check_file_actual_expected(form.to_h, sub_dir, "update_tuc_reference_expected_5a.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, local_label:"label u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, local_label:"label u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, local_label:"label ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @tuc_reference.id, tuc_reference: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_tuc_reference_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Destroy" do
    
    login_curator

    def sub_dir
      return "controllers/operational_reference_v3"
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    before :all do
      data_files = ["forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    end

    it "Delete" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1_TUC1"))
      parent = Form::Item.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: tuc_reference.id, tuc_reference: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "destroy_tuc_reference_expected_1.yaml", equate_method: :hash_equal)
    end

    it "delete second version" do
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      parent = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded"))
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681_C49508"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C25681/V1#C25681"))
      parent.add_child({type:"tuc_reference", id_set:[{id:cli_1.id, context_id: context_1.id}]})
      make_standard(form)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      tuc_reference = OperationalReferenceV3::TucReference.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#Q_4646b47a-4ae4-4f21-b5e2-565815c8cded_TUC1"))
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(new_form, @user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: tuc_reference.id, tuc_reference: {parent_id: parent.id , form_id: new_form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "destroy_tuc_reference_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end