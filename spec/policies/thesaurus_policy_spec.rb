require 'rails_helper'

describe ThesaurusPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, thesaurus) }
  let (:thesaurus) { Thesaurus.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a reader" do

    let (:user) { @user_r }

		it "allows access" do
      allow_list [:index, :show, :view, :history]
    end

		it "denies access" do
      deny_list [:new, :create, :edit, :impact, :destroy, :export_ttl]
    end

  end

  context "for a term reader" do

    let (:user) { @user_tr }

		it "allows access" do
      allow_list [:index, :show, :view, :history]
    end

		it "denies access" do
      deny_list [:new, :create, :edit, :impact, :destroy, :export_ttl]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

		it "allows access" do
      allow_list [:index, :show, :view, :history, :new, :create, :edit, :impact, :destroy, :export_ttl]
    end

		it "denies access" do
      deny_list []
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

		it "allows access" do
      allow_list [:index, :show, :view, :history, :new, :create, :edit, :impact, :destroy, :export_ttl]
    end

		it "denies access" do
      deny_list []
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

		it "allows access" do
      allow_list [:index, :show, :view, :history, :new, :create, :edit, :impact, :destroy, :export_ttl]
    end

		it "denies access" do
      deny_list []
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

		it "allows access" do
      allow_list []
    end

		it "denies access" do
      deny_list [:index, :show, :view, :history, :new, :create, :edit, :impact, :destroy, :export_ttl]
    end

  end

end