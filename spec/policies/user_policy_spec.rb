require 'rails_helper'

describe UserPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, user) }
  let (:user) { User.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a reader" do

    let (:user) { @user_r }

		it "denies access" do
      deny_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

  end

  context "for a term reader" do

    let (:user) { @user_tr }

    it "denies access" do
      deny_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

    it "denies access" do
      deny_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "deny access" do
      deny_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

    it "allows access" do
      allow_list [], true
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "deny access" do
      deny_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

    it "allows access" do
      allow_list []
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      allow_list [:index, :new, :show, :update, :create, :edit, :destroy]
    end

  end

end