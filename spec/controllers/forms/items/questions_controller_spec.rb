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
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: {question_text: "something", optional: false, form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      @question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text u"} 
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
      update_params = {form_id: @form.id, note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text u"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      update_params = {form_id: @form.id, note:"note u", completion:"completion u", datatype: "string u", format:"2", mapping:"mapping u", question_text:"question_text ±±±"} 
      request.env['HTTP_ACCEPT'] = "application/json"
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @question.id, question: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_question_expected_4.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add child" do

    login_curator

    def sub_dir
      return "controllers/forms/items"
    end

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "forms/FN000120.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..15)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      @question = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12_NG3_Q2"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it 'Add cli' do
      cli_1 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V4#C66789_C49484"))
      cli_2 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66790/V4#C66790_C17998"))
      cli_3 = Thesaurus::UnmanagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66790/V4#C66790_C43234"))
      context_1 = Thesaurus::ManagedConcept.find(Uri.new(uri: "http://www.cdisc.org/C66789/V13#C66789"))
      request.env['HTTP_ACCEPT'] = "application/json"
      audit_count = AuditTrail.count
      token = Token.obtain(@form, @user)
      post :add_child, params:{id: @question.id, question:{type: "tuc_reference",id_set:[{id:cli_1.id, context_id: context_1.id}, {id: cli_2.id, context_id: context_1.id}, {id: cli_3.id, context_id: context_1.id}], form_id: @form.id} }
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_child_question_expected_1.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down" do
    
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
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F"))
    end

    it "Move up I, Question" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q4"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, question: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_expected_1.yaml", equate_method: :hash_equal)
    end

    it "Move up I, Question, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_Q1"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, question: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Question, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Item::Question.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1_PL2"))
      parent = Form::Group.find(Uri.new(uri: "http://www.s-cubed.dk/FN000150/V1#F_NG1"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, question: {parent_id: parent.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

end