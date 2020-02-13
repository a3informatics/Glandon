require 'rails_helper'

describe "Change Notes", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers

  def wait_for_ajax_long
    wait_for_ajax(20)
  end

  def add_change_note(ref, text)
    click_button "+ Add new"
    expect(page).to have_css ("#cn-new")
    fill_in_change_note("#cn-new", ref, text)
    page.find("#save-cn-new-button").click
    wait_for_ajax(20)
  end

  def fill_in_change_note(id, ref, text)
    page.find("#{id}-ref").click
    sleep 0.2
    page.find("#{id}-ref").set(ref)
    page.find("#{id}-text").click
    sleep 0.2
    page.find("#{id}-text").set(text)
  end

  def check_change_note(id, ref, text, email)
    expect(page.find("#{id}-email").text).to eq(email)
    expect(page.find("#{id}-ref").text).to eq(ref)
    expect(page.find("#{id}-text").text).to eq(text)
  end

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
    NameValue.destroy_all
    NameValue.create(name: "thesaurus_parent_identifier", value: "10")
    NameValue.create(name: "thesaurus_child_identifier", value: "999")
    ua_create
  end

  after :all do
    ua_destroy
  end

  describe "Curator user (sponsor code list level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change notes modal", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      page.find("#tnb_new_button").click
      wait_for_ajax(20)
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_content("No change notes found")
      click_button "Close"
    end

    it "allows viewing change notes modal, edit page", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :edit)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_content("No change notes found")
      click_button "Close"
    end

    it "allows to create a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      add_change_note("Another reference name", "And another string of text for the newly created change note.")
      check_change_note("#cn-1", "Another reference name", "And another string of text for the newly created change note.", "curator@example.com")
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to edit a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_css(".note", count: 2)
      fill_in_change_note("#cn-1", "New reference", "New CN text")
      page.find("#save-cn-1-button").click
      wait_for_ajax(20)
      check_change_note("#cn-1", "New reference", "New CN text", "curator@example.com")
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to discard edit changes on change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_css(".note", count: 2)
      fill_in_change_note("#cn-0", "Some reference", "Some text")
      page.find("#cancel-cn-0-button").click
      ui_confirmation_dialog true
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      click_button "+ Add new"
      expect(page).to have_css ("#cn-new")
      fill_in_change_note("#cn-new", "Discard reference", "Discard text")
      page.find("#cancel-cn-new-button").click
      ui_confirmation_dialog true
      expect(page).to have_css(".note", count: 2)
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to delete a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_css(".note", count: 2)
      page.find("#del-cn-0-button").click
      ui_confirmation_dialog true
      expect(page).to have_css(".note", count: 1)
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows change note field validation", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_css(".note", count: 1)
      fill_in_change_note("#cn-0", " ", " ")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      expect(page).to have_css(".alert", count: 2)
      expect(page).to have_content("Reference is empty")
      expect(page).to have_content("Description is empty")
      click_button "Close"
    end

  end


  describe "Content admin user", :type => :feature do

    before :each do
      ua_content_admin_login
    end

    after :each do
      ua_logoff
    end

    # Depends on the previous test(s)
    it "allows to edit a change note, another user", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NP000010P")
      expect(page).to have_css(".note", count: 1)
      check_change_note("#cn-0", "New reference", "New CN text", "curator@example.com")
      fill_in_change_note("#cn-0", "Edited reference", "Edited change note text by another user")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      check_change_note("#cn-0", "Edited reference", "Edited change note text by another user", "content_admin@example.com")
      click_button "Close"
    end

  end

  describe "Community reader user", :type => :feature do

    before :each do
      ua_comm_reader_login
    end

    after :each do
      ua_logoff
    end

    it "prevents access to change notes, code list level", js:true do
      click_browse_every_version
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66790')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      Capybara.ignore_hidden_elements = false
      expect(page).to have_link("Export CSV")
      expect(page).to_not have_link("Change notes")
      Capybara.ignore_hidden_elements = true
    end

    it "prevents access to change notes, code list item level", js:true do
      click_browse_every_version
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66784')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C48275')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      Capybara.ignore_hidden_elements = false
      expect(page).to have_link("Return")
      expect(page).to_not have_link("Change notes")
      Capybara.ignore_hidden_elements = true
    end

  end

  describe "Curator user (code list item level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change notes modal", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :edit)
      wait_for_ajax(20)
      page.find("#tnp_new_button").click
      wait_for_ajax(20)
      page.go_back
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'NC00000999C')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NC00000999C")
      expect(page).to have_content("No change notes found")
      click_button "Close"
    end

    it "allows to create, edit and delete a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax(20)
      context_menu_element("history", 5, "NP000010P", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'NC00000999C')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for NC00000999C")
      # Add CN
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      # Edit CN
      fill_in_change_note("#cn-0", "Edited reference", "Edited change note text")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      check_change_note("#cn-0", "Edited reference", "Edited change note text", "curator@example.com")
      # Delete CN
      page.find("#del-cn-0-button").click
      expect(page).to have_content("You cannot undo this operation.")
      click_button "Yes"
      wait_for_ajax(20)
      expect(page).to have_css(".note", count: 0)
      click_button "Close"
    end

  end

  describe "Curator user (Extension)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change notes modalm edit page", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66790')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:extend)
      sleep 0.5
      click_button "Do not select"
      wait_for_ajax(20)
      expect(page).to have_content("Edit Extension")
      expect(context_menu_element_header_present?(:change_notes)).to eq(true)
      context_menu_element_header(:change_notes)
      sleep 0.5
      wait_for_ajax(20)
      expect(page).to have_content("Change notes for C66790E")
      expect(page).to have_content("No change notes found")
      click_button "Close"
      sleep 0.5
    end

    it "allows to create, edit and delete a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(50)
      ui_table_search("index", "C66790E")
      find(:xpath, "//tr[contains(.,'C66790E')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 8, 'C66790E', :edit)
      wait_for_ajax(20)
      expect(page).to have_content("Edit Extension")
      expect(page).to have_content("C66790E")
      context_menu_element_header(:change_notes)
      sleep 0.5
      expect(page).to have_content("Change notes for C66790E")
      # Add CN
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      # Edit CN
      fill_in_change_note("#cn-0", "Edited reference", "Edited change note text")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      check_change_note("#cn-0", "Edited reference", "Edited change note text", "curator@example.com")
      # Delete CN
      page.find("#del-cn-0-button").click
      expect(page).to have_content("You cannot undo this operation.")
      click_button "Yes"
      wait_for_ajax(20)
      expect(page).to have_css(".note", count: 0)
      click_button "Close"
      sleep 0.5
    end

  end

  describe "Curator user (Subset)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change notes modal, edit page", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66790')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:subsets)
      sleep 0.5
      page.find("#new_subset").click
      sleep 1
      click_button "Do not select"
      wait_for_ajax(20)
      expect(page).to have_content("Edit Subset")
      expect(context_menu_element_header_present?(:change_notes)).to eq(true)
      context_menu_element_header(:change_notes)
      sleep 0.5
      wait_for_ajax(20)
      expect(page).to have_content("Change notes for NP000011P")
      expect(page).to have_content("No change notes found")
      click_button "Close"
      sleep 0.5
    end

    it "allows to create, edit and delete a change note", js:true do
      click_navbar_code_lists
      wait_for_ajax(50)
      ui_table_search("index", "NP000011P")
      find(:xpath, "//tr[contains(.,'NP000011P')]/td/a").click
      wait_for_ajax(10)
      context_menu_element("history", 8, 'NP000011P', :edit)
      wait_for_ajax(20)
      expect(page).to have_content("Edit Subset")
      expect(page).to have_content("NP000011P")
      context_menu_element_header(:change_notes)
      sleep 0.5
      expect(page).to have_content("Change notes for NP000011P")
      # Add CN
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      # Edit CN
      fill_in_change_note("#cn-0", "Edited reference", "Edited change note text")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      check_change_note("#cn-0", "Edited reference", "Edited change note text", "curator@example.com")
      # Delete CN
      page.find("#del-cn-0-button").click
      expect(page).to have_content("You cannot undo this operation.")
      click_button "Yes"
      wait_for_ajax(20)
      expect(page).to have_css(".note", count: 0)
      click_button "Close"
      sleep 0.5
    end

  end

  describe "Curator user (thesaurus level)", :type => :feature do

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows viewing change notes modal", js:true do
      ui_create_terminology("CNTST", "CN Test Terminology")
      click_navbar_terminology
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'CNTST')]",).click
      wait_for_ajax(20)
      context_menu_element("history", 5, "CNTST", :show)
      wait_for_ajax(20)
      expect(context_menu_element_header_present?(:change_notes)).to eq(true)
      context_menu_element_header(:change_notes)
      sleep 0.5
      wait_for_ajax(20)
      expect(page).to have_content("Change notes for CNTST")
      expect(page).to have_content("No change notes found")
      click_button "Close"
      sleep 0.5
    end

    it "allows viewing change notes modal, edit page", js:true do
      click_navbar_terminology
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'CNTST')]",).click
      wait_for_ajax(20)
      context_menu_element("history", 5, "CNTST", :edit)
      wait_for_ajax(20)
      expect(context_menu_element_header_present?(:change_notes)).to eq(true)
      context_menu_element_header(:change_notes)
      sleep 0.5
      wait_for_ajax(20)
      expect(page).to have_content("Change notes for CNTST")
      expect(page).to have_content("No change notes found")
      click_button "Close"
      sleep 0.5
    end

    it "allows to create, edit and delete a change note", js:true do
      click_navbar_terminology
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'CNTST')]",).click
      wait_for_ajax(20)
      context_menu_element("history", 5, "CNTST", :show)
      wait_for_ajax(20)
      expect(context_menu_element_header_present?(:change_notes)).to eq(true)
      context_menu_element_header(:change_notes)
      sleep 0.5
      wait_for_ajax(20)
      expect(page).to have_content("Change notes for CNTST")
      # Add CN
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      # Edit CN
      fill_in_change_note("#cn-0", "Edited reference", "Edited change note text")
      page.find("#save-cn-0-button").click
      wait_for_ajax(20)
      check_change_note("#cn-0", "Edited reference", "Edited change note text", "curator@example.com")
      # Delete CN
      page.find("#del-cn-0-button").click
      expect(page).to have_content("You cannot undo this operation.")
      click_button "Yes"
      wait_for_ajax(20)
      expect(page).to have_css(".note", count: 0)
      click_button "Close"
      sleep 0.5
    end

  end

  describe "List change notes", :type => :feature do

   before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows to list change notes", js:true do
      click_navbar_code_lists
      wait_for_ajax(20)
      identifier = ui_new_code_list
      wait_for_ajax(20)
      context_menu_element('history', 4, identifier, :show)
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      sleep 1
      click_button "+ Add new"
      fill_in_change_note("#cn-new", "Some reference name", "String of text for the newly created change note.")
      page.find("#save-cn-new-button").click
      wait_for_ajax(20)
      click_button "+ Add new"
      fill_in_change_note("#cn-new", "Another reference name", "And another string of text for the newly created change note.")
      page.find("#save-cn-new-button").click
      wait_for_ajax(20)
      click_button "Close"
      sleep 1
      click_link "Return"
      wait_for_ajax(20)
      context_menu_element('history', 4, identifier, :list_change_notes)
      wait_for_ajax(20)
      expect(page).to have_content("Change Notes of #{identifier} and Children")
      ui_check_table_info("list-change-notes-table", 1, 2, 2)
      page.find("#export-csv")[:href].include?("export_change_notes_csv")
    end

  end

end
