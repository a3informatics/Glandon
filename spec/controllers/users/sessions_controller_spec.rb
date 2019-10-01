require 'rails_helper'

describe Users::SessionsController do

  C_PASSWORD = "Changeme1%"

  describe "login" do
  	
    it 'creates audit entry for login' do
      user1 = User.create :email => "fred@example.com", :password => C_PASSWORD 
      request.env['devise.mapping'] = Devise.mappings[:user]
      audit_count = AuditTrail.count
      post :create, :user => {:email => 'fred@example.com', :password => C_PASSWORD}
      expect(AuditTrail.count).to eq(audit_count + 1)
    end

    it 'does not create audit entry for failed login' do
      user1 = User.create :email => "fred@example.com", :password => "#{C_PASSWORD}X" 
      request.env['devise.mapping'] = Devise.mappings[:user]
      audit_count = AuditTrail.count
      post :create, :user => {:email => 'fred@example.com', :password => C_PASSWORD}
      expect(AuditTrail.count).to eq(audit_count)
    end

  end

end