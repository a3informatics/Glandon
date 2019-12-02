require 'rails_helper'

describe "Change Notes", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper

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
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl",
                    "thesaurus.ttl", "BusinessOperational.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)
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

    it "allows viewing change notes modal", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C67153')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C67153")
      expect(page).to have_content("No change notes found")
      click_button "Close"
    end

    it "allows to create a change note", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
      add_change_note("Some reference name", "String of text for the newly created change note.")
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      add_change_note("Another reference name", "And another string of text for the newly created change note.")
      check_change_note("#cn-1", "Another reference name", "And another string of text for the newly created change note.", "curator@example.com")
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to edit a change note", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
      expect(page).to have_css(".note", count: 2)
      fill_in_change_note("#cn-1", "New reference", "New CN text")
      page.find("#save-cn-1-button").click
      wait_for_ajax(20)
      check_change_note("#cn-1", "New reference", "New CN text", "curator@example.com")
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to discard edit changes on change note", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
      expect(page).to have_css(".note", count: 2)
      fill_in_change_note("#cn-0", "Some reference", "Some text")
      page.find("#cancel-cn-0-button").click
      expect(page).to have_content("Your unsaved changes will be lost.")
      click_button "Yes"
      check_change_note("#cn-0", "Some reference name", "String of text for the newly created change note.", "curator@example.com")
      click_button "+ Add new"
      expect(page).to have_css ("#cn-new")
      fill_in_change_note("#cn-new", "Discard reference", "Discard text")
      page.find("#cancel-cn-new-button").click
      expect(page).to have_content("Your unsaved changes will be lost.")
      click_button "Yes"
      expect(page).to have_css(".note", count: 2)
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows to delete a change note", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
      expect(page).to have_css(".note", count: 2)
      page.find("#del-cn-0-button").click
      expect(page).to have_content("You cannot undo this operation.")
      click_button "Yes"
      wait_for_ajax(20)
      expect(page).to have_css(".note", count: 1)
      click_button "Close"
    end

    # Depends on the previous test(s)
    it "allows change note field validation", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
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
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66786')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C66786")
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
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66784')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C48275')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C48275")
      expect(page).to have_content("No change notes found")
      click_button "Close"
    end

    it "allows to create, edit and delete a change note", js:true do
      click_navbar_cdisc_terminology
      wait_for_ajax(20)
      context_menu_element("history", 5, "2007-04-20 Release", :show)
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C66784')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      find(:xpath, "//tr[contains(.,'C48275')]/td/a", :text => 'Show').click
      wait_for_ajax(20)
      context_menu_element_header(:change_notes)
      expect(page).to have_content("Change notes for C48275")
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

end
