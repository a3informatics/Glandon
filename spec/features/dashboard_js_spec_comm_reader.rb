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

    #after :each do
    #  ua_log_off
    #end

  after :all do
    ua_destroy
  end

  describe "Community Reader User", :type => :feature do

    it "allows the dashboard to be viewed (REQ-MDR-UD-090)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      expect(page).to have_content 'Created Code List'
      expect(page).to have_content 'Updated Code List'
      expect(page).to have_content 'Deleted Code List'
    end

    it "allows access to CDISC history (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      click_link 'btn-browse-cdisc'
      expect(page).to have_content 'History: CDISC Terminology'
      expect(page).to have_content '2019-06-28 Release'
      expect(page).to have_content '2017-09-29 Release'
    end

    it "allows access to CDISC changes (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      click_link 'See the changes across versions'
      expect(page).to have_content 'Changes: CDISC Terminology'
      fill_in 'Search:', with: 'C67154'
      ui_check_table_info("changes", 1, 1, 1)
    end

    it "allows access to CDISC submission changes (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      click_link 'See submission value changes across versions'
      expect(page).to have_content 'Submission: CDISC Terminology'
    end
    
    it "allows access to CDISC search (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      click_link 'Search the latest version of CDISC CT'
      expect(page).to have_content 'Search: Controlled Terminology CT '    
    end

    it "allows to versions to be selected and chnages to be displayed", js: true do
      expect(page).to have_content 'Changes in CDISC Terminology versions'
      
      script = 'var tl_slider = $(".timeline-container").data(); '
      script += 'tl_slider.moveToDate(tl_slider.l_slider, "2012-08-03");'
      script += 'tl_slider.moveToDate(tl_slider.r_slider, "2013-04-12");'

      script_filter = 'var filter_created = $(".alph-slider").eq(0).data(), filter_updated = $(".alph-slider").eq(1).data(), filter_deleted = $(".alph-slider").eq(2).data(); '
      script_filter += ' filter_created.moveToLetter("A"); '
      script_filter += ' filter_updated.moveToLetter("B"); '
      script_filter += ' filter_deleted.moveToLetter("C"); '
      page.execute_script(script)
      click_link 'Display'
      click_link 'btn_f_created'
      click_link 'btn_f_updated'
      click_link 'btn_f_deleted'
      page.execute_script(script_filter)
      pause

    end


# var tl_slider = $(".timeline-container").data();
# tl_slider.moveToDate(tl_slider.r_slider, "date");
  end

end