require 'rails_helper'

describe IsoScopedIdentifiersController do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_curator

    
    before :each do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
      load_test_file_into_triple_store("iso_namespace_fake.ttl")
      load_test_file_into_triple_store("iso_scoped_identifier.ttl")
    end

    it 'updates a scoped identifier' do
      count = IsoScopedIdentifier.all.count
      @request.env['HTTP_REFERER'] = 'http://test.host/iso_scoped_identifiers'
      scoped_identifier = IsoScopedIdentifier.all.first
      patch :update, { id: "#{scoped_identifier.id}", iso_scoped_identifier: { versionLabel: "update to label" }}
      updated_scoped_identifier = IsoScopedIdentifier.find(scoped_identifier.id)
      expect(IsoScopedIdentifier.all.count).to eq(count)
      expect(updated_scoped_identifier.versionLabel).to eq("update to label")
      expect(response).to redirect_to("/iso_scoped_identifiers")
    end

    it 'fails to update a scoped identifier, invalid version label' do
      count = IsoScopedIdentifier.all.count
      @request.env['HTTP_REFERER'] = 'http://test.host/iso_scoped_identifiers'
      scoped_identifier = IsoScopedIdentifier.all.first
      vl = scoped_identifier.versionLabel
      patch :update, { id: "#{scoped_identifier.id}", iso_scoped_identifier: { versionLabel: "update to label@@@£±£±" }}
      updated_scoped_identifier = IsoScopedIdentifier.find(scoped_identifier.id)
      expect(IsoScopedIdentifier.all.count).to eq(count)
      expect(updated_scoped_identifier.versionLabel).to eq(vl)
      expect(response).to redirect_to("/iso_scoped_identifiers")
    end 

  end

  describe "Unauthorized User" do
    
    login_sys_admin

    it 'update' do
      patch :update, id: "XXX", iso_scoped_identifier: { name: "XXX Pharma", shortName: "XXX" }
      expect(response).to redirect_to("/")
      expect(flash[:error]).to be_present
      expect(flash[:error]).to match(/You do not have the access rights to that operation.*/)
    end

  end

  describe "Not logged in" do
    
    it "update" do
      patch :update, id: "XXX", iso_scoped_identifier: { name: "XXX Pharma", shortName: "XXX" }
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end