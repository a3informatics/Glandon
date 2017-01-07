require 'rails_helper'

describe "CDISC Term", :type => :feature do
  
  include DataHelpers

  before :each do
    user = FactoryGirl.create(:user)
    user.add_role :curator
    visit '/users/sign_in'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'example1234'
    click_button 'Log in'
  end

  describe "CDISC Terminology", :type => :feature do
  
    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCTerm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V39.ttl")
      load_test_file_into_triple_store("CT_V40.ttl")
      load_test_file_into_triple_store("CT_V41.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
    end

    it "allows the history page to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    it "history allows the show CDISC Term page to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-03-27')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: CDISC Terminology 2015-03-27 '
      expect(page).to have_content 'C100129'
      expect(page).to have_content 'C100132'
      expect(page).to have_content 'C100138'
    end

    it "history allows the status page to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-09-25')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: CDISC Terminology 2015-09-25 CDISC Terminology (2015-09-25, V42, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end
    
    it "history allows the search page to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-06-26')]/td/a", :text => 'Search').click
      expect(page).to have_content 'Search: CDISC Terminology 2015-06-26'
      #save_and_open_page
      click_link 'Close'
      expect(page).to have_content 'History: CDISC Terminology'
    end

    it "allows the lower level show pages to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2015-03-27')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: CDISC Terminology 2015-03-27 CDISC Terminology (2015-03-27, V40, Standard)'
      expect(page).to have_content 'C100136'
      expect(page).to have_content 'C100135'
      expect(page).to have_content 'C100137'
      find(:xpath, "//tr[contains(.,'EQ-5D-3L TESTCD')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: QS-European Quality of Life Five Dimension Three Level Scale Test Code C100136'
      expect(page).to have_content 'C100393'
      expect(page).to have_content 'C100394'
      expect(page).to have_content 'C100395'
      find(:xpath, "//tr[contains(.,'C100397')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: EQ-5D-3L - EQ VAS Score C100397'
      expect(page).to have_content 'European Quality of Life Five Dimension Three Level Scale - Indicate on this scale how good or bad your own health is today, in your opinion.'
      #save_and_open_page
    end
    
    it "allows the code list item changes to be viewed" do
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Terminology 2014-12-16')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: CDISC Terminology 2014-12-16 CDISC Terminology (2014-12-16, V39, Standard)'
      expect(page).to have_content 'C100136'
      expect(page).to have_content 'C100135'
      expect(page).to have_content 'C100137'
      find(:xpath, "//tr[contains(.,'VSTESTCD')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Signs Test Code C66741'
      expect(page).to have_content 'C100947'
      expect(page).to have_content 'C117976'
      expect(page).to have_content 'C100945'
      #save_and_open_page
      click_link 'Changes'
      expect(page).to have_content 'Changes: CDISC SDTM Vital Sign Test Code Terminology C66741'
      expect(page).to have_content 'C104622'
      find(:xpath, "//tr[contains(.,'BODYFATM')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Changes: Body Fat Measurement C122232'
      #save_and_open_page
    end

  end

end