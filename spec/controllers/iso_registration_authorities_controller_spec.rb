require 'rails_helper'

describe IsoRegistrationAuthoritiesController do

  include DataHelpers
  include IsoHelpers
  
  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
  end
  
  describe "Authrorized User" do
  	
    login_curator

    it "index registration authorities" do
      ras = IsoRegistrationAuthority.all.each {|ra| ra.ra_namespace_objects}
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
      post :create, iso_registration_authority: { :namespace_id => namespaces[0].id, :organization_identifier => "222233334" }
      expect(IsoRegistrationAuthority.all.count).to eq(3)
    end

    it 'deletes registration authority' do
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      delete :destroy, :id => IsoRegistrationAuthority.all.first.id
      expect(IsoRegistrationAuthority.all.count).to eq(1)
    end

    it "deletes registration authority, doesn't exist" do
      id = IsoRegistrationAuthority.all.first.id
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      delete :destroy, :id => id
      expect(IsoRegistrationAuthority.all.count).to eq(1)
      delete :destroy, :id => id
      expect(flash[:error]).to be_present
    end

    it "deletes registration authority, used" do
      ra = IsoRegistrationAuthority.all.first
      IsoHelpers.mark_as_used(ra.uri)
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      delete :destroy, :id => ra.id
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      expect(flash[:error]).to be_present
    end

  end

  describe "Unauthorized User" do
    
    login_sys_admin

    it "index registration authority" do
      get :index
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it "new registration authority" do
      get :new
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

    it 'creates namespace' do
      namespaces = IsoNamespace.all
      post :create, iso_registration_authority: { :namespaceId => namespaces[0].id, :number => "222233334" }
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do
    
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