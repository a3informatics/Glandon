require 'rails_helper'

describe "Change Instructions", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

  def in_modal
    sleep 1
    wait_for_ajax 20
    yield
    sleep 1
  end

  def fill_in_field(id, text)
    page.find("##{id}").click
    sleep 0.2
    page.find("##{id}").set(text)
  end

  def check_fields(ref, text)
    expect(page.find("#reference").text).to eq(ref)
    expect(page.find("#description").text).to eq(text)
  end

  def check_no_errors
    expect(page).not_to have_css(".alert-danger")
  end

  def check_link(type, icon, text)
    find(:xpath, "//div[contains(concat(' ',normalize-space(@class), ' '),' items-list')]/a[@data-type='#{type}' and contains(.,'#{text}')]/span[contains(concat(' ',normalize-space(@class), ' '),' #{icon}')]")
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "change_instructions_v47.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..60)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    NameValue.create(name: "thesaurus_child_identifier", value: "999")
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator user (code list level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change instructions modal", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "EPOCH")
      find(:xpath, "//tr[contains(.,'EPOCH')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "58.0.0", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        expect(page).to have_content("Change Instructions for C99079")
        expect(page).to have_content("No Change Instructions were found.")
        click_button "Close"
      end
    end

    it "allows to create a change instruction, edit page redirect", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "EPOCH")
      find(:xpath, "//tr[contains(.,'EPOCH')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "58.0.0", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        click_button "+ Create new"
        wait_for_ajax 10
      end
      wait_for_ajax 10
      expect(page).to have_content "Edit Change Instruction"
      check_fields("Not set", "Not set")
      expect(page).to have_content("Empty", count: 2)
      #Help Dialog
      find(".icon-help").click
      in_modal do
        expect(page).to have_content("Editing a Change Instruction")
        click_on "Dismiss"
      end
    end

    it "allows to edit a change instruction", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "EPOCH")
      find(:xpath, "//tr[contains(.,'EPOCH')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "58.0.0", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        click_button "+ Create new"
        wait_for_ajax 10
      end
      wait_for_ajax 10
      expect(page).to have_content "Edit Change Instruction"

      #Edit fields
      fill_in_field("reference", "REF 01")
      find('#reference').native.send_keys(:return)
      wait_for_ajax 10
      check_no_errors
      fill_in_field("description", "Description of the Change Instruction")
      find('#description').native.send_keys(:return)
      wait_for_ajax 10
      check_no_errors

      #Add references
      find("#add-previous").click
      in_modal do
        ui_selector_check_tabs(["Code Lists", "Code List Items"])
        ui_selector_check_tabs_gone(["Terminologies"])
        ui_selector_item_click("index", "C100129")
        ui_selector_item_click("history", "60.0.0")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10
      check_link("previous", "icon-codelist", "QSCAT")

      find("#add-current").click
      in_modal do
        ui_selector_check_tabs(["Code Lists", "Code List Items"])
        ui_selector_check_tabs_gone(["Terminologies"])
        ui_selector_tab_click("Code List Items")
        wait_for_ajax 20
        ui_selector_item_click("index", "RELSUB")
        ui_selector_item_click("history", "57.0.0")
        ui_selector_item_click("children", "C96658")
        ui_selector_item_click("children", "C96657")
        ui_selector_item_click("children", "C96656")
        ui_selector_item_click("children", "C96587")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10
      check_link("current", "icon-codelist-item", "SISTER, BIOLOGICAL MATERNAL HALF")
      check_link("current", "icon-codelist-item", "C96657")
      check_link("current", "icon-codelist-item", "BROTHER")
      check_link("current", "icon-codelist-item", "UNCLE")

      #Remove references
      count = all('a.bg-label').count

      check_link("current", "icon-codelist-item", "SISTER, BIOLOGICAL MATERNAL HALF").click
      wait_for_ajax 10
      check_no_errors
      expect(all('a.bg-label').count).to eq(count-1)

      check_link("current", "icon-codelist-item", "UNCLE").click
      wait_for_ajax 10
      check_no_errors
      expect(all('a.bg-label').count).to eq(count-2)


      #Remove Change Instruction
      find("#delete-ci").click
      ui_confirmation_dialog true
      wait_for_ajax 10
      expect(page).to have_current_path(root_path)
    end

    it "Change instruction modal - edit link, show link, remove", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "QSCAT")
      find(:xpath, "//tr[contains(.,'QSCAT')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "57.0.0", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        click_button "+ Create new"
        wait_for_ajax 10
      end
      wait_for_ajax 10
      expect(page).to have_content "Edit Change Instruction"

      find("#add-previous").click
      in_modal do
        ui_selector_item_click("index", "QSCAT")
        ui_selector_item_click("history", "57.0.0")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10

      find("#add-current").click
      in_modal do
        ui_selector_tab_click("Code List Items")
        wait_for_ajax 20
        ui_selector_item_click("index", "C100132")
        ui_selector_item_click("history", "47.0.0")
        ui_selector_item_click("children", "ADCMZ02")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10

      click_on "Return"

      #Show items links
          wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        check_link("current", "icon-codelist-item", "C100132").click
      end
      wait_for_ajax 10
      expect(page).to have_content("ADCMZ02")
      expect(page).to have_content("Shared Synonyms")
      page.go_back

      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        check_link("previous", "icon-codelist", "QSCAT").click
      end
      wait_for_ajax 10
      expect(page).to have_content("C100129")
      expect(page).to have_content("Code Lists Items")

      #Edit CI link
      wait_for_ajax(20)
      context_menu_element_header(:change_instructions)
      in_modal do
        find(".icon-edit").click
      end
      wait_for_ajax 10
      expect(page).to have_content "Edit Change Instruction"
      check_link("previous", "icon-codelist", "QSCAT")

      click_on "Return"
      wait_for_ajax 10

      #Remove CI
      context_menu_element_header(:change_instructions)
      in_modal do
        find(".icon-trash").click
        ui_confirmation_dialog true
        wait_for_ajax 10
        expect(page).to have_content("Change Instruction deleted.")
        click_on "Close"
      end
    end

    it "allows both change instructions and change notes to be present on an item (bug fix)", js:true do
      # Add CN
      click_navbar_code_lists
      identifier = ui_new_code_list
      wait_for_ajax 20
      context_menu_element("history", 5, identifier, :show)
      wait_for_ajax 20
      context_menu_element_header(:change_notes)
      in_modal do
        click_button "+ Add new"
        fill_in_field("cn-new-text", "CN TEST")
        page.find("#save-cn-new-button").click
        wait_for_ajax 20
        click_on "Close"
      end
      # Add CI
      context_menu_element_header(:change_instructions)
      in_modal do
        click_button "+ Create new"
        wait_for_ajax 10
      end
      wait_for_ajax 10

      fill_in_field("description", "CI TEST")
      find('#description').native.send_keys(:return)
      wait_for_ajax 10

      find("#add-previous").click
      in_modal do
        ui_table_search("index", identifier)
        ui_selector_item_click("index", identifier)
        ui_selector_item_click("history", "0.1.0")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10

      click_on "Return"
      page.driver.browser.navigate.refresh

      # Check
      wait_for_ajax 20
      context_menu_element_header(:change_notes)
      in_modal do
        ui_check_no_flash_message_present
        expect(page.find("#cn-0-text").text).to eq("CN TEST")
        click_on "Close"
      end
      context_menu_element_header(:change_instructions)
      in_modal do
        ui_check_no_flash_message_present
        expect(page).to have_content("CI TEST")
        click_on "Close"
      end
    end

  end


  describe "Curator user (code list item level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change instructions modal", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "PKUWKG")
      find(:xpath, "//tr[contains(.,'C128683')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "56.0.0", :show)
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'C85754')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_header(:change_instructions)
      in_modal do
        expect(page).to have_content("Change Instructions for C85754")
        expect(page).to have_content("No Change Instructions were found.")
        click_button "Close"
      end
    end

    it "allows to create, show a change instruction", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "PKUWKG")
      find(:xpath, "//tr[contains(.,'C128683')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 5, "56.0.0", :show)
      wait_for_ajax(10)
      find(:xpath, "//tr[contains(.,'C85754')]/td/a").click
      wait_for_ajax(10)
      context_menu_element_header(:change_instructions)
      in_modal do
        click_button "+ Create new"
        wait_for_ajax 10
      end
      wait_for_ajax 10
      expect(page).to have_content "Edit Change Instruction"

      find("#add-current").click
      in_modal do
        ui_selector_tab_click("Code List Items")
        wait_for_ajax 20
        ui_table_search("index", "PKUWKG")
        ui_selector_item_click("index", "PKUWKG")
        ui_selector_item_click("history", "56.0.0")
        ui_selector_item_click("children", "C85754")
        click_on "Submit and proceed"
      end
      wait_for_ajax 10

      click_on "Return"
      wait_for_ajax(10)

      context_menu_element_header(:change_instructions)
      in_modal do
        check_link("current", "icon-codelist-item", "nmol/kg")
        click_on "Close"
      end
    end

    it "allows to display CDISC change instruction, edit disabled (REQ-MDR-PT-020)", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax 20
      ui_table_search("history", "2016-03-25")
      context_menu_element('history', 5, '2016-03-25 Release', :show)
      wait_for_ajax 20
      ui_child_search("C67154")
      find(:xpath, "//tr[contains(.,'C67154')]/td/a", :text => 'Show').click
      wait_for_ajax 20
      ui_child_search("C125949")
      find(:xpath, "//tr[contains(.,'Urea')]/td/a", :text => 'Show').click
      context_menu_element_header(:change_instructions)
      in_modal do
        expect(page).to have_content "This concept will replace C61019"
        check_link("previous", "icon-codelist-item", "Blood Urea Nitrogen (C61019)")
        check_link("current", "icon-codelist-item", "Urea Nitrogen (C125949)")
        expect(find("#change-instructions-modal")).not_to have_css(".icon-edit")
        expect(find("#change-instructions-modal")).not_to have_css(".icon-times")
        find(:xpath, "//a[contains(.,'Blood Urea Nitrogen (C61019)')]").click
      end
      wait_for_ajax 10
      expect(page).to have_content "A measurement of the urea nitrogen in a blood specimen."
    end

  end

  describe "Community User, read-only", :type => :feature do

    before :each do
      ua_community_reader_login
    end

    after :each do
      ua_logoff
    end

    it "allows to display CDISC change instruction, create and edit disabled", js:true do
      click_browse_every_version
      wait_for_ajax 20
      ui_table_search("history", "2016-03-25")
      context_menu_element('history', 5, '2016-03-25 Release', :show)
      wait_for_ajax 20
      ui_child_search("C67154")
      find(:xpath, "//tr[contains(.,'C67154')]/td/a", :text => 'Show').click
      wait_for_ajax 20
      ui_child_search("C125949")
      find(:xpath, "//tr[contains(.,'Urea')]/td/a", :text => 'Show').click
      context_menu_element_header(:change_instructions)
      in_modal do
        expect(page).to have_content "This concept will replace C61019"
        check_link("previous", "icon-codelist-item", "Blood Urea Nitrogen (C61019)")
        check_link("current", "icon-codelist-item", "Urea Nitrogen (C125949)")
        expect(find("#change-instructions-modal")).not_to have_css(".icon-edit")
        expect(find("#change-instructions-modal")).not_to have_css(".icon-times")
        # expect(find("#change-instructions-modal")).to have_content("Owned by CDISC")
        expect(page).not_to have_css("#add-ci-button")
        click_on "Close"
      end
    end

  end

end
