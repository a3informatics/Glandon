require 'rails_helper'

describe "ISO Managed JS", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include NameValueHelpers
  include WaitForAjaxHelper
  include TokenHelpers
  include IsoManagedHelpers

  def sub_dir
    return "features/iso_managed"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
    Token.delete_all
    nv_destroy
    nv_create({parent: '10', child: '999'})
    ua_create
    set_transactional_tests false 
  end

  after :all do
    ua_destroy
    nv_destroy
    set_transactional_tests true 
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  def go_to_dc(identifier, version)
    ui_table_search('index', identifier)
    find(:xpath, "//tr[contains(.,'#{ identifier }')]/td/a").click
    wait_for_ajax 10
    context_menu_element_v2('history', version, :document_control)
    wait_for_ajax 10
  end 

  describe "Document Control, Code List, Curator User", type: :feature, js: true do

    it "allows to view the Document Control page, initial state" do
      new_cl_and_dc

      expect(page).to have_content "Document Control"
      dc_check_version '0.1.0'
      dc_check_version_label 'None'
      dc_check_current :not_standard
      dc_check_status('Incomplete', 'Candidate')
    end

    it "allows to update version information" do
      new_cl_and_dc

      dc_forward_to 'Candidate'
      wait_for_ajax 10
      
      # Semantic version
      dc_update_version('1.0.0')

      # Dismiss Edit 
      find('#version .bg-label').click 
      click_on('sp-dismiss')
      dc_check_version '1.0.0'

      # Version label (with validation)
      dc_update_version_label('Test version æ', success: false)
      expect(page).to have_content('contains invalid characters')
      click_on 'sp-dismiss'

      dc_update_version_label('Test version')
    end

    it "allows to make item current" do
      new_cl_and_dc

      dc_forward_to 'Standard'
      wait_for_ajax 10

      dc_check_current :not_current

      click_on 'Make Current'
      wait_for_ajax 10 
      dc_check_current :current 
    end
    
    it "allows to forward item through states" do
      states = ['Candidate', 'Recorded', 'Qualified', 'Standard', 'Superseded']

      new_cl_and_dc

      states.each_with_index do |state, i|
        click_on 'Forward to Next'
        ui_confirmation_dialog true if state.eql?('Superseded')
        wait_for_ajax 10 
        expect(page).to have_content("Changed Status to #{ state }")
        dc_check_status(state, states[i+1])
      end 

      # Check Superseded disables UI
      expect(page).not_to have_selector ('#details-wrap')
      expect(page).not_to have_selector ('#state-next')
      expect( find('#next-status')[:class] ).to include ('disabled')
    end

    it "allows to add notes when updating item state, WILL CURRENTLY FAIL: Notes not used on server" do
      new_cl_and_dc
      
      fill_in 'Administrative note', with: 'Test Admin Note ææ'
      fill_in 'Unresolved issue', with: 'Issue'

      # Forward to next
      click_on 'Forward to Next'
      wait_for_ajax 10
      expect(page).to have_content('Administrative note contains invalid characters')
      fill_in 'Administrative note', with: 'Test Admin Note'
      
      dc_forward_to 'Candidate'
      dc_check_status('Candidate', 'Recorded')

      # Fast Forward 
      fill_in 'Administrative note', with: 'Test Admin Note ææ'
      fill_in 'Unresolved issue', with: 'Issue'

      click_on 'Forward to Release'
      wait_for_ajax 10
      expect(page).to have_content('Administrative note contains invalid characters')
      fill_in 'Administrative note', with: 'Test Admin Note'

      click_on 'Forward to Release'
      dc_check_status('Standard')

      # Rewind Back
      fill_in 'Administrative note', with: 'Test Admin Note ææ'
      fill_in 'Unresolved issue', with: 'Issue'

      click_on 'Rewind to Draft'
      wait_for_ajax 10
      expect(page).to have_content('Administrative note contains invalid characters')
      fill_in 'Administrative note', with: 'Test Admin Note'

      click_on 'Rewind to Draft'
      dc_check_status('Incomplete')
    end
    
    it "allows to fast forward item state to Release and rewind to Draft" do
      new_cl_and_dc

      # Fast Forward from Draft
      click_on 'Forward to Release'
      wait_for_ajax 10 
      dc_check_status('Standard')

      # Rewind from Release
      click_on 'Rewind to Draft'
      wait_for_ajax 10 
      dc_check_status('Incomplete')

      # Fast Forward from Recorded 
      dc_forward_to('Recorded')
      click_on 'Forward to Release'
      wait_for_ajax 10 
      dc_check_status('Standard')

      # Rewind
      click_on 'Rewind to Draft'
      wait_for_ajax 10 
      dc_check_status('Incomplete')

      # Rewind from Qualified 
      dc_forward_to('Qualified')
      click_on 'Rewind to Draft'
      wait_for_ajax 10 
      dc_check_status('Incomplete')
    end

    it "allows to fast forward and rewind item with dependencies" do
      # Data
      codelist = Thesaurus::ManagedConcept.create
      subset = codelist.create_subset 
      subset2 = codelist.create_subset 

      click_navbar_code_lists
      wait_for_ajax 10 
      go_to_dc(codelist.has_identifier.identifier, 'Incomplete')

      # Checkbox 
      dc_click_with_dependencies
      expect( find('#next-status')[:class] ).to include('disabled')

      # Fast Forward
      click_on 'Forward to Release'

      ui_in_modal do
        ui_check_table_info('managed-items', 1, 3, 3)
        ui_check_table_cell('managed-items', 2, 3, '0.1.0')
        ui_check_table_cell('managed-items', 2, 7, 'Incomplete')
        expect( find('#managed-items') ).to have_selector('.icon-sel-filled', count: 3)
        click_on 'Confirm and proceed'
      end
      wait_for_ajax 10 
      expect(page).to have_content 'Changed Status of 3 items to Standard'
    
      # Rewind
      click_on 'Rewind to Draft'
      ui_in_modal do
        ui_check_table_info('managed-items', 1, 3, 3)
        ui_check_table_cell('managed-items', 2, 3, '0.1.0')
        ui_check_table_cell('managed-items', 2, 7, 'Standard')
        expect( find('#managed-items') ).to have_selector('.icon-sel-filled', count: 3)
        click_on 'Confirm and proceed'
      end
      wait_for_ajax 10 
      expect(page).to have_content 'Changed Status of 3 items to Incomplete'
      
      # Move Subset 2 to Superseded 
      for i in 1..5
        subset2.next_state({})
      end

      click_on 'Forward to Release'

      # Prevents bulk Fast Forward if not all dependencies qualify
      ui_in_modal do
        expect( find('#managed-items') ).to have_selector('.icon-sel-filled', count: 2)
        ui_check_table_cell('managed-items', 3, 7, 'Superseded')
        ui_check_table_cell_icon('managed-items', 3, 8, 'times-circle')
        expect( find('#modal-submit')[:class] ).to include('disabled')
        click_on 'Close'
      end

    end

    it "removes the Current flag when rewinding to draft" do
      new_cl_and_dc
      
      click_on 'Forward to Release'
      wait_for_ajax 10 
      click_on 'Make Current'
      wait_for_ajax 10 

      dc_check_current :is_current 

      click_on 'Rewind to Draft'
      wait_for_ajax 10

      dc_check_current :not_standard 
    end

    it "token timers, warnings, extension and expiration" do

      token_ui_check(@user_c) do
        new_cl_and_dc
      end 

    end

    it "token timer, expires edit lock, prevents changes" do

      go_to_edit = proc { new_cl_and_dc }
      do_an_edit = proc do 
        click_on 'Forward to Next'
        wait_for_ajax 10
      end 

      token_expired_check(go_to_edit, do_an_edit)
 
    end

    it "releases edit lock on page leave" do

      token_clear_check do 
        new_cl_and_dc
      end

    end
    
    # Helpers 

    def new_cl_and_dc
      click_navbar_code_lists
      wait_for_ajax 10 
      ui_new_code_list
      context_menu_element_v2('history', 'Incomplete', :document_control)
      wait_for_ajax 10
    end

  end

end
