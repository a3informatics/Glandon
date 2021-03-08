require 'rails_helper'

describe "Thesauri Subsets", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include NameValueHelpers
  include ItemsPickerHelpers
  include TokenHelpers
  include EditorHelpers

  def sub_dir
    return "features/thesaurus/subset"
  end

  def add_or_remove_items(identifiers)
    find('#tab-source').click
    identifiers.each do |identifier|
      find(:xpath, "//tr[contains(.,'#{identifier}')]").click
      wait_for_ajax 10
    end
  end

  describe "Subsets Draft State", type: :feature, js:true do

    before :all do
      data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
      load_files(schema_files, data_files)
      Token.delete_all
      nv_destroy
      nv_create({parent: '10', child: '999'})
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_content_admin_login
    end

    after :each do
      Token.delete_all
      ua_logoff
    end

    it "allows to create a new Code List, Edit page, initial state", js: true do
      click_navbar_code_lists
      wait_for_ajax 10

      ui_new_code_list
      wait_for_ajax 10

      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10

      (1..5).each_with_index do |x, index|
        click_on "New item"
        wait_for_ajax 10
        ui_editor_select_by_location 1, 2
        ui_editor_fill_inline "notation", "ITEM#{index+1}\n"
        ui_press_key :arrow_right
        ui_press_key :enter
        ui_editor_fill_inline "preferred_term", "ITEM#{index+1} PT\t"
        ui_press_key :enter
        ui_editor_fill_inline "synonym", "SYN#{index+1}\n"
        ui_editor_select_by_content "Not Set"
        ui_editor_fill_inline "definition", "We never fill this in, too tricky!\n"
      end

      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax 10

      context_menu_element_v2("history", "0.1.0", :show)
      wait_for_ajax 10

      context_menu_element_header(:subsets)

      ui_in_modal do
        expect(page).to have_content("No subsets found.")
        click_on "+ New Subset"
      end

      ui_in_modal do
        click_on 'Do not select'
      end

      add_or_remove_items ["NC00001003C", "NC00001002C"]

      click_navbar_code_lists
      wait_for_ajax 10
      ui_table_search("index", "NP000010P")
      find(:xpath, "//tr[contains(.,'NP000010P')]/td/a").click
      wait_for_ajax 10
      context_menu_element_v2("history", "0.1.0", :edit)
      wait_for_ajax 10

      ui_editor_select_by_location 1, 3
      ui_editor_fill_inline "preferred_term", "Updated Pt\t"
      ui_editor_check_value 1, 3, "Updated Pt"
      
    end

  end

end
