require 'rails_helper'

describe IsoRegistrationStatesController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_sys_admin

    it "sets database" do
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
      rs = IsoRegistrationState.all.first
      post :current, { old_id: "", new_id: rs.id}
      expect(response).to redirect_to("/")
    end

  end

  describe "Curator" do
    
    login_curator

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