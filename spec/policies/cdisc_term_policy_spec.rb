require 'rails_helper'

describe CdiscTermPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, cdisc_term) }
  let (:cdisc_term) { CdiscTerm.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a community reader" do

    let (:user) { @user_cr }

    it "allows access" do
      allow_list [:index, :changes, :history]
    end

    it "denies access" do
      deny_list [], true
    end

  end

  context "for a reader" do

    let (:user) { @user_r }

		it "allows access" do
      allow_list [:index, :history]
    end

		it "denies access" do
      deny_list [:changes], true
    end

  end

  context "for a term reader" do

    let (:user) { @user_tr }

		it "allows access" do
      allow_list [:index, :history]
    end

		it "denies access" do
      deny_list [:changes]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

		it "allows access" do
      allow_list [:index, :history]
    end

		it "denies access" do
      deny_list [:changes]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

		it "allows access" do
      allow_list [:index, :history]
    end

		it "denies access" do
      deny_list [:changes]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

		it "allows access" do
      allow_list [:index, :history]
    end

		it "denies access" do
      deny_list [:changes]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

		it "allows access" do
      allow_list []
    end

		it "denies access" do
      deny_list [:index, :changes, :history]
    end

  end

end