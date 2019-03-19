require 'rails_helper'

describe BiomedicalConcepts::PropertiesController do

  include DataHelpers
  include PauseHelpers
  
  describe "Curator User" do
    
    login_curator

    def sub_dir
      return "controllers/biomedical_concepts"
    end

    before :all do
      Token.delete_all
      AuditTrail.delete_all
      @lock_user = User.create :email => "lock@example.com", :password => "changeme" 
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    after :all do
      user = User.where(:email => "lock@example.com").first
      user.destroy
      AuditTrail.delete_all
    end

    it "gets the property, JSON" do  
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, { :id => "BC-ACME_BC_C25208_PerformedClinicalResult_baselineIndicator_BL_value", :property => { :namespace => "http://www.assero.co.uk/MDRBCs/V1" }}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_show.txt")
      expected = read_text_file_2(sub_dir, "property_show.txt")
      expect(response.body).to eq(expected)
    end

    it "prevents property being updated if not locked" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:question_text] = "New Q, no lock"
      the_params[:prompt_text] = "New P, no lock"
      the_params[:enabled] = "true"
      the_params[:collect]= "true"
      the_params[:format] = "11.1"
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
    #Xwrite_text_file_2(response.body, sub_dir, "property_update_no_lock.txt")
      expected = read_text_file_2(sub_dir, "property_update_no_lock.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows property to be updated" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:question_text] = "New Q"
      the_params[:prompt_text] = "New P"
      the_params[:enabled] = "true"
      the_params[:collect]= "true"
      the_params[:format] = "10.1"
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_update_1.txt")
      expected = read_text_file_2(sub_dir, "property_update_1.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count + 1)
    end
      
    it "allows property to be updated, not first" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:question_text] = "New Q + 1"
      the_params[:prompt_text] = "New P + 1"
      the_params[:enabled] = "false"
      the_params[:collect]= "false"
      the_params[:format] = "9.1"
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :update, params
      the_params[:question_text] = "New Q + 2"
      the_params[:prompt_text] = "New P + 2"
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :update, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_update_2.txt")
      expected = read_text_file_2(sub_dir, "property_update_2.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it "prevents terms being added if not locked" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      tc_refs = []
      tc_refs << { :subject_ref => {id: "CLI-C112450_C112714", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42" }, ordinal: 1}
      tc_refs << { :subject_ref => {id: "CLI-C106653_C107006", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42" }, ordinal: 2}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = tc_refs
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
    #Xwrite_text_file_2(response.body, sub_dir, "property_add_no_lock.txt")
      expected = read_text_file_2(sub_dir, "property_add_no_lock.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows terms to be added" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      tc_refs = []
      tc_refs << { :subject_ref => {id: "CLI-C112450_C112714", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42" }, ordinal: 1}
      tc_refs << { :subject_ref => {id: "CLI-C106653_C107006", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42" }, ordinal: 2}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = tc_refs
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_add_1.txt")
      expected = read_text_file_2(sub_dir, "property_add_1.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count + 1)
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    #Xwrite_yaml_file(bc.to_json, sub_dir, "property_add_1.yaml")
      expected = read_yaml_file(sub_dir, "property_add_1.yaml")
      expect(bc.to_json).to hash_equal(expected)      
    end
    
    it "does not create audit record if not first update, add" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      tc_refs = []
      tc_refs << { :subject_ref => {id: "CLI-C103476_C103696", namespace: "http://www.assero.co.uk/MDRThesaurus/CDISC/V42" }, ordinal: 1}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = tc_refs
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, params
      request.env['HTTP_ACCEPT'] = "application/json"
      post :add, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_add_2.txt")
      expected = read_text_file_2(sub_dir, "property_add_2.txt")
      expect(response.body).to eq(expected)
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    #Xwrite_yaml_file(bc.to_json, sub_dir, "property_add_2.yaml")
      expected = read_yaml_file(sub_dir, "property_add_2.yaml")
      expect(bc.to_json).to hash_equal(expected)      
      expect(AuditTrail.count).to eq(audit_count + 1)
    end   

    it "prevents terms being removed if not locked"  do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = []
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :remove, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("422")
    #Xwrite_text_file_2(response.body, sub_dir, "property_remove_no_lock.txt")
      expected = read_text_file_2(sub_dir, "property_remove_no_lock.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count)
    end

    it "allows terms to be removed" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      tc_refs = []
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = tc_refs
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :remove, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_remove_1.txt")
      expected = read_text_file_2(sub_dir, "property_remove_1.txt")
      expect(response.body).to eq(expected)
      expect(AuditTrail.count).to eq(audit_count + 1)
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    #Xwrite_yaml_file(bc.to_json, sub_dir, "property_remove_1.yaml")
      expected = read_yaml_file(sub_dir, "property_remove_1.yaml")
      expect(bc.to_json).to hash_equal(expected)      
    end

    it "does not create audit record if not first update, remove" do
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
      token = Token.obtain(bc, @user)
      audit_count = AuditTrail.count
      property = BiomedicalConceptCore::Property.find("BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", "http://www.assero.co.uk/MDRBCs/V1")
      the_params = {}
      tc_refs = []
      the_params[:namespace] = "http://www.assero.co.uk/MDRBCs/V1"
      the_params[:tc_refs] = tc_refs
      params = { id: "BC-ACME_BC_C25347_PerformedClinicalResult_baselineIndicator_BL_value", property: the_params }
      request.env['HTTP_ACCEPT'] = "application/json"
      post :remove, params
      request.env['HTTP_ACCEPT'] = "application/json"
      post :remove, params
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    #Xwrite_text_file_2(response.body, sub_dir, "property_remove_2.txt")
      expected = read_text_file_2(sub_dir, "property_remove_2.txt")
      expect(response.body).to eq(expected)
      bc = BiomedicalConceptCore.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    #Xwrite_yaml_file(bc.to_json, sub_dir, "property_remove_2.yaml")
      expected = read_yaml_file(sub_dir, "property_remove_2.yaml")
      expect(bc.to_json).to hash_equal(expected)   
      expect(AuditTrail.count).to eq(audit_count + 1)
    end   

  end

end