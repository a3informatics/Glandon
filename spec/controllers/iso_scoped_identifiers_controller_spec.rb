require 'rails_helper'

describe IsoScopedIdentifiersController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_sys_admin

    it "sets database" do
      clear_triple_store
      load_test_file_into_triple_store("IsoNamespace.ttl")
      load_test_file_into_triple_store("IsoScopedIdentifier.ttl")
    end

    it "index scoped_identifiers" do
      scoped_identifiers = IsoScopedIdentifier.all
      get :index
      expect(assigns(:scoped_identifiers).to_json).to eq(scoped_identifiers.to_json)
      expect(response).to render_template("index")
    end

    it "new scoped identifier" do
      scoped_identifier = IsoScopedIdentifier.new
      namespaces = IsoNamespace.all
      get :new
      expect(assigns(:namespaces)).to eq([["BBB Pharma","NS-BBB"],["AAA Long","NS-AAA"]])
      expect(assigns(:scoped_identifier).to_json).to eq(scoped_identifier.to_json)
      expect(response).to render_template("new")
    end

    it 'creates scoped identifier' do
      post :create, iso_scoped_identifier: { identifier: "XXX SI", version: "1", versionLabel: "draft 1" }
      expect(IsoScopedIdentifier.all.count).to eq(6)
      expect(response).to redirect_to("/iso_scoped_identifiers")
    end

    it 'fails to create an existing scoped identifier' do
      post :create, iso_scoped_identifier: { identifier: "XXX SI", version: "1", versionLabel: "draft 1" }
      expect(IsoScopedIdentifier.all.count).to eq(6)
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/iso_scoped_identifiers/new")
    end

    it 'deletes scoped_identifier' do
      scoped_identifiers = IsoScopedIdentifier.all
      delete :destroy, :id => scoped_identifiers[0].id
      expect(IsoScopedIdentifier.all.count).to eq(5)
    end

  end

  describe "Unauthorized User" do
    
    it "index scoped identifier" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "new scoped identifier" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'creates scoped_identifier' do
      post :create, iso_scoped_identifier: { name: "XXX Pharma", shortName: "XXX" }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end