require 'rails_helper'

describe "Dashboard JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  
  before :all do
    user = User.create :email => "reader@example.com", :password => "12345678" 
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
  end

  after :all do
    user = User.where(:email => "reader@example.com").first
    user.destroy
  end

  describe "Reader User", :type => :feature do

    it "allows the triples to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      click_link 'Biomedical Concepts'
      #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC  C16358'
      #pause
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => /\AT\z/).click
      expect(page).to have_content 'Triple Store View'
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      #pause
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRBCs/V1'
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'      
      #pause
      find(:xpath, "//tr[contains(.,'mdrItems:SI-ACME_BC_C16358-1')]/td", :text => 'Show').click
      expect(page).to have_content 'Triple Store View'
      #pause
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRItems'
      expect(find('#subjectId').value).to eq 'SI-ACME_BC_C16358-1'      
      find(:xpath, "//table[@id='main']/tbody/tr/td", :text => /\A1\z/).click
      click_button 'View'
      #pause
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'      
      click_link 'Close'
      expect(current_path).to eq("/dashboard")
    end

    it "allows the graph to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      click_link 'Biomedical Concepts'
      #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC  C16358'
      #pause
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => /\AT\z/).click
      expect(page).to have_content 'Triple Store View'
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRBCs/V1'
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'      
      click_button 'Gr+'
      expect(page).to have_content 'Metadata View:'
      click_link 'logoff_button'
      expect(page).to have_content 'Log in'
    end

    it "allows the dashboard to be viewed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      expect(page).to have_content 'CDISC Terminology 2015-09-25'
      expect(page).to have_content 'Temperature (BC C25206)'
      expect(page).to have_content 'Weight (BC C25208)'
      expect(page).to have_content 'Vital Signs Baseline'      
    end

    it "allows the history to be accessed", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      find(:xpath, "//tr[contains(.,'APGAR Score (BC A00002)')]/td/a", :text => /\AHistory\z/).click
      expect(page).to have_content 'History: BC  A00002'
    end

    it "displays the organization name", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      org = ENV['organization_navbar']
      expect(page).to have_content("#{org} Glandon (v")
    end

  end

end