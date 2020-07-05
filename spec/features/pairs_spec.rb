require 'rails_helper'

describe "Pairs", :type => :feature do

  include PauseHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include UiHelpers

  before :all do
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..2)

    ua_create
    nv_destroy
    nv_create(parent: "10", child: "999")
    set_transactional_tests false
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  after :all do
    ua_destroy
    nv_destroy
    set_transactional_tests true
  end

  # Interdependent tests, run as a whole

  describe "Pair Code Lists, Curator user", :type => :feature do

    def prepare_data
      cl1 = Thesaurus::ManagedConcept.create
      cl1.update({notation: "TESTCD"})
      cl2 = Thesaurus::ManagedConcept.create
      cl2.update({notation: "TEST"})
    end

    def go_to_cl(identifier, action)
      click_navbar_code_lists
      wait_for_ajax 20
      ui_table_search("index", identifier)
      find(:xpath, "//tr[contains(.,'#{identifier}')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", action)
      wait_for_ajax 10
    end

    it "allows to pair Code Lists", js: true do
      prepare_data
      go_to_cl("NP000010P", :edit)

      expect(context_menu_element_header_present?(:pair)).to eq(true)
      context_menu_element_header(:pair)
      ui_selector_pick_managed_items("Code Lists", [{identifier: "NP000011P", version: "1"}])
      wait_for_ajax 10
      expect(context_menu_element_header_present?(:unpair)).to eq(true)

      # TODO: Check indicators in header
    end

    it "prevents pairing Code Lists, validation fail", js:true do
      cl = Thesaurus::ManagedConcept.create

      go_to_cl(cl.has_identifier.identifier, :edit)

      context_menu_element_header(:pair)
      ui_selector_pick_managed_items("Code Lists", [{identifier: "C25464", version: "1"}])

      expect(context_menu_element_header_present?(:pair)).to eq(true)
      expect(page).to have_content "Pairing not permitted, trying to pair Not Set with COUNTRY."
    end

    it "allows to link to Show of paired Code Lists from both paired items", js: true do
      go_to_cl("NP000010P", :show)
      expect(context_menu_element_header_present?(:show_paired)).to eq(true)
      context_menu_element_header(:show_paired)
      expect(page).to have_content "NP000011P"

      go_to_cl("NP000011P", :show)
      expect(context_menu_element_header_present?(:show_paired)).to eq(true)
      context_menu_element_header(:show_paired)
      expect(page).to have_content "NP000010P"
    end

    it "prevents pairing on an already paired item", js: true do
      go_to_cl("NP000011P", :edit)

      expect(context_menu_element_header_present?(:unpair)).to eq(false)
      expect(context_menu_element_header_present?(:pair)).to eq(false)
    end

    it "allows to unpair Code Lists", js:true do
      go_to_cl("NP000010P", :edit)

      expect(context_menu_element_header_present?(:unpair)).to eq(true)
      context_menu_element_header(:unpair)
      wait_for_ajax 10
      sleep 1
      
      expect(context_menu_element_header_present?(:pair)).to eq(true)
    end

    it "prevents pairing when token expired", js: true do
      Token.set_timeout(5)
      go_to_cl("NP000010P", :edit)

      sleep 7
      context_menu_element_header(:pair)
      ui_selector_pick_managed_items("Code Lists", [{identifier: "NP000011P", version: "1"}])
      expect(page).to have_content "The changes were not saved as the edit lock has timed out."
    end

  end

end