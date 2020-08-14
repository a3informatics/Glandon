require 'rails_helper'

describe "Tests validation server", :type => :feature, :remote=> true do

  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include RemoteServerHelpers
  include PauseHelpers
  include QualificationUserHelpers

  # RemoteServerHelpers.switch_to_remote

  RemoteServerHelpers.switch_to_local


  describe "Login", :type => :feature do

    it "Admin user login", js: true do
     quh_sys_and_content_admin_login
     quh_logoff
    end
    
    it "Community Reader Login", js: true do
      quh_community_reader_login
      quh_logoff
    end
  end

  describe "Login", :type => :feature do

    before :all do
      puts 'before all'
    end

    before :each do
      puts 'before each'
    end
    
    after :all do
      puts 'after all'
    end

    after :each do
      puts 'after each'
    end
    
    it "Login test - REQ12333", js: true do
      puts '12333'
    end

    it "Login test - REQ12334", js: true do
      puts '12334'
    end

  end

end
