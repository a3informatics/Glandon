require 'rails_helper'

describe ImportPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, export) }
  let (:import) { Import.new }

  after :all do
    ua_destroy
  end

  before :all do
    ua_create
  end

  context "for a reader" do

    let (:user) { @user_r }

    it "denies access" do
      deny_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

    it "allows access" do
      allow_list []
    end

  end

  context "for a term reader" do

    let (:user) { @user_tr }

    it "denies access" do
      deny_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

    it "allows access" do
      allow_list []
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

    it "denies access" do
      deny_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

    it "allows access" do
      allow_list []
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "deny access" do
      deny_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

    it "allows access" do
      allow_list []
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "deny access" do
      deny_list []
    end

    it "allows access" do
      allow_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "deny access" do
      deny_list [:index, :show, :create, :list, :items, :destroy, :destroy_multiple]
    end

    it "allows access" do
      allow_list []
    end

  end

end