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
      ras = IsoRegistrationAuthority.all.each {|ra| ra.ra_namespace_objects}.sort_by{|x| x.organization_identifier}
      namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
      get :index
      expected_ras = assigns(:registrationAuthorities).map{|x| x.to_h}
      actual_ras = ras.map{|x| x.to_h}
      expect(expected_ras).to hash_equal(actual_ras)
      expect(assigns(:owner).to_h).to eq(ras.last.to_h)
      expect(assigns(:namespaces)).to eq(namespaces)
      expect(response).to render_template("index")
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

    it "deletes registration authority, not found" do
      namespaces = IsoNamespace.all
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      post :create, iso_registration_authority: { :namespace_id => namespaces[0].id, :organization_identifier => "222233334" }
      expect(IsoRegistrationAuthority.all.count).to eq(3)
      ra = IsoRegistrationAuthority.where(organization_identifier:"222233334")
      delete :destroy, :id => ra.first.id
      expect(IsoRegistrationAuthority.all.count).to eq(2)
      delete :destroy, :id => ra.first.id
      expect(flash[:error]).to be_present
      expect(IsoRegistrationAuthority.all.count).to eq(2)
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
