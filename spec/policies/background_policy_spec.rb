require 'rails_helper'

describe BackgroundPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, background) }
  let (:background) { Background.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a term reader" do

    let (:user) { @user_tr }

    it "denies access" do
      deny_list [:index, :destroy, :destroy_multiple]
    end

  end

  context "for a term curator" do

    let (:user) { @user_tc }

    it "denies access" do
      deny_list [:index, :destroy, :destroy_multiple]
    end

  end

  context "for a reader" do

    let (:user) { @user_r }

    it "denies access" do
      deny_list [:index, :destroy, :destroy_multiple]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "denies access" do
      deny_list [:index, :destroy, :destroy_multiple]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:index, :destroy, :destroy_multiple]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      allow_list [:index, :destroy, :destroy_multiple]
    end

  end

end