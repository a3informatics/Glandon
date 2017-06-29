require 'rails_helper'

describe "SDTM User Domains", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include TurtleHelpers

  def sub_dir
    return "features"
  end

  describe "Users Domains", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_dm.ttl")
      load_test_file_into_triple_store("sdtm_user_domain_vs.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      Token.set_timeout(60)
      clear_downloads
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows for a domain to be deleted, cancel", js: true do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'History: VS Domain'
    end

    it "allows for a domain to be deleted, ok", js: true do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Index: Domains'
    end

    it "allows a domain to be created, field validation", js: true do
      visit '/sdtm_user_domains/clone_ig?sdtm_user_domain[sdtm_ig_domain_id]=IG-CDISC_SDTMIGEG&sdtm_user_domain[sdtm_ig_domain_namespace]=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
      expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (V0.0.0, 3, Standard)'
      fill_in 'sdtm_user_domain[prefix]', with: '@@@'
      fill_in 'sdtm_user_domain[label]', with: '€€€'
      click_button 'Clone'
      expect(page).to have_content "Label contains invalid characters and Scoped Identifier error: Identifier contains invalid characters"
      fill_in 'sdtm_user_domain[prefix]', with: 'XX'
      fill_in 'sdtm_user_domain[label]', with: '€€€'
      click_button 'Clone'
      expect(page).to have_content "Label contains invalid characters"
      fill_in 'sdtm_user_domain[prefix]', with: 'XX'
      fill_in 'sdtm_user_domain[label]', with: 'Nice Label'
      click_button 'Clone'
      expect(page).to have_content "SDTM Sponsor Domain was successfully created."
      expect(page).to have_content "XX"
      expect(page).to have_content "Nice Label"
    end

    it "allows for a IG Domain to be exported as JSON", js: true do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History:'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export JSON'
      file = download_content 
    #write_text_file_2(file, sub_dir, "sdtm_user_domain_export.json")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a IG Domain to be exported as TTL", js: true do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History:'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export Turtle'
      file = download_content
    #write_text_file_2(file, sub_dir, "sdtm_user_domain_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_user_domain_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_export.ttl")
      check_ttl("sdtm_user_domain_export_results.ttl", "sdtm_user_domain_export.ttl")
      delete_data_file(sub_dir, "sdtm_user_domain_export_results.ttl")
    end

    it "*** SDTM IMPORT SEMANTIC VERSION ***"
    
  end

end