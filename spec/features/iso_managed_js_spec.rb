require 'rails_helper'

describe "ISO Managed JS", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include NameValueHelpers
  include WaitForAjaxHelper
  include TokenHelpers

  def sub_dir
    return "features/iso_managed"
  end

  before :all do
    data_files = []
    load_files(schema_files, data_files)
    load_data_file_into_triple_store("mdr_identification.ttl")
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

  describe "Document Control, Code List, Curator User", type: :feature, js: true do

    it "allows to view the Document Control page, initial state" do
      new_cl_and_dc

      expect(page).to have_content "Document Control"
      dc_check_version '0.1.0'
      dc_check_version_label 'None'
      dc_check_current :not_standard
      dc_check_statuses('Incomplete', 'Candidate')
    end

    it "allows to update version information" do
      new_cl_and_dc

      dc_forward_to 'Candidate'
      wait_for_ajax 10
      
      # Semantic version
      find('#version .bg-label').click 
      select 'major'
      click_on('sp-submit')
      wait_for_ajax 10 
      dc_check_version '1.0.0'

      # Dismiss Edit 
      find('#version .bg-label').click 
      click_on('sp-dismiss')
      dc_check_version '1.0.0'

      # Version label 
      find('#version-label .bg-label').click
     
      # Validation 
      fill_in 'Version label', with: 'Test version æ'
      click_on('sp-submit')
      wait_for_ajax 10 
      expect(page).to have_content('contains invalid characters')

      fill_in 'Version label', with: 'Test version'
      click_on('sp-submit')
      wait_for_ajax 10 
      dc_check_version_label 'Test version'
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
        dc_check_statuses(state, states[i+1])
      end 

      # Check Superseded disables UI
      expect(page).not_to have_selector ('#details-wrap')
      expect(page).not_to have_selector ('#state-next')
      expect( find('#next-status')[:class] ).to include ('disabled')
    end

    it "allows to add notes when updating item state" do
      new_cl_and_dc
      
      fill_in 'Administrative note', with: 'Test Admin Note ææ'
      fill_in 'Unresolved issue', with: 'Issue'

      # Validation
      click_on 'Forward to Next'
      wait_for_ajax 10
      expect(page).to have_content('Administrative note contains invalid characters')
      fill_in 'Administrative note', with: 'Test Admin Note'
      
      dc_forward_to 'Candidate'
      dc_check_statuses('Candidate', 'Recorded')
    end
    
    it "allows to fast forward item state to Release and rewind to Draft"

    it "allows to fast forward and rewind item with dependencies"

    it "allows to rewind item back to Draft state"

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

    def dc_check_version(version)
      expect( find('#version') ).to have_content(version)
      expect( find('.semantic-version') ).to have_content(version) 
    end

    def dc_check_version_label(version_label)
      expect( find('#version-label') ).to have_content(version_label) 
      expect( find('#imh_header .version-label') ).to have_content(version_label) unless version_label.eql?('None')
    end

    def dc_check_statuses(current_status, next_status = nil)
      expect( find('#status .status') ).to have_content(current_status) 
      expect( find('#imh_header .state') ).to have_content(current_status)
      expect( find('#status-next .status') ).to have_content(next_status) unless next_status.nil? 
    end

    def dc_check_current(type)
      current = find('#current')

      case type 
      when :is_current 
        expect( current ).to have_selector('.icon-sel-filled')
      when :not_standard
        expect( current ).to have_content('Item status is not Standard')
      when :can_be_current  
        expect( current ).to have_button('Make Current')
      end 
    end

    def get_current_state
      find('#status .status').text
    end 

    def dc_forward_to(state)
      while not get_current_state.eql?(state) do 
        click_on 'Forward to Next'
        wait_for_ajax 10 
        expect(page).to have_content('Changed Status to')
      end
    end

  end

end
