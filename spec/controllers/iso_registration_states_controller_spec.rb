require 'rails_helper'

describe IsoRegistrationStatesController do

  include DataHelpers
  
  describe "Authorized User" do
  	
    login_content_admin

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "iso_scoped_identifier.ttl"]
      load_files(schema_files, data_files)
    end

    it 'makes an item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs = IsoRegistrationState.all.first
      post :current, params:{ old_id: "", new_id: rs.id}
      rs = IsoRegistrationState.all.first
      expect(rs.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

  end

  describe "Curator" do
    
    login_curator

    before :each do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "form_example_general.ttl"]
      load_files(schema_files, data_files)
    end

    it 'updates an item' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      mi = IsoManaged.find("F-ACME_T2", "http://www.assero.co.uk/MDRForms/ACME/V1")
      post :update, params:{ id: "#{mi.registrationState.id}", iso_registration_state: { mi_id: mi.id, mi_namespace: mi.namespace, 
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
      post :update, params:{ id: "#{mi.registrationState.id}", iso_registration_state: { mi_id: mi.id, mi_namespace: mi.namespace,
        registrationStatus: "X", previousState: "Standard"  , administrativeNote: "X1", unresolvedIssue: "X2"  }}
      new_mi = IsoManaged.find(mi.id, mi.namespace)
      new_rs = new_mi.registrationState
      expect(new_rs.to_json).to eq(mi.registrationState.to_json)
      expect(response).to redirect_to("/registration_states")
    end

    it 'makes an item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs = IsoRegistrationState.all.first
      post :current, params:{ old_id: "", new_id: rs.id}
      updated_rs = IsoRegistrationState.find(rs.id)
      expect(updated_rs.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

    it 'makes another item current' do
      @request.env['HTTP_REFERER'] = 'http://test.host/registration_states'
      rs1 = IsoRegistrationState.all[0]
      rs2 = IsoRegistrationState.all[1]
      rs2.registrationStatus = "Standard"
      post :current, params:{ old_id: "", new_id: rs1.id}
      updated_rs1 = IsoRegistrationState.find(rs1.id)
      expect(updated_rs1.current).to eq(true)
      post :current, params:{ old_id: rs1.id, new_id: rs2.id}
      updated_rs1 = IsoRegistrationState.find(rs1.id)
      updated_rs2 = IsoRegistrationState.find(rs2.id)
      expect(updated_rs1.current).to eq(false)
      expect(updated_rs2.current).to eq(true)
      expect(response).to redirect_to("/registration_states")
    end

  end

  describe "Unauthorized User" do
    
    login_sys_admin

    it 'makes a registration state current' do
      post :current, params:{ old_id: "", new_id: "X"}
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do
    
    it 'makes a registration state current' do
      post :current, params:{ old_id: "", new_id: "X"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end