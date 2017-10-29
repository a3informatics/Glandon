require 'rails_helper'

describe "ISO Namespace JS", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UserAccountHelpers

  before :all do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    ua_create
  end 

  after :all do
    ua_destroy
  end 

  before :each do
    ua_content_admin_login
  end

  after :each do
    ua_logoff
  end

  describe "valid user", :type => :feature, js: true do

    it "deletes namespace" do
      click_link 'Namespace'
      expect(page).to have_content 'Namespaces'
      find(:xpath, "//tr[contains(.,'AAA')]/td/a", :text => 'Delete').click
      page.accept_alert
      sleep(1)
      expect(page).to have_content 'BBB Pharma'
      expect(page).to have_no_content 'AAA Long'
      #pause
    end

  end

end