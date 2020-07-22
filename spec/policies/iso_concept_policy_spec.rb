require 'rails_helper'

describe IsoConceptPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, iso_concept) }
  let (:iso_concept) { IsoConceptV2.new }

  before :all do
    ua_create
  	@role_to_user = construct_roles_to_user
  	@list = contruct_default_list  
  end

  after :all do
    ua_destroy
  end

  context "for a term reader" do

    let (:user) { @user_tr }

    it "allows access" do
      allow_list [:show]
    end

    it "denies access" do
      deny_list [:edit]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

    it "allows access" do
      allow_list [:show, :edit]
    end

    it "denies access" do
      deny_list []
    end

  end

  context "for a reader" do

    let (:user) { @user_r }

    it "allows access" do
      allow_list [:show]
    end

    it "denies access" do
      deny_list [:edit]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
      allow_list [:show, :edit]
    end

    it "denies access" do
      deny_list []
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:show, :edit]
    end

    it "denies access" do
      allow_list []
    end
    
  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      allow_list []
    end

    it "denies access" do
      deny_list [:show, :edit]
    end

  end

end