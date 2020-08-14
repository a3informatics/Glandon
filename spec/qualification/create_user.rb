require 'rails_helper'

describe "Users", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include RemoteServerHelpers
  include PauseHelpers

  RemoteServerHelpers.switch_to_local
  User.destroy_all
  before :all do
    #ua_create
    #ua_add_user email: 'admin@s-cubed.dk', password: 'Changeme1?', role: :curator
    #ua_add_user email: 'lock@example.com', password: 'Changeme1#', role: :curator
    #ua_add_user email: 'tst_user2@example.com', password: 'Changeme1#', current_sign_in_at: '2019-11-21 07:45:59.141587'
    admin_user = User.create :email => "admin@s-cubed.dk", :password => "Changeme1?", :name => "Admin"
    admin_user.add_role :sys_admin
    admin_user.add_role :content_admin
    admin_user.remove_role :reader
    unforce_first_pass_change admin_user
    community_user = ua_add_user email: 'community@s-cubed.dk', password: 'Changeme1?'
    community_user.add_role :community_reader
    community_user.remove_role :reader
    unforce_first_pass_change community_user
  end

      it "Create Admin user", js: true do
    end
              
     it "Create Community user", js: true do
    end

end