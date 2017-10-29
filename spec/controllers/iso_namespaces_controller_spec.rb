require 'rails_helper'

describe IsoNamespacesController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_curator

    before :each do
      clear_triple_store
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
    end

    it "index namespaces" do
      namespaces = IsoNamespace.all
      get :index
      expect(assigns(:namespaces).to_json).to eq(namespaces.to_json)
      expect(response).to render_template("index")
    end

    it "new namespace" do
      namespace = IsoNamespace.new
      get :new
      expect(assigns(:namespace).to_json).to eq(namespace.to_json)
      expect(response).to render_template("new")
    end

    it 'creates namespace' do
      expect(IsoNamespace.all.count).to eq(2)
      post :create, iso_namespace: { name: "XXX Pharma", shortName: "XXX" }
      expect(IsoNamespace.all.count).to eq(3)
      expect(response).to redirect_to("/iso_namespaces")
    end

    it 'fails to create an existing namespace' do
      expect(IsoNamespace.all.count).to eq(2)
      post :create, iso_namespace: { name: "YYY Pharma", shortName: "YYY" }
      expect(IsoNamespace.all.count).to eq(3)
      post :create, iso_namespace: { name: "YYY Pharma", shortName: "YYY" }
      expect(IsoNamespace.all.count).to eq(3)
      expect(flash[:error]).to be_present
      expect(response).to redirect_to("/iso_namespaces/new")
    end

    it 'deletes namespace' do
      ns = IsoNamespace.findByShortName("XXX")
      delete :destroy, :id => ns.id
      expect(IsoNamespace.all.count).to eq(2)
    end

  end

  describe "Unauthorized User" do
    
    it "index namespace" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it "new namespace" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'creates namespace' do
      post :create, iso_namespace: { name: "XXX Pharma", shortName: "XXX" }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end