require 'rails_helper'

describe IsoScopedIdentifiersV2Controller do

  include DataHelpers
  
  describe "Authrorized User" do
  	
    login_curator

    
    before :each do
      data_files = ["iso_namespace_fake.ttl"]
      load_files(schema_files, data_files)
      org = IsoNamespace.find_by_short_name("BBB")
      uri = Uri.new(uri: "http://www.assero.co.uk/SI/BBB/NEW-1")
      @object = IsoScopedIdentifierV2.create(identifier: "NEW 1", version: 1, version_label: "0.1", semantic_version: "1.2.3", has_scope: org)
    end

    it 'updates a scoped identifier' do
      @request.env['HTTP_REFERER'] = 'http://test.host/iso_scoped_identifiers'
      patch :update, { id: @object.id, iso_scoped_identifier: { version_label: "update to label" }}
      updated_scoped_identifier = IsoScopedIdentifierV2.find(@object.id)
      expect(updated_scoped_identifier.version_label).to eq("update to label")
      expect(response).to redirect_to("/iso_scoped_identifiers")
    end

    it 'fails to update a scoped identifier, invalid version label' do
      @request.env['HTTP_REFERER'] = 'http://test.host/iso_scoped_identifiers'
      vl = @object.version_label
      patch :update, { id: @object.id, iso_scoped_identifier: { versionLabel: "update to label@@@£±£±" }}
      updated_scoped_identifier = IsoScopedIdentifierV2.find(@object.id)
      expect(updated_scoped_identifier.version_label).to eq(vl)
      expect(response).to redirect_to("/iso_scoped_identifiers")
    end 

  end

  describe "Unauthorized User" do
    
    login_sys_admin

    it 'update' do
      patch :update, id: "XXX", iso_scoped_identifier: { version_label: "XXX" }
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