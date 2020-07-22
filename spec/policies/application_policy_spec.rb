require 'rails_helper'

describe ApplicationPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  # subject { described_class.new(user, audit_trail) }
  # let (:audit_trail ) { AuditTrail.new }

  before :all do
    ua_create
  end

  after :all do
    ua_destroy
  end
  
  context "methods" do

    let (:user) { @user_r }

    it "policy methods" do
      expect_any_instance_of(ApplicationPolicy).to receive(:read_policy_definitions).and_return({})
      expect_any_instance_of(ApplicationPolicy).to receive(:read_alias_definitions).and_return({})
      policy = ApplicationPolicy.new(:user, nil)
      list = 
      {
        index:
        {
          sys_admin: true,
          community_reader: true,
          term_reader: true,
          term_curator: true,
          reader: true,
          curator: true,
          content_admin: true
        },
        update:
        {  
          sys_admin: true,
          community_reader: true,
          term_reader: true,
          term_curator: true,
          reader: true,
          curator: true,
          content_admin: true
        }
      }
      policy.create_policies(list)
      expect(policy.respond_to?(:index?)).to eq(true)
      expect(policy.respond_to?(:update?)).to eq(true)
    end

    it "alias methods" do
      expect_any_instance_of(ApplicationPolicy).to receive(:read_policy_definitions).and_return({})
      expect_any_instance_of(ApplicationPolicy).to receive(:read_alias_definitions).and_return({})
      policy = ApplicationPolicy.new(:user, nil)
      list = 
      {
        index_data: "index",
        update_something: "index"
      }
      policy.create_alias(list)
      expect(policy.respond_to?(:index_data?)).to eq(true)
      expect(policy.respond_to?(:update_something?)).to eq(true)
    end

  end

end