require 'rails_helper'

describe "SDTM User Domains", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers

  describe "Users Domains", :type => :feature, js:true do

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
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to index page" do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
    end

    it "allows the history page to be viewed" do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
    end

    it "history allows the show page to be viewed" do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Signs VS Domain (V0.1.0, 1, Incomplete)'
    end

    it "history allows the status page to be viewed" do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: Vital Signs VS Domain (V0.1.0, 1, Incomplete)'
      click_link 'Close'
      expect(page).to have_content 'History: VS Domain'
    end

    it "allows a domain to be cloned" do
      visit 'sdtm_ig_domains/IG-CDISC_SDTMIGEG?sdtm_ig_domain[namespace]=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
      click_link 'Clone'
      expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (V3.2.0, 3, Standard)'
      ui_check_input('sdtm_user_domain_prefix', 'EG')
      fill_in 'sdtm_user_domain_label', with: 'Cloned EG'
      click_button 'Clone'
      expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
      expect(page).to have_content 'Cloned EG'
    end

    it "*** SDTM IMPORT SEMANTIC VERSION ***"

    it "allows for a BC to be associated with the domain" do
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      bc_count = domain.bc_refs.count
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Signs VS Domain (V0.1.0, 1, Incomplete)'
      click_link 'BC+'
      expect(page).to have_content 'Add Biomedical Concepts'
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C98793']").set(true)
      click_button 'Add'
      expect(page).to have_content("Show: Vital Signs VS Domain (V0.1.0, 1, Incomplete)")
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      expect(domain.bc_refs.count).to eq(bc_count + 1)
    end

    it "allows for a BC to be dis-associated with the domain" do
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      bc_count = domain.bc_refs.count
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Signs VS Domain (V0.1.0, 1, Incomplete)'
      click_link 'BC-'
      expect(page).to have_content 'Remove Biomedical Concepts'
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C98793']").set(true)
      click_button 'Remove'
      expect(page).to have_content("Show: Vital Signs VS Domain (V0.1.0, 1, Incomplete)")
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1")
      expect(domain.bc_refs.count).to eq(bc_count - 1)
    end

    it "history allows the edit page to be entered" do
      click_navbar_sponsor_domain
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: Vital Signs VS Domain (V0.1.0, 1, Incomplete)'
    end

    it "allows for a report to be exported"

  end

end
