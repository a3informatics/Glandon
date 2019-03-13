require 'rails_helper'

describe IsoRegistrationStatesController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_content_admin

    before :all do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_scoped_identifier.ttl")
    end

    it "index registration states" do
      registration_states = IsoRegistrationState.all
      get :index
      expect(assigns(:registration_states).to_json).to eq(registration_states.to_json)
      expect(response).to render_template("index")
    end

    it 'makes an item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs = IsoRegistrationState.all.first
      post :current, { old_id: "", new_id: rs.id}
      rs = IsoRegistrationState.all.first
      expect(rs.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

  end

  describe "Curator" do
    
    login_curator

    before :all do
    clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      load_test_file_into_triple_store("BC.ttl")
    end

    it 'updates an item' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      mi = IsoManaged.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
      post :update, { id: "#{mi.registrationState.id}", iso_registration_state: { mi_id: mi.id, mi_namespace: mi.namespace, 
        registrationStatus: "Retired"  , previousState: "Standard"  , administrativeNote: "X1", unresolvedIssue: "X2"  }}
      mi = IsoManaged.find(mi.id, mi.namespace)
      updated_rs = mi.registrationState
      rs = IsoRegistrationState.new
      rs.registrationStatus = "Retired"   
      rs.previousState = "Standard"   
      rs.administrativeNote = "X1" 
      rs.unresolvedIssue = "X2" 
      rs.id = "RS-ACME_T2-1"
      rs.registrationAuthority = mi.registrationState.registrationAuthority
      expect(updated_rs.to_json).to eq(rs.to_json)
      expect(response).to redirect_to("/registration_states")
    end

    it 'prevents updates with invalid data' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      mi = IsoManaged.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
      post :update, { id: "#{mi.registrationState.id}", iso_registration_state: { mi_id: mi.id, mi_namespace: mi.namespace,
        registrationStatus: "X", previousState: "Standard"  , administrativeNote: "X1", unresolvedIssue: "X2"  }}
      new_mi = IsoManaged.find(mi.id, mi.namespace)
      new_rs = new_mi.registrationState
      expect(new_rs.to_json).to eq(mi.registrationState.to_json)
      expect(response).to redirect_to("/registration_states")
    end

    it 'makes an item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs = IsoRegistrationState.all.first
      post :current, { old_id: "", new_id: rs.id}
      updated_rs = IsoRegistrationState.find(rs.id)
      expect(updated_rs.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

    it 'makes another item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs1 = IsoRegistrationState.all[0]
      rs2 = IsoRegistrationState.all[1]
      rs2.registrationStatus = "Standard"
      post :current, { old_id: "", new_id: rs1.id}
      updated_rs1 = IsoRegistrationState.find(rs1.id)
      expect(updated_rs1.current).to eq(true)
      post :current, { old_id: rs1.id, new_id: rs2.id}
      updated_rs1 = IsoRegistrationState.find(rs1.id)
      updated_rs2 = IsoRegistrationState.find(rs2.id)
      expect(updated_rs1.current).to eq(false)
      expect(updated_rs2.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

  end

  describe "Unauthorized User" do
    
    login_sys_admin

    it "index registration state" do
      get :index
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it 'makes a registration state current' do
      post :current, { old_id: "", new_id: "X"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do
    
    it "index registration state" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'makes a registration state current' do
      post :current, { old_id: "", new_id: "X"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end