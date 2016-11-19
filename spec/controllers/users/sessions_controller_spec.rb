require 'rails_helper'

describe Users::SessionsController do

  describe "login" do
  	
    it 'creates audit entry for login' do
      user1 = User.create :email => "fred@example.com", :password => "changeme" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      audit_count = AuditTrail.count
      post :create, :user => {:email => 'fred@example.com', :password => 'changeme'}
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it 'does not create audit entry for failed login' do
      user1 = User.create :email => "fred@example.com", :password => "changemeX" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      audit_count = AuditTrail.count
      post :create, :user => {:email => 'fred@example.com', :password => 'changeme'}
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

end