require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers

  describe "Sponsor Terminology", :type => :feature do

    before :all do
      schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl", "BusinessOperational.ttl"]
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_concept_new_2.ttl"]
      load_files(schema_files, data_files)
      # clear_triple_store
      # load_schema_file_into_triple_store("ISO11179Types.ttl")
      # load_schema_file_into_triple_store("ISO11179Identification.ttl")
      # load_schema_file_into_triple_store("ISO11179Registration.ttl")
      # load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      # load_schema_file_into_triple_store("ISO25964.ttl")
      # load_test_file_into_triple_store("iso_registration_authority_real.ttl")
      # load_test_file_into_triple_store("iso_namespace_real.ttl")
      # load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_all_edit_locks
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

    it "allows access to index page (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
    end

    it "allows a terminology to be created (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      # click_link 'New'
      expect(page).to have_content 'New Terminology'
      fill_in 'thesauri_identifier', with: 'TEST test'
      fill_in 'thesauri_label', with: 'Test Terminology'
      click_button 'Create'
      expect(page).to have_content 'Terminology was successfully created.'
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

    it "allows the history page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'Test Terminology')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: TEST test'
    end

    it "history allows the show page to be viewed (REQ-MDR-ST-015)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :show)
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
    end

    # it "history allows the view page to be viewed (REQ-MDR-ST-015)", js: true do
    #   click_navbar_terminology
    #   expect(page).to have_content 'Index: Terminology'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: CDISC EXT'
    #   find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'View').click
    #   expect(page).to have_content 'View: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
    #   click_link 'Close'
    #   expect(page).to have_content 'History: CDISC EXT'
    # end

    it "history allows the status page to be viewed (REQ-MDR-ST-050)", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :document_control)
      # find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'Status').click
      expect(page).to have_content 'Status: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      click_link 'Close'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "history allows the search page to be viewed ()", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :search)
      expect(page).to have_content 'Search: CDISC Extensions CDISC EXT (V1.0.0, 1, Standard)'
      #save_and_open_page
      click_link 'Return'
      expect(page).to have_content 'History: CDISC EXT'
    end

    it "allows the lower level show pages to be viewed", js: true do
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :show)
      expect(page).to have_content 'CDISC Extensions'
      expect(page).to have_content 'CDISC EXT'
      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00010'
      expect(page).to have_content 'A00020'
      find(:xpath, "//tr[contains(.,'VSTEST')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Vital Sign Test Codes Extension'
      expect(page).to have_content 'A00001'
      expect(page).to have_content 'A00003'
      expect(page).to have_content 'A00002'
      find(:xpath, "//tr[contains(.,'MUAC')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Mid upper arm circumference'
      expect(page).to have_content 'A00003'
      #save_and_open_page
    end

    it "history allows the edit page to be viewed", js: true do # Put this after other tests, creates V2
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC Extensions')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      context_menu_element('history', 4, 'CDISC Extensions', :edit)
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (V1.1.0, 2, Incomplete)' # Note the up version because V1 is at 'Standard'
      #click_button 'Close' # This requires Javascript so wont work in this test.
      #expect(page).to have_content 'History: CDISC EXT'
    end


  end

end
