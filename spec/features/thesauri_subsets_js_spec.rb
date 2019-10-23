require 'rails_helper'

describe "Thesauri", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  describe "The Content Admin User can", :type => :feature do

    before :all do
      schema_files =["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl",
        "ISO11179Concepts.ttl", "thesaurus.ttl"]
      data_files = ["CT_SUBSETS.ttl","iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..20)
      ua_create
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    after :all do
      ua_destroy
    end

     #Index subsets
    it "index subsets (REQ-MDR-?????)", js:true do
      click_navbar_cdisc_terminology
      expect(page).to have_content 'History'
      wait_for_ajax(7)
      context_menu_element("history", 5, "2010-03-05 Release", :show)
      expect(page).to have_content '2010-03-05 Release'
      ui_child_search("C66726")
      ui_check_table_info('children_table', 1, 1, 1)
      find(:xpath, "//tr[contains(.,'C66726')]/td/a", :text => 'Show').click
      expect(page).to have_content("CDISC SDTM Pharmaceutical Dosage Form Terminology")
      expect(page).to have_link("Subsets")
      click_link "Subsets"
      ui_check_table_cell("ssIndexTable", 1, 1, "S000001")
      ui_check_table_cell("ssIndexTable", 2, 1, "S000002")
      click_button "Close"
    end


  end

end
