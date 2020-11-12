require 'rails_helper'

describe FormPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, form) }
  let (:form) { Form.new }

  before :all do
    ua_create
  	@role_to_user = construct_roles_to_user
  	@list = contruct_default_list  
  end

  after :all do
    ua_destroy
  end

	["sys_admin", "term_reader", "term_curator", "reader", "curator", "content_admin"].each do |role|
	
		context "#{role}" do

			let (:user) { @role_to_user[role] }

  		it "allows access" do
	  		allow_list @list[role][:allow]
  		end

  		it "denies access" do
   			deny_list @list[role][:deny]
  		end

  	end

  end

end