require 'rails_helper'

describe AuditTrailPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, audit_trail) }
  let (:audit_trail ) { AuditTrail.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a reader" do

    let (:user) { @user_r }

    it "denies access" do
      deny_list [:index, :search, :export_csv]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
      allow_list [:index, :search, :export_csv]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:index, :search, :export_csv]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      allow_list [:index, :search, :export_csv]
    end

  end

end