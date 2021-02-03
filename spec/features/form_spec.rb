require 'rails_helper'

describe "Forms", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include IsoManagedHelpers

  def sub_dir
    return "features/forms"
  end

  describe "Forms", :type => :feature do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_file_into_triple_store("forms/FN000150.ttl")
      load_test_file_into_triple_store("forms/FN000120.ttl")
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

    it "allows access to index page (REQ-MDR-MIT-015)", js:true do
      click_navbar_forms
      wait_for_ajax 10
      find(:xpath, "//a[@href='/forms']").click
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//th[contains(.,'Identifier')]").click #Order
      ui_check_table_info("index", 1, 2, 2)
      ui_check_table_cell("index", 1, 2, "FN000120")
      ui_check_table_cell("index", 1, 3, "Disability Assessment For Dementia (DAD) (Pilot)")
    end

    it "allows the history page to be viewed", js:true do
      click_navbar_forms
      wait_for_ajax 10
      expect(page).to have_content 'Index: Forms'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "Height (Pilot)")
      ui_check_table_cell("history", 1, 7, "Incomplete")
    end

    it "history allows the show page to be viewed (REQ-MDR-BC-010)", js:true do
      click_navbar_forms
      wait_for_ajax 10
      expect(page).to have_content 'Index: Forms'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      context_menu_element('history', 4, 'Height (Pilot)', :show)
      wait_for_ajax 10
      expect(page).to have_content 'Show: Form'
      ui_check_table_info("show", 1, 5, 5)
      ui_check_table_cell("show", 5, 3, "Unit")
      ui_check_table_cell("show", 5, 5, "string")
      ui_check_table_cell("show", 5, 6, "20")
      ui_check_table_cell("show", 5, 7, "VSORRESU")
      ui_check_table_cell("show", 3, 4, "Measure with shoes off. Round up or down to the nearest tenth inch or tenth centimeter.")

      # Check correct group styling
      expect(find("table#show tbody tr", match: :first)[:class]).to include("row-subtitle")
    end

    it "history allows the crf page to be viewed (REQ-MDR-BC-???)", js:true do
      click_navbar_forms
      wait_for_ajax 10
      expect(page).to have_content 'Index: Forms'
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      context_menu_element_v2('history', 'Height (Pilot)', :crf)
      wait_for_ajax 10
      expect(page).to have_content 'Not Set'
      expect(page).to have_content 'Compltion Status'
    end

    it "show page has terminology reference links", js:true do
      click_navbar_forms
      wait_for_ajax 10
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      context_menu_element('history', 4, 'Height (Pilot)', :show)
      wait_for_ajax 10
      click_on "NOT DONE C49484 (ND C66789 v3.0.0)"
      wait_for_ajax 10
      expect(page).to have_content 'Shared Preferred Terms'
      expect(page).to have_content 'C49484'
      expect(page).to have_content 'Indicates a task, process or examination that has either not been initiated or completed.'
    end

    it "allows to download show Form table as a csv file", js:true do
      click_navbar_forms
      wait_for_ajax 10
      ui_table_search('index', 'DAD')
      find(:xpath, "//tr[contains(.,'(DAD) (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000120\''
      context_menu_element_v2('history', '(DAD) (Pilot)', :show)
      wait_for_ajax 30
      expect(page).to have_content 'Show: Form'
      ui_check_table_info("show", 1, 10, 225)
      click_on 'CSV'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_csv_expected.csv")
    end

    it "allows to download show Form table as an excel file", js:true do
      click_navbar_forms
      wait_for_ajax 10
      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''
      context_menu_element_v2('history', 'Height (Pilot)', :show)
      wait_for_ajax 30
      expect(page).to have_content 'Show: Form'
      ui_check_table_info("show", 1, 5, 5)
      click_on 'Excel'

      file = download_content
      expected = read_text_file_2(sub_dir, "show_excel_expected.xlsx")
    end

  end

  describe "Create, Delete a Form", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_file_into_triple_store("forms/FN000150.ttl")
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

    it "allows to create a new Form" do
      click_navbar_forms
      wait_for_ajax 20
      expect(page).to have_content 'Index: Forms'
      click_on 'New Form'

      ui_in_modal do
        fill_in 'identifier', with: 'FORM Test'
        fill_in 'label', with: 'Test Label'
        click_on 'Submit'
      end

      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FORM Test\''
    end

    # Depends on previous test
    it "create Form, clear fields, field validation" do
      click_navbar_forms
      wait_for_ajax 20
      expect(page).to have_content 'Index: Forms'
      click_on 'New Form'

      ui_in_modal do
        click_on 'Submit'

        # Empty fields validation
        expect(page).to have_content('Field cannot be empty', count: 2)
        expect(page).to have_selector('.form-group.has-error', count: 2)

        fill_in 'identifier', with: 'FORM Test'

        click_on 'Submit'

        expect(page).to have_content('Field cannot be empty', count: 1)
        expect(page).to have_selector('.form-group.has-error', count: 1)

        click_on 'Clear fields'

        expect(find_field('identifier').value).to eq('')
        expect(find_field('label').value).to eq('')

        # Special characters validation
        fill_in 'identifier', with: 'FØRM Test'
        fill_in 'label', with: 'Test Label 2'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content('contains invalid characters', count: 1)

        # Duplicate identifier validation
        fill_in 'identifier', with: 'FORM Test'
        fill_in 'label', with: 'Test Label 2'

        click_on 'Submit'
        wait_for_ajax 10

        expect(page).to have_content 'already exists in the database'
        click_on 'Close'
      end

    end

    it "allows to delete a Form" do
      ui_create_form('FORM DELETE', 'Test Form')

      form_count = Form.all.count

      context_menu_element_v2('history', 'Incomplete', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( Form.all.count ).to eq form_count-1
    end

    it "allows to delete a Form with children nodes" do
      click_navbar_forms
      wait_for_ajax 10

      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height (Pilot)')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'FN000150\''

      form_count = Form.all.count

      context_menu_element_v2('history', 'Incomplete', :delete)
      ui_confirmation_dialog true
      wait_for_ajax 10

      expect(page).to have_content "No versions found"
      expect( Form.all.count ).to eq form_count-1
    end

  end

  describe "Forms, Document Control", :type => :feature, js:true do

    before :all do
      load_files(schema_files, [])
      load_cdisc_term_versions(1..65)
      load_data_file_into_triple_store("mdr_identification.ttl")
      load_test_file_into_triple_store("forms/FN000150.ttl")
      load_test_file_into_triple_store("forms/FN000120.ttl")
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

    it "allows to update a Form status, version and version label" do
      click_navbar_forms
      wait_for_ajax 20

      ui_table_search('index', 'Disability Assessment For Dementia')
      find(:xpath, "//tr[contains(.,'DAD')]/td/a", :text => 'History').click
      wait_for_ajax 10

      context_menu_element_v2('history', '0.1.0', :document_control)
      wait_for_ajax 10

      dc_check_status('Incomplete')
      dc_check_version('0.1.0')

      dc_forward_to('Candidate')
      dc_check_status('Candidate')

      dc_update_version('1.0.0')
      dc_update_version_label('Form Version Label')

      dc_forward_to('Standard')
      click_on 'Return'
      wait_for_ajax 10

      expect(page).to have_content '1.0.0'
      expect(page).to have_content 'Standard'
      expect(page).to have_content 'Form Version Label'
    end

    it "allows multiple edits enable and disable on a Form in locked state" do
      click_navbar_forms
      wait_for_ajax 20

      ui_table_search('index', 'Height')
      find(:xpath, "//tr[contains(.,'Height')]/td/a", :text => 'History').click
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
      ui_check_table_info('show', 1, 5, 5)

    end

    it "allows to create a new version off Standard" do
      ui_create_form('TST FORM 2', 'Test Form Label')

      # Creates a new version off of Standard
      context_menu_element_v2('history', '0.1.0', :document_control)

      dc_forward_to('Recorded')
      dc_update_version('1.0.0')
      dc_forward_to('Standard')

      click_on 'Return'
      wait_for_ajax 10

      context_menu_element_v2('history', '1.0.0', :edit)
      wait_for_ajax 10
      click_on 'Return'
      wait_for_ajax 10

      ui_check_table_info('history', 1, 2, 2)
      ui_check_table_cell('history', 1, 7, 'Incomplete')
      ui_check_table_cell('history', 1, 1, '1.1.0')
    end

  end

    # it "history allows the view page to be viewed (REQ-MDR-CRF-010)", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: DM1 01'
    #   find(:xpath, "//tr[contains(.,'Demographics')]/td/a", :text => 'View').click
    #   #save_and_open_page
    #   expect(page).to have_content 'View: Demographics DM1 01 (V0.0.0, 1, Candidate)'
    #   click_link 'Close'
    #   expect(page).to have_content 'History: DM1 01'
    # end

    # it "allows a form to be cloned", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: T2'
    #   find(:xpath, "//tr[contains(.,'Test 2')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   click_link 'Clone'
    #   expect(page).to have_content 'Cloning: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   fill_in 'form[identifier]', with: 'A CLONE FORM'
    #   fill_in 'form[label]', with: 'Test Clone Form'
    #   click_button 'Clone'
    #   expect(page).to have_content 'Index: Forms'
    #   expect(page).to have_content 'Test Clone Form'
    # end

    # it "prevents a duplicate form being cloned.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: T2'
    #   find(:xpath, "//tr[contains(.,'Test 2')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   click_link 'Clone'
    #   expect(page).to have_content 'Cloning: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   fill_in 'form[identifier]', with: 'A CLONE FORM'
    #   fill_in 'form[label]', with: 'Test 2nd Clone Form'
    #   click_button 'Clone'
    #   expect(page).to have_content 'Cloning: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   expect(page).to have_content 'The item cannot be created. The identifier is already in use.'
    # end

    # it "prevents a form to be cloned, identifier error.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: T2'
    #   find(:xpath, "//tr[contains(.,'Test 2')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   click_link 'Clone'
    #   expect(page).to have_content 'Cloning: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   fill_in 'form[identifier]', with: 'A CLONE FORM@'
    #   fill_in 'form[label]', with: 'Test 2nd Clone Form'
    #   click_button 'Clone'
    #   expect(page).to have_content 'Cloning: Test 2 T2 (V0.0.0, 1, Incomplete)'
    #   expect(page).to have_content 'Identifier contains invalid characters'
    # end

    # it "allows a placeholder form to be created", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   click_link 'New Placeholder'
    #   expect(page).to have_content 'New Placeholder Form:'
    #   fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM'
    #   fill_in 'form[label]', with: 'Test Placeholder Form'
    #   fill_in 'form[freeText]', with: 'This is **some** mardown with a little mardown in *it*'
    #   click_button 'Create'
    #   expect(page).to have_content 'Index: Forms'
    #   expect(page).to have_content 'Test Placeholder Form'
    # end

    # it "prevents a placeholder duplicate form being created.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   click_link 'New Placeholder'
    #   expect(page).to have_content 'New Placeholder Form:'
    #   fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM'
    #   fill_in 'form[label]', with: 'Test Placeholder Form'
    #   click_button 'Create'
    #   expect(page).to have_content 'New Placeholder Form:'
    #   expect(page).to have_content 'The item cannot be created. The identifier is already in use.'
    # end

    # it "prevents a placeholder form to be created, identifier error.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   click_link 'New Placeholder'
    #   expect(page).to have_content 'New Placeholder Form:'
    #   fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM&'
    #   fill_in 'form[label]', with: 'Test Placeholder Form'
    #   click_button 'Create'
    #   expect(page).to have_content 'New Placeholder Form:'
    #   expect(page).to have_content 'Identifier contains invalid characters'
    # end

    # it "allows a form to be branched", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: DM1 BRANCH'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   click_link 'Branch'
    #   expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   fill_in 'form[identifier]', with: 'A BRANCH FORM'
    #   fill_in 'form[label]', with: 'Test Branch Form'
    #   click_button 'Branch'
    #   expect(page).to have_content 'Index: Forms'
    #   expect(page).to have_content 'Test Branch Form'
    # end

    # it "prevents a duplicate form being branched.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: DM1 BRANCH'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   click_link 'Branch'
    #   expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   fill_in 'form[identifier]', with: 'A BRANCH FORM'
    #   fill_in 'form[label]', with: 'Test 2nd Branch Form'
    #   click_button 'Branch'
    #   expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   expect(page).to have_content 'The item cannot be created. The identifier is already in use.'
    # end

    # it "prevents a form to be branched, identifier error.", js:true do
    #   click_navbar_forms
    #   expect(page).to have_content 'Index: Forms'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'History').click
    #   expect(page).to have_content 'History: DM1 BRANCH'
    #   find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'Show').click
    #   expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   click_link 'Branch'
    #   expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   fill_in 'form[identifier]', with: 'A BRANCH FORM@'
    #   fill_in 'form[label]', with: 'Test 2nd Branch Form'
    #   click_button 'Branch'
    #   expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (V0.0.0, 1, Standard)'
    #   expect(page).to have_content 'Identifier contains invalid characters'
    # end

end
