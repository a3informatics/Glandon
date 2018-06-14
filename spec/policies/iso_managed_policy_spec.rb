require 'rails_helper'

describe IsoManagedPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, iso_managed) }
  let (:iso_managed) { IsoManaged.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a term reader" do

    let (:user) { @user_tr }

    it "allows access" do
      allow_list []
    end

    it "denies access" do
      deny_list [:show, :view, :list, :history, :index, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :status]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

		it "allows access" do
      allow_list [:index, :status]
    end

    it "denies access" do
      deny_list [:show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl,:import]
    end

  end

	context "for a reader" do

    let (:user) { @user_r }

    it "allows access" do
      allow_list [:show, :view, :list, :history]
    end

    it "denies access" do
      deny_list [:index, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :status]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
      allow_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :status]
    end

    it "denies access" do
      deny_list [:import]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :import, :status]
    end

    it "denies access" do
      allow_list []
    end
    
  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      @user_sa.remove_role :reader # Just for this test
      allow_list []
      @user_sa.add_role :reader
    end

    it "denies access" do
      @user_sa.remove_role :reader # Just for this test
      deny_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :import, :status]
      @user_sa.add_role :reader
    end

  end

end