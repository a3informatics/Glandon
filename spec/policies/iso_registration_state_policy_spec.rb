require 'rails_helper'

describe IsoRegistrationStatePolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, iso_registration_state) }
  let (:iso_registration_state) { IsoRegistrationState.new }

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a reader" do

    let (:user) { @user_r }

		it "denies access" do
      deny_list [:create, :update]
    end

  end

  context "for a term reader" do

    let (:user) { @user_tr }

    it "denies access" do
      deny_list [:create, :update]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

		it "denies access" do
      deny_list [:create, :update]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
	    allow_list [:current, :update]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
	    allow_list [:current, :update]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "denies access" do
      deny_list [:create, :update]
    end

  end

end