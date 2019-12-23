require 'rails_helper'

describe "Tokens", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include BrowserSessionHelpers
  include WaitForAjaxHelper

  before :all do
    data_files =
    ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "thesaurus_new_airports.ttl", "CT_SUBSETS_1.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions((1..59))
    load_local_file_into_triple_store("features/thesaurus/subset", "subsets_input_4.ttl")
    Token.delete_all
    ua_add_user email: "token_user_1@example.com", role: :curator
    ua_add_user email: "token_user_2@example.com", role: :curator
  end

  after :all do
    ua_remove_user "token_user_1@example.com"
    ua_remove_user "token_user_2@example.com"
  end

  describe "Curator User", :type => :feature do

    it "locks a terminology (REQ-MDR-EL-010)", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
        expect(page).to have_content 'Version History of \'AIRPORTS\''
        wait_for_ajax
        context_menu_element('history', 4, '0.1.0', :edit)
        expect(page).to have_content 'Find & Select Code Lists'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
        expect(page).to have_content 'Version History of \'AIRPORTS\''
        wait_for_ajax
        context_menu_element('history', 4, '0.1.0', :edit)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks a biomedical concept"

    it "locks a form (REQ-MDR-EL-010)"#, js:true do

    #   in_browser(:one) do
    #     ua_generic_login 'token_user_1@example.com'
    #     click_navbar_forms
    #     find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
    #     expect(page).to have_content 'History: CRF TEST 1'
    #     find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
    #     expect(page).to have_content 'Edit:'
    #   end

    #   in_browser(:two) do
    #     ua_generic_login 'token_user_2@example.com'
    #     click_navbar_forms
    #     find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'History').click
    #     expect(page).to have_content 'History: CRF TEST 1'
    #     find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a", :text => 'Edit').click
    #     expect(page).to have_content 'The item is locked for editing by another user.'
    #   end

    # end

    it "locks a domain (REQ-MDR-EL-010)"#, js:true do

    #   in_browser(:one) do
    #     ua_generic_login 'token_user_1@example.com'
    #     click_navbar_sponsor_domain
    #     find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
    #     expect(page).to have_content 'History: DS Domain'
    #     find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
    #     expect(page).to have_content 'Edit:'
    #   end

    #   in_browser(:two) do
    #     ua_generic_login 'token_user_2@example.com'
    #     click_navbar_sponsor_domain
    #     find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'History').click
    #     expect(page).to have_content 'History: DS Domain'
    #     find(:xpath, "//tr[contains(.,'DS Domain')]/td/a", :text => 'Edit').click
    #     expect(page).to have_content 'The item is locked for editing by another user.'
    #   end

    # end

    it "locks a subset - WILL CURRENTLY FAIL", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_cdisc_terminology
        wait_for_ajax(10)
        ui_table_search("history", "2010-03-05")
        context_menu_element("history", 5, "2010-03-05 Release", :show)
        wait_for_ajax(10)
        expect(page).to have_content '2010-03-05 Release'
        ui_child_search("C85494")
        find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
        wait_for_ajax(10)
        context_menu_element_header(:subsets)
        context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
        wait_for_ajax(10)
        expect(page).to have_content("Edit Subset")
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_cdisc_terminology
        wait_for_ajax(10)
        ui_table_search("history", "2010-03-05")
        context_menu_element("history", 5, "2010-03-05 Release", :show)
        wait_for_ajax(10)
        expect(page).to have_content '2010-03-05 Release'
        ui_child_search("C85494")
        find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
        wait_for_ajax(10)
        context_menu_element_header(:subsets)
        context_menu_element("ssIndexTable", 3, "PK Parameter Units of Measure", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'The item is locked for editing by another user.'
      end

    end

  end

end
