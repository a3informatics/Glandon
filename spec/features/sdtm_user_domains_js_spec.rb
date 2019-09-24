require 'rails_helper'

describe "SDTM User Domains", :type => :feature do

  include DataHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include SparqlHelpers
  include UserAccountHelpers

  def sub_dir
    return "features"
  end

  describe "Users Domains", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl","ISO11179Identification.ttl", "ISO11179Registration.ttl","ISO11179Concepts.ttl",
        "CDISCBiomedicalConcept.ttl", "BusinessOperational.ttl", "BusinessDomain.ttl"]
      data_files = ["iso_registration_authority_real.ttl", "iso_namespace_real.ttl", "BCT.ttl", "BC.ttl", "sdtm_user_domain_dm.ttl",
        "sdtm_user_domain_vs.ttl", "sdtm_model_and_ig.ttl"]
      load_files(schema_files, data_files)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      Token.set_timeout(60)
      clear_downloads
      ua_create
    end

    after :all do
      ua_destroy
      Token.restore_timeout
    end

    before :each do
      ua_curator_login
    end

    after :each do
      clear_downloads
      ua_logoff
    end

    it "allows for a domain to be deleted, cancel", js: true do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'History: VS Domain'
    end

    it "allows for a domain to be deleted, ok", js: true do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Index: Domains'
    end

    it "allows a domain to be created, field validation", js: true do
      visit '/sdtm_user_domains/clone_ig?sdtm_user_domain[sdtm_ig_domain_id]=IG-CDISC_SDTMIGEG&sdtm_user_domain[sdtm_ig_domain_namespace]=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
      expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (V3.2.0, 3, Standard)'
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
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History:'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export JSON'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_user_domain_export.json")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a IG Domain to be exported as TTL", js: true do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History:'
      find(:xpath, "//tr[contains(.,'DM Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export Turtle'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_user_domain_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_user_domain_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_user_domain_export.ttl")
      check_triples("sdtm_user_domain_export_results.ttl", "sdtm_user_domain_export.ttl")
      delete_data_file(sub_dir, "sdtm_user_domain_export_results.ttl")
    end

    it "*** SDTM IMPORT SEMANTIC VERSION ***"

  end

end
