require 'rails_helper'

describe BiomedicalConceptPolicy do

  include UserAccountHelpers

  subject { described_class.new(user, biomedical_concept) }
  let (:biomedical_concept) { BiomedicalConcept.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  def allow(action)
    expect(subject.public_send("#{action}?")).to eq(true)
  end

  def deny(action)
    expect(subject.public_send("#{action}?")).to eq(false)
  end

  def allow_list(action_list)
    action_list.each do |action|
      allow(action)
    end
  end

  def deny_list(action_list)
    action_list.each do |action|
      deny(action)
    end
  end

  context "for a reader" do

    let (:user) { @user_r }

    it "allows access" do
      allow_list [:index, :show, :view, :list, :history]
    end

    it "denies access" do
      deny_list [:create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :import]
    end

  end

  context "for a curator" do

    let (:user) { @user_c }

    it "allows access" do
      allow_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl]
    end

    it "denies access" do
      deny_list [:import]
    end

  end

  context "for a content admin" do

    let (:user) { @user_ca }

    it "allows access" do
      allow_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :import]
    end

  end

  describe "for a system admin" do

    let (:user) { @user_sa }

    it "denies access" do
      @user_sa.remove_role :reader # Just for this test
      deny_list [:index, :show, :view, :list, :history, :create, :new, :update, :edit, :clone, :upgrade, :destroy, :export_json, :export_ttl, :import]
      @user_sa.add_role :reader
    end

  end

end