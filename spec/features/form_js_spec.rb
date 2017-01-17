require 'rails_helper'

describe "Forms", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper

  def sub_dir
    return "features"
  end

  describe "Forms", :type => :feature do
  
    before :all do
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_dm1_branch.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a placeholder form to be created", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New Placeholder'
      expect(page).to have_content 'New Placeholder Form:'
      fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM'
      fill_in 'form[label]', with: 'Test Placeholder Form'
      fill_in 'form[freeText]', with: 'This is **some** mardown with a little mardown in *it*'
      click_button 'markdown_preview'
      #pause
      ui_check_div_text('generic_markdown', 'This is some mardown with a little mardown in it') # Need Javascript for this
      click_button 'Create'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test Placeholder Form'
    end

    it "allows a CRF and aCRF to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'CRF'
      #pause
      expect(page).to have_content 'CRF: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      click_link 'aCRF'
      #pause
      expect(page).to have_content 'CRF: Demographics DM1 01 (, V1, Candidate)'
    end

    it "allows a form show page to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Demographics DM1 01 (, V1, Candidate)'
      #show_body = page.body
      click_link 'Close'
      #write_text_file_2(show_body, sub_dir, "form_show.txt")
      #expected = read_text_file_2(sub_dir, "form_show.txt")
      #expect(show_body).to eq(expected)
    end

    it "allows a form show page to be viewed, show table details", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Demographics DM1 01 (, V1, Candidate)'
      wait_for_ajax
      ui_check_table_row('main', 1, ["1", "Question Group", "", "", "", "", "", "", ""])
      ui_check_table_row('main', 4, ["4", "Sex", "Sex:", "string", "", "SEX", "M [C20197] F [C16576]", "Indicate the appropriate sex.", ""])
      ui_check_table_row('main', 6, ["6", "Race Other", "Race Other Mixed Specify:", "string", "20", "SUPPDM.QVAL when QNAM=RACEOTH", "", "", ""])
      ui_check_table_row('main', 8, ["8", "Ethnic Subgroup", "Ethnic Subgroup:", "string", "", "SUPPDM.QVAL when QNAM=RACESG", "ETHNIC SUBGROUP [1] [A00011]", "Tick the appropriate box to indicate the subject s ethnic subgroup. If the appropriate subgroup is not listed, tick Other", ""])
      #ui_check_table_row_class('main', 2, 'warning')
      #ui_check_table_row_class('main', 7, 'warning')
      #ui_check_table_row_class('main', 8, 'warning')
    end

    it "allows a form show page to be viewed, show table details, VS BC", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS BASELINE'
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Vital Signs Baseline VS BASELINE (, V1, Standard)'
      wait_for_ajax
      ui_check_table_row('main', 1, ["1", "Group", "", "", "", "", "", "", ""])
      ui_check_table_row('main', 6, ["6", "Date and Time (--DTC)", "Question text", "dateTime", "", "", "", "", ""])
      ui_check_table_row('main', 12, ["12", "Result Units (--ORRESU)", "Result units?", "string", "", "", "oz [C48519]<br/>g [C48155]]<br/>LB [C48531]]<br/>kg [C28252]", "", ""])
    end

    it "allows a form show page to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
    end

    it "allows a form show page to be viewed, view tree details, DM", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      wait_for_ajax
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      expect(page).to have_content 'Form'
      ui_check_anon_table_row(1, ["Identifier:", "DM1 01"])
      ui_check_anon_table_row(2, ["Label:", "Demographics"])
      ui_check_anon_table_row(3, ["Completion Instructions:", ""])
      key = ui_get_key_by_path('["Demographics", "Question Group"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Group'
      ui_check_anon_table_row(1, ["Label:", "Question Group"])
      ui_check_anon_table_row(2, ["Repeating:", "false"])
      ui_check_anon_table_row(3, ["Optional:", "false"])
      key = ui_get_key_by_path('["Demographics", "Question Group", "Race"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Question'
      ui_check_anon_table_row(1, ["Label:", "Race"])
      ui_check_anon_table_row(2, ["Optional:", "false"])
      ui_check_anon_table_row(3, ["Question Text:", "Race:"])
      ui_check_anon_table_row(4, ["Mapping:", "RACE"])
      ui_check_anon_table_row(5, ["Datatype:", "string"])
      ui_check_anon_table_row(6, ["Format:", ""])
      key = ui_get_key_by_path('["Demographics", "Question Group", "Race", "Asian"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Code List'
      ui_check_anon_table_row(1, ["Identifier:", "C41260"])
      ui_check_anon_table_row(2, ["Label:", "Asian"])
      ui_check_anon_table_row(3, ["Default Label:", ""])
      ui_check_anon_table_row(4, ["Submission Value:", "ASIAN"])
      ui_check_anon_table_row(5, ["Enabled:", "true"])
      ui_check_anon_table_row(6, ["Optional:", "false"])
      key = ui_get_key_by_path('["Demographics", "Question Group", "CRF Number"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Question'
      ui_check_anon_table_row(1, ["Label:", "CRF Number"])
      ui_check_anon_table_row(4, ["Mapping:", "[NOT SUBMITTED]"])      
      ui_check_anon_table_row(5, ["Datatype:", "integer"])
      key = ui_get_key_by_path('["Demographics"]')      
      ui_click_node_key(key)
      ui_check_anon_table_row(1, ["Identifier:", "DM1 01"])
      ui_check_anon_table_row(2, ["Label:", "Demographics"])
      ui_check_anon_table_row(3, ["Completion Instructions:", ""])     
    end

    it "allows a form show page to be viewed, view tree details, VS BC", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: VS BASELINE'
      find(:xpath, "//tr[contains(.,'VS BASELINE')]/td/a", :text => 'View').click
      wait_for_ajax
      expect(page).to have_content 'View: Vital Signs Baseline VS BASELINE (, V1, Standard)'
      expect(page).to have_content 'Form'
      ui_check_anon_table_row(1, ["Identifier:", "VS BASELINE"])
      ui_check_anon_table_row(2, ["Label:", "Vital Signs Baseline"])
      ui_check_anon_table_row(3, ["Completion Instructions:", ""])
      key = ui_get_key_by_path('["Vital Signs Baseline", "Group"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Group'
      ui_check_anon_table_row(1, ["Label:", "Group"])
      ui_check_anon_table_row(2, ["Repeating:", "false"])
      ui_check_anon_table_row(3, ["Optional:", "false"])
      key = ui_get_key_by_path('["Vital Signs Baseline", "Group", "Height (BC_C25347)"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Group'
      ui_check_anon_table_row(1, ["Label:", "Height (BC_C25347)"])
      ui_check_anon_table_row(2, ["Repeating:", "false"])
      ui_check_anon_table_row(3, ["Optional:", "false"])
      ui_check_anon_table_row(4, ["Completion Instructions:", ""])
      ui_check_anon_table_row(5, ["Notes:", ""])
      key = ui_get_key_by_path('["Vital Signs Baseline", "Group", "Height (BC_C25347)", "Result Units (--ORRESU)"]') 
      #pause     
      ui_click_node_key(key)
      expect(page).to have_content 'Biomedical Concept Item'
      ui_check_anon_table_row(1, ["Label:", "Result Units (--ORRESU)"])
      ui_check_anon_table_row(2, ["Enabled:", "true"])
      ui_check_anon_table_row(3, ["Optional:", "false"])
      ui_check_anon_table_row(4, ["Question Text:", "Result units?"])
      ui_check_anon_table_row(5, ["Datatype:", ""])
      ui_check_anon_table_row(6, ["Format:", ""])
      ui_check_anon_table_row(7, ["Completion Instructions:", ""])
      ui_check_anon_table_row(8, ["Notes:", ""])
      key = ui_get_key_by_path('["Vital Signs Baseline", "Group", "Height (BC_C25347)", "Result Units (--ORRESU)", "Meter"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Code List'
      ui_check_anon_table_row(1, ["Identifier:", "C41139"])
      ui_check_anon_table_row(2, ["Label:", "Meter"])
      ui_check_anon_table_row(3, ["Default Label:", "Meter"])
      ui_check_anon_table_row(4, ["Submission Value:", "m"])      
      ui_check_anon_table_row(5, ["Enabled:", "true"])
      ui_check_anon_table_row(6, ["Optional:", "false"])
      key = ui_get_key_by_path('["Vital Signs Baseline"]')      
      ui_click_node_key(key)
      ui_check_anon_table_row(1, ["Identifier:", "VS BASELINE"])
      ui_check_anon_table_row(2, ["Label:", "Vital Signs Baseline"])
      ui_check_anon_table_row(3, ["Completion Instructions:", ""])
      key = ui_get_key_by_path('["Vital Signs Baseline", "Group", "Height (BC_C25347)"]')      
      ui_click_node_key(key)
      expect(page).to have_content 'Group'
      ui_check_anon_table_row(1, ["Label:", "Height (BC_C25347)"])
      ui_check_anon_table_row(2, ["Repeating:", "false"])
      ui_check_anon_table_row(3, ["Optional:", "false"])
      ui_check_anon_table_row(4, ["Completion Instructions:", ""])
      ui_check_anon_table_row(5, ["Notes:", ""])  
    end

    it "allows a form to be deleted", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: T2'
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'Delete').click
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'History: T2'
      find(:xpath, "//tr[contains(.,'T2')]/td/a", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Index: Forms'
    end

    it "allows a placeholder form to be created, field validation", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New Placeholder'
      expect(page).to have_content 'New Placeholder Form:'
      fill_in 'form[identifier]', with: '@@@'
      fill_in 'form[label]', with: '€€€'
      fill_in 'form[freeText]', with: '±±±'
      click_button 'Create'
      expect(page).to have_content "Please enter a valid identifier. Upper and lower case alphanumeric and space characters only."
      expect(page).to have_content "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
      expect(page).to have_content "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&|<> special characters and return only."
      fill_in 'form[identifier]', with: 'BETTER'
      click_button 'Create'
      expect(page).to have_content "Please enter a valid label. Upper and lower case case alphanumerics, space and .!?,'\"_-/\\()[]~#*=:;&|<> special characters only."
      expect(page).to have_content "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&|<> special characters and return only."
      fill_in 'form[label]', with: 'Nice Label'
      click_button 'Create'
      expect(page).to have_content "Please enter valid markdown. Upper and lowercase alphanumeric, space, .!?,'\"_-/\\()[]~#*=:;&|<> special characters and return only."
      fill_in 'form[freeText]', with: '**Brilliant**'
      click_button 'Create'
      expect(page).to have_content "Form was successfully created."
      expect(page).to have_content "BETTER"
      expect(page).to have_content "Nice Label"
    end
    
    it "allows a form to be created, field validation", js: true do
      visit '/forms/new'
      expect(page).to have_content 'New Form:'
      fill_in 'form[identifier]', with: '@@@'
      fill_in 'form[label]', with: '€€€'
      click_button 'Create'
      expect(page).to have_content "Label contains invalid characters and Scoped Identifier error: Identifier contains invalid characters"
      fill_in 'form[identifier]', with: 'BETTER2'
      fill_in 'form[label]', with: '€€€'
      click_button 'Create'
      expect(page).to have_content "Label contains invalid characters"
      fill_in 'form[identifier]', with: 'BETTER2'
      fill_in 'form[label]', with: 'Nice Label'
      click_button 'Create'
      expect(page).to have_content "Form was successfully created."
      expect(page).to have_content "BETTER"
      expect(page).to have_content "Nice Label"
    end

    it "allows a form to be branched, presents a parent button", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 BRANCH'
      find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'Show').click
      #pause
      expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (, V1, Standard)'
      click_link 'Branch'
      #pause
      expect(page).to have_content 'Branch: DM1 For Branching DM1 BRANCH (, V1, Standard)'
      fill_in 'form[identifier]', with: 'A BRANCH FORM'
      fill_in 'form[label]', with: 'Test Branch Form'
      click_button 'Branch'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test Branch Form'
      #pause
      find(:xpath, "//tr[contains(.,'A BRANCH FORM')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: A BRANCH FORM'
      find(:xpath, "//tr[contains(.,'A BRANCH FORM')]/td/a", :text => 'Show').click
      wait_for_ajax
      expect(page).to have_link 'Branched From'
      click_link 'Branched From'
      expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (, V1, Standard)'
    end

    it "shows the forms that have been branched", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 BRANCH'
      find(:xpath, "//tr[contains(.,'DM1 BRANCH')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: DM1 For Branching DM1 BRANCH (, V1, Standard)'
      expect(page).to have_content 'A BRANCH FORM'
      find(:xpath, "//tr[contains(.,'A BRANCH FORM')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Test Branch Form A BRANCH FORM (, V1, Incomplete)'
    end
    
  end

end