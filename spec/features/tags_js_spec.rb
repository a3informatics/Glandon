require 'rails_helper'

describe "Tags", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    @user = User.create :email => "content_admin@example.com", :password => "12345678" 
    @user.add_role :content_admin
  end

  after :all do
    user = User.where(:email => "content_admin@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do
  
    it "allows a tag system to be created" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      click_link 'New'
      fill_in 'iso_concept_system_label', with: 'A New tag System'
      fill_in 'iso_concept_system_description', with: 'A cunning system to end all systems'
      click_button 'Create'
      expect(page).to have_content 'Concept system was successfully created.'
      #pause
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      click_link 'Close'      
    end

    it "allows a tag node to be created" do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      click_link 'New'
      fill_in 'iso_concept_system_label', with: 'Tag 1'
      fill_in 'iso_concept_system_description', with: 'This is Tag 1'
      #pause
      click_button 'Create'
      #sleep 1
      expect(page).to have_content 'Concept system node was successfully created.'   
      #pause
      find(:xpath, "//table[@id='main']/tbody/tr[contains(.,'This is Tag 1')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Tag: Tag 1'
    end

    it "allows a child tag node to be created", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      find(:xpath, "//tr[contains(.,'This is Tag 1')]/td/a", :text => 'Show').click
      #sleep 1
      expect(page).to have_content 'Tag: Tag 1'
      click_link 'New'
      fill_in 'iso_concept_system_label', with: 'Tag 1-1'
      fill_in 'iso_concept_system_description', with: 'This is Tag 1-1'
      click_button 'Create'
      expect(page).to have_content 'Concept system node was successfully created.'    
      find(:xpath, "//tr[contains(.,'This is Tag 1-1')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Tag: Tag 1-1'    
    end

    it "allows a child tag node to be deleted, rejection", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      find(:xpath, "//tr[contains(.,'This is Tag 1')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Tag: Tag 1'
      #pause
      find(:xpath, "//tr[contains(.,'This is Tag 1-1')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
    end

    it "allows a child tag node to be deleted", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      find(:xpath, "//tr[contains(.,'This is Tag 1')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Tag: Tag 1'
      find(:xpath, "//tr[contains(.,'This is Tag 1-1')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Concept system node was successfully deleted.'    
    end

    it "allows a tag node to be deleted", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Show').click
      expect(page).to have_content 'A New tag System'
      find(:xpath, "//tr[contains(.,'This is Tag 1')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Concept system node was successfully deleted.'    
    end

    it "allows a tag system to be deleted", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
      click_link 'Tags'
      expect(page).to have_content 'Classifications'  
      find(:xpath, "//tr[contains(.,'A New tag System')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Concept system node was successfully deleted.'    
    end

  end

end