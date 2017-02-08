require 'rails_helper'

describe TokenPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, token) }
  let (:token ) { Token.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "for a reader" do

    let (:user) { @user_r }

    it "denies access" do
      deny_list [:index, :release, :status, :extend_token]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
      allow_list [:release, :status, :extend_token]
    end

    it "denies access" do
      deny_list [:index]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:release, :status, :extend_token]
    end

    it "denies access" do
      deny_list [:index]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "allows access" do
      allow_list [:index, :release]
    end

    it "denies access" do
      deny_list [:status, :extend_token]
    end

  end

end