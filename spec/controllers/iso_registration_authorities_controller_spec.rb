require 'rails_helper'

describe IsoRegistrationAuthoritiesController do

  include DataHelpers
  
  before :all do
    clear_triple_store
    load_test_file_into_triple_store("IsoNamespace.ttl")
  end
  
  describe "Authrorized User" do
  	
    login_sys_admin

    it "index registration authorities" do
      ras = IsoRegistrationAuthority.all
      get :index
      expect(assigns(:registrationAuthorities).to_json).to eq(ras.to_json)
      expect(assigns(:owner).to_json).to eq(ras[0].to_json)
      expect(response).to render_template("index")
    end

    it "new registration authority" do
      ra = IsoRegistrationAuthority.new
      namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
      get :new
      expect(assigns(:namespaces)).to eq(namespaces)
      expect(response).to render_template("new")
    end

    it 'creates registration authority' do
      namespaces = IsoNamespace.all
      post :create, iso_registration_authority: { :namespaceId => namespaces[0].id, :number => "222233334" }
      expect(IsoRegistrationAuthority.all.count).to eq(3)
    end

    it 'deletes registration authority' do
      delete :destroy, :id => "RA-111111111"
      expect(IsoRegistrationAuthority.all.count).to eq(2)
    end

  end

  describe "Unauthorized User" do
    
    it "index registration authority" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "new registration authority" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'creates namespace' do
      namespaces = IsoNamespace.all
      post :create, iso_registration_authority: { :namespaceId => namespaces[0].id, :number => "222233334" }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end