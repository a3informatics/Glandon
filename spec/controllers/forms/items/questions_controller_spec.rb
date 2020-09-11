require 'rails_helper'

describe Forms::Items::QuestionsController do

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
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000150.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
      @question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
    end

    it "update" do
      update_params = {form_id: @form.id, label:"label u", note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      @question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, label:"label u", note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_2.yaml", equate_method: :hash_equal)
    end

    it 'update, locked by another user' do
      update_params = {form_id: @form.id, label:"label u", note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, label:"label u", note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_4.yaml", equate_method: :hash_equal)
    end

    # it 'update, coded' do
    #   request.env['HTTP_ACCEPT'] = "application/json"
    #   token = Token.obtain(@form, @user)
    #   audit_count = AuditTrail.count
    #   cl = Thesaurus::ManagedConcept.find_minimum(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457"))
    #   cli = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C74457/V10#C74457_C41259"))
    #   post :update_property, params:{id: @form.id, biomedical_concept_form: {has_coded_value: [{id: cli.id, context_id: cl.id}], property_id: @property.id}}
    #   expect(AuditTrail.count).to eq(audit_count+1)
    #   actual = check_good_json_response(response)
    #   check_file_actual_expected(actual, sub_dir, "update_question_expected_5.yaml", equate_method: :hash_equal)
    # end

  end

end