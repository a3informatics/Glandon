require 'rails_helper'

describe Forms::Groups::NormalGroupsController do

  include DataHelpers
  include PauseHelpers
  include UserAccountHelpers
  include IsoHelpers
  include ControllerHelpers
  include SecureRandomHelpers
  include IsoManagedHelpers
  include BiomedicalConceptInstanceFactory

  def sub_dir
    return "controllers/forms/groups"
  end

  def make_standard(item)
    IsoManagedHelpers.make_item_standard(item)
  end
  
  describe "Update" do
  	
    login_curator

    before :all do
      data_files = ["forms/FN000120.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
      @normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "update" do
      request.env['HTTP_ACCEPT'] = "application/json"
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'update, second update so no audit' do
      request.env['HTTP_ACCEPT'] = "application/json"
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
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
      request.env['HTTP_ACCEPT'] = "application/json"
      update_params = {form_id: @form.id, note:"note u", completion:"completion u"} 
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_3.yaml", equate_method: :hash_equal)
    end

    it 'update, errors' do
      request.env['HTTP_ACCEPT'] = "application/json"
      update_params = {form_id: @form.id, note:"note u", completion:"completion ±±±"} 
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: @normal.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_4.yaml", equate_method: :hash_equal)
    end

    it "update second version" do
      request.env['HTTP_ACCEPT'] = "application/json"
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form1", identifier: "XXX")
      form.add_child({type:"normal_group"})
      normal_group = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/XXX/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      normal_group.add_child({type:"question"})
      make_standard(form)
      new_form = form.create_next_version
      new_form = Form.find_full(new_form.uri)
      update_params = {form_id: new_form.id, note:"note u", completion:"completion u"} 
      token = Token.obtain(new_form, @user)
      audit_count = AuditTrail.count
      put :update, params:{id: normal_group.id, normal_group: update_params}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "update_normal_expected_5.yaml", equate_method: :hash_equal)
    end

  end

  describe "Add child" do

    login_curator

    before :all do
      data_files = ["forms/FN000120.ttl", "biomedical_concept_instances.ttl", "biomedical_concept_templates.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it 'Add normal group' do
      request.env['HTTP_ACCEPT'] = "application/json"
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      audit_count = AuditTrail.count
      token = Token.obtain(@form, @user)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
      post :add_child, params:{id: normal.id, normal_group:{type: "normal_group", form_id: @form} }
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_child_normal_group_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Add Bc group' do
      request.env['HTTP_ACCEPT'] = "application/json"
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      normal = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG2"))
      bci_1 = create_biomedical_concept_instance("WEIGHT1", "WEIGHT")
      bci_2 = create_biomedical_concept_instance("BMI1", "BMI")
      bci_3 = create_biomedical_concept_instance("RACE1", "RACE")
      audit_count = AuditTrail.count
      token = Token.obtain(@form, @user)
      post :add_child, params:{id: normal.id, normal_group:{type: "bc_group", id_set: [bci_1.id,bci_2.id, bci_3.id], form_id: @form}}
      expect(AuditTrail.count).to eq(audit_count + 1)
      expect(JSON.parse(response.body).deep_symbolize_keys[:errors]).to eq(nil)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "add_child_normal_group_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Move up/down" do
    
    login_curator

    before :all do
      data_files = ["forms/FN000120.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
      @form = Form.find_minimum(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F"))
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "Move up I" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, normal_group: {parent_id: @form.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
    end

    it "Move up I, Error" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG1"))
      token = Token.obtain(@form, @user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, normal_group: {parent_id: @form.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_normal_error_expected_1.yaml", equate_method: :hash_equal)
    end

    it 'Move up I, Error locked by another user' do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      item = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/FN000120/V1#F_NG12"))
      token = Token.obtain(@form, @lock_user)
      audit_count = AuditTrail.count
      put :move_up, params:{id: item.id, normal_group: {parent_id: @form.id , form_id: @form.id}}
      expect(AuditTrail.count).to eq(audit_count)
      actual = check_error_json_response(response)
      check_file_actual_expected(actual.to_h, sub_dir, "move_up_normal_error_expected_2.yaml", equate_method: :hash_equal)
    end

  end

  describe "Destroy" do
    
    login_curator

    before :all do
      load_files(schema_files, [])
      load_data_file_into_triple_store("mdr_identification.ttl")
      @lock_user = ua_add_user(email: "lock@example.com")
      Token.delete_all
    end

    after :all do
      ua_remove_user("lock@example.com")
    end

    it "Destroy" do
      request.env['HTTP_ACCEPT'] = "application/json"
      request.content_type = 'application/json'
      allow(SecureRandom).to receive(:uuid).and_return(*SecureRandomHelpers.predictable)
      form = Form.create(label: "Form test 2", identifier: "Form test 2")
      form.add_child({type:"normal_group"})
      item = Form::Group::Normal.find(Uri.new(uri: "http://www.s-cubed.dk/Formtest2/V1#NG_1760cbb1-a370-41f6-a3b3-493c1d9c2238"))
      form = Form.find_minimum(form.uri)
      token = Token.obtain(form, @user)
      audit_count = AuditTrail.count
      delete :destroy, params:{id: item.id, normal_group: {parent_id: form.id , form_id: form.id}}
      expect(AuditTrail.count).to eq(audit_count+1)
      actual = check_good_json_response(response)
      check_file_actual_expected(actual, sub_dir, "destroy_normal_group_expected_1.yaml", equate_method: :hash_equal)
    end

  end

end