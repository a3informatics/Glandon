require 'rails_helper'

describe "CDISC Term", :type => :feature do
  
  include DataHelpers
  include PublicFileHelpers
  include UserAccountHelpers

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
      load_test_file_into_triple_store("CT_V43.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      delete_all_public_test_files
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
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
      expect(page).to have_content 'Status: CDISC Terminology 2015-09-25 CDISC Terminology (V42.0.0, 42, Standard)'
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
      expect(page).to have_content 'Show: CDISC Terminology 2015-03-27 CDISC Terminology (V40.0.0, 40, Standard)'
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
      expect(page).to have_content 'Show: CDISC Terminology 2014-12-16 CDISC Terminology (V39.0.0, 39, Standard)'
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
      #save_and_open_page
      expect(page).to have_content 'Changes: CDISC SDTM Vital Sign Terminology by Code C66741'
      expect(page).to have_content 'C104622'
      find(:xpath, "//tr[contains(.,'BODYFATM')]/td/a", :text => 'Changes').click
      expect(page).to have_content 'Changes: Body Fat Measurement C122232'
      #save_and_open_page
    end

    it "allows changes to be viewed" do
      copy_file_to_public_files("features", "CDISC_CT_Changes.yaml", "test")
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Changes'
      expect(page).to have_content 'Changes: CDISC Terminology'
    end

    it "allows changes report to be produced"

    it "allows submission to be viewed" do
      copy_file_to_public_files("features", "CDISC_CT_Submission_Changes.yaml", "test")
      visit '/cdisc_terms/history'
      expect(page).to have_content 'History: CDISC Terminology'
      click_link 'Submission'
      expect(page).to have_content 'Submission Values Changes:'
    end

    it "allows submission report to be produced"

  end

end