require 'rails_helper'

describe "Community Dashboard JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  
  before :all do
    clear_triple_store
    ua_create
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_cdisc_term_versions(1..59)
    clear_iso_concept_object
  end

    before :each do
      ua_comm_reader_login
    end

  after :all do
    ua_destroy
  end

  describe "Community Reader User", :type => :feature do

    it "allows the dashboard to be viewed (REQ-MDR-UD-090)", js: true do
      expect(page).to have_content 'Changes in CDISC CT versions'
      expect(page).to have_content 'Created Items'
      expect(page).to have_content 'Updated Items'
      expect(page).to have_content 'Deleted Items'
    end

    it "allows access to CDISC history (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC CT versions'
      click_link 'Browse every version of CDISC CT'
      expect(page).to have_content 'History: CDISC Terminology'
      expect(page).to have_content '2019-06-28 Release'
      expect(page).to have_content '2017-09-29 Release'
    end

    it "allows access to CDISC changes (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC CT versions'
      click_link 'See the changes across versions'
      expect(page).to have_content 'Changes: CDISC Terminology'
      fill_in 'Search:', with: 'C67154'
      ui_check_table_info("changes", 1, 1, 1)
    end

    it "allows access to CDISC submission changes (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC CT versions'
      click_link 'See submission value changes across versions'
      expect(page).to have_content 'Submission: CDISC Terminology'
    end
    
    it "allows access to CDISC search (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC CT versions'
      click_link 'Search the latest version of CDISC CT'
      expect(page).to have_content 'Search: Controlled Terminology CT '    
    end

  end

end