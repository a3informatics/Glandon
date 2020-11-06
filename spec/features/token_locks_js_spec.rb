require 'rails_helper'

describe "Token Locks", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include BrowserSessionHelpers
  include WaitForAjaxHelper

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl",
      "thesaurus_new_airports.ttl", "thesaurus_subsets_1.ttl", "thesaurus_subsets_2.ttl",
      "thesaurus_extension.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..65)
    load_local_file_into_triple_store("features/thesaurus/subset", "subsets_input_4.ttl")
    load_data_file_into_triple_store("mdr_identification.ttl")
    load_data_file_into_triple_store("biomedical_concept_instances.ttl")
    load_test_file_into_triple_store("forms/CRF TEST 1.ttl")

    Token.delete_all

    ua_add_user email: "token_user_1@example.com", role: :curator
    ua_add_user email: "token_user_2@example.com", role: :curator

    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "123")
    NameValue.create(name: "thesaurus_child_identifier", value: "456")
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
        wait_for_ajax(10)
        expect(page).to have_content 'Find & Select Code Lists'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
        expect(page).to have_content 'Version History of \'AIRPORTS\''
        wait_for_ajax
        context_menu_element('history', 4, '0.1.0', :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks a terminology, document control page (REQ-MDR-EL-010)", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
        expect(page).to have_content 'Version History of \'AIRPORTS\''
        wait_for_ajax
        context_menu_element('history', 4, '0.1.0', :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'Find & Select Code Lists'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_terminology
        find(:xpath, "//tr[contains(.,'AIRPORTS')]/td/a").click
        expect(page).to have_content 'Version History of \'AIRPORTS\''
        wait_for_ajax(20)
        context_menu_element('history', 4, '0.1.0', :document_control)
        wait_for_ajax(20)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks a biomedical concept", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_bc
        wait_for_ajax 20
        ui_table_search('index', 'Height')
        find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a").click
        expect(page).to have_content 'Version History of \'HEIGHT\''
        wait_for_ajax 10
        context_menu_element_v2('history', '0.1.0', :edit)
        wait_for_ajax 10
        expect(page).to have_content 'Biomedical Concept Editor'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_bc
        wait_for_ajax 20
        ui_table_search('index', 'Height')
        find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a").click
        expect(page).to have_content 'Version History of \'HEIGHT\''
        wait_for_ajax 10
        context_menu_element_v2('history', '0.1.0', :edit)
        wait_for_ajax 10
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks a form (REQ-MDR-EL-010)", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_forms
        wait_for_ajax 20
        ui_table_search('index', 'CRF TEST 1')
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a").click
        expect(page).to have_content 'Version History of \'CRF TEST 1\''
        wait_for_ajax 10
        context_menu_element_v2('history', '0.1.0', :edit)
        wait_for_ajax 10
        expect(page).to have_content 'Form Editor'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_forms
        wait_for_ajax 20
        ui_table_search('index', 'CRF TEST 1')
        find(:xpath, "//tr[contains(.,'CRF TEST 1')]/td/a").click
        expect(page).to have_content 'Version History of \'CRF TEST 1\''
        wait_for_ajax 10
        context_menu_element_v2('history', '0.1.0', :edit)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

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

    it "locks a subset", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_cdisc_terminology
        wait_for_ajax(10)
        ui_table_search("history", "2010-03-05")
        context_menu_element_v2("history", "2010-03-05 Release", :show)
        wait_for_ajax(10)
        expect(page).to have_content '2010-03-05 Release'
        ui_child_search("C85494")
        find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
        wait_for_ajax(10)
        context_menu_element_header(:subsets)
        sleep 0.5
        context_menu_element_v2("subsets-index-table", "PK Parameter Units of Measure", :edit)
        wait_for_ajax(10)
        expect(page).to have_content("Subset Editor")
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_cdisc_terminology
        wait_for_ajax(10)
        ui_table_search("history", "2010-03-05")
        context_menu_element_v2("history", "2010-03-05 Release", :show)
        wait_for_ajax(10)
        expect(page).to have_content '2010-03-05 Release'
        ui_child_search("C85494")
        find(:xpath, "//tr[contains(.,'C85494')]/td/a", :text => 'Show').click
        wait_for_ajax(10)
        context_menu_element_header(:subsets)
        sleep 0.5
        context_menu_element_v2("subsets-index-table", "PK Parameter Units of Measure", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks an extension", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_code_lists
        wait_for_ajax(120)
        ui_table_search("index", "Epoch Extension")
        find(:xpath, "//tr[contains(.,'Epoch Extension')][1]/td/a").click
        wait_for_ajax(10)
        context_menu_element_v2("history", "A00001", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'Extension Editor'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_code_lists
        wait_for_ajax(120)
        ui_table_search("index", "Epoch Extension")
        find(:xpath, "//tr[contains(.,'Epoch Extension')][1]/td/a").click
        wait_for_ajax(10)
        context_menu_element_v2("history", "A00001", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

    it "locks a codelist", js:true do

      in_browser(:one) do
        ua_generic_login 'token_user_1@example.com'
        click_navbar_code_lists
        wait_for_ajax(120)
        page.find("#tnb_new_button").click
        wait_for_ajax(20)
        wait_for_ajax(20)
        context_menu_element("history", 5, "Not Set", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'Code List Editor'
      end

      in_browser(:two) do
        ua_generic_login 'token_user_2@example.com'
        click_navbar_code_lists
        wait_for_ajax(120)
        ui_table_search("index", "\"Not Set\"")
        find(:xpath, "//tr[contains(.,'Not Set')]/td/a").click
        wait_for_ajax(10)
        context_menu_element("history", 5, "Not Set", :edit)
        wait_for_ajax(10)
        expect(page).to have_content 'The item is locked for editing by user: token_user_1@example.com.'
      end

    end

  end

end
