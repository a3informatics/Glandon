require 'rails_helper'

describe "Biomedical Concept Instances", :type => :feature do

  include DataHelpers
  include UserAccountHelpers
  include UiHelpers
  include ItemsPickerHelpers
  include EditorHelpers
  include WaitForAjaxHelper
  include DownloadHelpers
  include IsoManagedHelpers 

  def sub_dir
    return "features/biomedical_concepts"
  end

  def total_bcs
    14
  end

  describe "BCs", :type => :feature, js: true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..68)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_local_bc_template_and_instances
      load_data_file_into_triple_store("complex_datatypes.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows access to index page (REQ-MDR-MIT-015)" do
      click_navbar_bc
      wait_for_ajax 20
      find(:xpath, "//a[@href='/biomedical_concept_instances']").click
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_check_table_info("index", 1, 10, total_bcs) # Update total BCs number if test fails 
      find(:xpath, "//table[@id='index']/thead/tr/th[contains(.,'Label')]").click #Order data
      ui_check_table_cell("index", 3, 2, "BMI")
      ui_check_table_cell("index", 3, 3, "BMI")
    end

    it "allows the history page to be viewed" do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HEIGHT\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 4, "HEIGHT")
      ui_check_table_cell("history", 1, 5, "Height")
      ui_check_table_cell("history", 1, 7, "Incomplete")
    end

    it "history allows ttl to be exported", js:true do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HEIGHT\''
      context_menu_element_v2('history', 'HEIGHT', :export_ttl)
      file = download_content
    # write_text_file_2(file, sub_dir, "bc_export_ttl_expected.ttl")
      expected = read_text_file_2(sub_dir, "bc_export_ttl_expected.ttl")
      expect(file).to eq(expected)
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)" do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HEIGHT\''
      context_menu_element_v2('history', 'HEIGHT', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      expect(page).to have_content 'Incomplete'
      ui_check_table_info("show", 1, 10, 12)
      ui_check_table_cell("show", 7, 3, "--ORRES")
      ui_check_table_cell("show", 7, 4, "Result")
      ui_check_table_cell("show", 7, 5, "Height")
      ui_check_table_cell("show", 7, 6, "PQR")
      ui_check_table_cell("show", 7, 7, "5.2")
      ui_check_table_cell("show", 1, 8, "HEIGHT C25347 (VSTESTCD C66741 v24.0.0)")
    end

    it "show page has terminology reference links" do
      click_navbar_bc
      wait_for_ajax 10
      ui_table_search('index', 'Heart Rate')
      find(:xpath, "//tr[contains(.,'Heart Rate')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'HR\''
      context_menu_element_v2('history', 'HR', :show)
      wait_for_ajax 10
      click_on "ARM C32141 (LOC C74456 v38.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'Shared Preferred Terms'
      expect(page).to have_content 'C32141'
      expect(page).to have_content 'The portion of the upper extremity between the shoulder and the elbow.'
      page.go_back
      click_on "HR C49677 (VSTESTCD C66741 v24.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'C49677'
      expect(page).to have_content 'The number of heartbeats per unit of time, usually expressed as beats per minute.'
    end

    it "allows to download show BC table as a csv file" do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search('index', 'DIABP')
      find(:xpath, "//tr[contains(.,'DIABP')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'DIABP\''
      context_menu_element_v2('history', 'DIABP', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 10, 12)
      click_on 'CSV'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_csv_expected.csv")
    end

    it "allows to download show BC table as an excel file" do
      click_navbar_bc
      wait_for_ajax 10
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_table_search("index", "WEIGHT")
      find(:xpath, "//tr[contains(.,'WEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'WEIGHT\''
      context_menu_element_v2('history', 'WEIGHT', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Biomedical Concept'
      ui_check_table_info("show", 1, 10, 12)
      click_on 'Excel'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_excel_expected.xlsx")
    end

    # it "allows for a BC to be cloned", js:true do

  end

  describe "Create, Delete a BC", :type => :feature, js: true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..68)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_local_bc_template_and_instances
      load_data_file_into_triple_store("complex_datatypes.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows to create a new BC" do
      click_navbar_bc
      wait_for_ajax 20
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_on 'New Biomedical Concept'

      ui_in_modal do
        fill_in 'identifier', with: 'BC Test'
        fill_in 'label', with: 'Test Label'
        find('#new-item-template').click
        ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS PQR', version: '1' } ], 'new-bc')

        click_on 'Submit'
      end

      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'BC Test\''
    end

    # Depends on previous test
    it "create BC, clear fields, field validation" do
      click_navbar_bc
      wait_for_ajax 20
      expect(page).to have_content 'Index: Biomedical Concepts'
      click_on 'New Biomedical Concept'

      ui_in_modal do
        click_on 'Submit'

        # Empty fields validation
        expect(page).to have_content('Field cannot be empty', count: 3)
        expect(page).to have_selector('.form-group.has-error', count: 3)

        fill_in 'identifier', with: 'BC Test'
        fill_in 'label', with: 'Test Label'

        click_on 'Submit'

        expect(page).to have_content('Field cannot be empty', count: 1)
        expect(page).to have_selector('.form-group.has-error', count: 1)

        click_on 'Clear fields'

        expect(find_field('identifier').value).to eq('')
        expect(find_field('label').value).to eq('')

        # Special characters validation
        fill_in 'identifier', with: 'BC Tææst'
        fill_in 'label', with: 'Test Label'
        find('#new-item-template').click
        ip_pick_managed_items(:bct, [ { identifier: 'BASIC OBS PQR', version: '1' } ], 'new-bc')

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content('contains invalid characters', count: 1)

        # Duplicate identifier validation
        fill_in 'identifier', with: 'BC Test'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content 'already exists in the database'
        click_on 'Close'
      end

    end

    it "allows to delete a BC" do
      # Create a new BC and delete
      ui_create_bc('DELETE BC', 'BC Label', { identifier: 'BASIC OBS PQR', version: '1' })

      bc_count = BiomedicalConceptInstance.all.count

      context_menu_element_v2('history', 'Incomplete', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( BiomedicalConceptInstance.all.count ).to eq bc_count-1
    end

    it "allows to delete an existing BC" do
      click_navbar_bc
      wait_for_ajax 10

      ui_table_search("index", "WEIGHT")
      find(:xpath, "//tr[contains(.,'WEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10

      bc_count = BiomedicalConceptInstance.all.count

      context_menu_element_v2('history', 'Incomplete', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( BiomedicalConceptInstance.all.count ).to eq bc_count-1
    end

  end

  describe "BCs, Document Control", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..68)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_local_bc_template_and_instances
      load_data_file_into_triple_store("complex_datatypes.ttl")
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows to update a BC status, version and version label" do
      click_navbar_bc
      wait_for_ajax 20

      ui_table_search('index', 'HEIGHT')
      find(:xpath, "//tr[contains(.,'HEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10

      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax 10

      dc_check_status('Incomplete')
      dc_check_version('0.1.0')

      dc_forward_to('Candidate')
      dc_check_status('Candidate')

      dc_update_version('1.0.0')
      dc_update_version_label('BC Version Label')

      dc_forward_to('Standard')
    
      click_on 'Return'
      wait_for_ajax 10

      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'BC Version Label'
    end

    it "allows multiple edits enable and disable on a BC in locked state" do
      click_navbar_bc
      wait_for_ajax 20

      ui_table_search('index', 'WEIGHT')
      find(:xpath, "//tr[contains(.,'WEIGHT')]/td/a", :text => 'History').click
      wait_for_ajax 10

      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax 10

      dc_forward_to('Recorded')
      click_on 'Return'
      wait_for_ajax 10

      ui_check_table_info('history', 1, 1, 1)
      expect(page).to have_css '.registration-state .icon-lock'

      find('.registration-state').click
      wait_for_ajax 10
      expect(page).to have_css '.registration-state .icon-lock-open'

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax 10

      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_info('history', 1, 1, 1)

      find('.registration-state').click
      wait_for_ajax 10
      expect(page).to have_css '.registration-state .icon-lock'

      context_menu_element_v2('history', '0.1.0', :edit)
      wait_for_ajax 10

      click_on 'Return'
      wait_for_ajax 10
      ui_check_table_info('history', 1, 2, 2)

      # Check data copied when new version created
      context_menu_element_v2('history', 1, :show)
      wait_for_ajax 30
      ui_check_table_info('show', 1, 10, 12)

    end

    it "allows to create a new version off Standard BCs on Edit" do
      ui_create_bc('TST BC 2', 'Test BC Label', { identifier: 'BASIC OBS PQR', version: '1' })

      # Creates a new version off of Standard
      context_menu_element_v2('history', '0.1.0', :document_control)

      dc_forward_to('Recorded')
      dc_update_version('1.0.0')
      dc_forward_to('Standard')

      ui_create_bc('TST BC 3', 'Test BC Label', { identifier: 'BASIC OBS PQR', version: '1' })
      # Creates a new version off of Standard
      context_menu_element_v2('history', '0.1.0', :document_control)

      dc_forward_to('Recorded')
      dc_update_version('1.0.0')
      dc_forward_to('Standard')
      click_on 'Return'
      wait_for_ajax 10

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax 10

      click_on 'Add a BC to Editor'
      ui_in_modal do
        ip_pick_managed_items :bci, [ { identifier: 'TST BC 2', version: '1' } ], 'add-bc-edit'
      end
      wait_for_ajax 10

      click_on 'Return'
      wait_for_ajax 10

      ui_check_table_info('history', 1, 2, 2)
      ui_check_table_cell('history', 1, 7, 'Incomplete')
      ui_check_table_cell('history', 1, 1, '1.1.0')

      click_navbar_bc
      wait_for_ajax 10
      ui_table_search('index', 'TST BC 2')
      find(:xpath, "//tr[contains(.,'TST BC 2')]/td/a", :text => 'History').click
      wait_for_ajax 10
      ui_check_table_info('history', 1, 2, 2)
      ui_check_table_cell('history', 1, 7, 'Incomplete')
      ui_check_table_cell('history', 2, 7, 'Standard')
      ui_check_table_cell('history', 1, 1, '1.1.0')
      ui_check_table_cell('history', 2, 1, '1.0.0')
    end

  end

end
