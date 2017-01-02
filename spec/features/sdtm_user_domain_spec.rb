require 'rails_helper'

describe "SDTM User Domains", :type => :feature do
  
  include DataHelpers
  include UiHelpers

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
    end

    before :each do
      user = FactoryGirl.create(:user)
      user.add_role :curator
      visit '/users/sign_in'
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'example1234'
      click_button 'Log in'
    end

    it "allows access to index page" do
      visit '/'
      find(:xpath, "//a[@href='/sdtm_user_domains']").click
      expect(page).to have_content 'Index: Domains'
    end

    it "allows the history page to be viewed" do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
    end

    it "history allows the show page to be viewed" do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: VS Copy VS Domain (, V1, Incomplete)'
    end

    it "history allows the status page to be viewed" do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: VS Copy VS Domain (, V1, Incomplete)'
      click_link 'Close'
      expect(page).to have_content 'History: VS Domain'
    end
    
    it "allows a domain to be cloned" do
      visit 'sdtm_ig_domains/IG-CDISC_SDTMIGEG?namespace=http://www.assero.co.uk/MDRSdtmIgD/CDISC/V3'
      click_link 'Clone'
      expect(page).to have_content 'Cloning: Electrocardiogram SDTM IG EG (3.2, V3, Standard)'
      ui_check_input('sdtm_user_domain_prefix', 'EG')
      fill_in 'sdtm_user_domain_label', with: 'Cloned EG'
      click_button 'Clone'   
      expect(page).to have_content 'SDTM Sponsor Domain was successfully created.'
      expect(page).to have_content 'Cloned EG'
    end

    it "allows for a BC to be associated with the domain" do
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      bc_count = domain.bc_refs.count
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: VS Copy VS Domain (, V1, Incomplete)'
      click_link 'BC+'
      expect(page).to have_content 'Add Biomedical Concepts'
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C98793']").set(true)
      click_button 'Add'
      expect(page).to have_content("Show: VS Copy VS Domain (, V1, Incomplete)")
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      expect(domain.bc_refs.count).to eq(bc_count + 1)
    end

    it "allows for a BC to be dis-associated with the domain" do
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      bc_count = domain.bc_refs.count
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: VS Copy VS Domain (, V1, Incomplete)'
      click_link 'BC-'
      expect(page).to have_content 'Remove Biomedical Concepts'
      find(:css, "#sdtm_user_domain_bcs_[value='http://www.assero.co.uk/MDRBCs/V1#BC-ACME_BC_C98793']").set(true)
      click_button 'Remove'
      expect(page).to have_content("Show: VS Copy VS Domain (, V1, Incomplete)")
      domain = SdtmUserDomain.find("D-ACME_VSDomain", "http://www.assero.co.uk/MDRSdtmUD/ACME/V1") 
      expect(domain.bc_refs.count).to eq(bc_count - 1)
    end

    it "history allows the edit page to be entered" do
      visit '/sdtm_user_domains'
      expect(page).to have_content 'Index: Domains'
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS Domain'
      #save_and_open_page
      find(:xpath, "//tr[contains(.,'VS Domain')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: VS Copy VS Domain (, V1, Incomplete)'
    end

    it "allows for a domain to be exported as JSON"

    it "allows for a domain to be exprted as TTL"

    it "allows for a report to be exported"

  end

end