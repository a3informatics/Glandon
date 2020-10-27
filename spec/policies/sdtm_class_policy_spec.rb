require 'rails_helper'

describe SdtmClassPolicy do

  include UserAccountHelpers
  include PermissionsHelpers

  subject { described_class.new(user, sdtm_class) }
  let (:sdtm_class) { SdtmClass.new }

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
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