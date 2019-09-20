require 'rails_helper'

describe "Tags", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include TagHelper
  include WaitForAjaxHelper

  before :all do
    @user = User.create :email => "content_admin@example.com", :password => "12345678" 
    @user.add_role :content_admin
  end

  before :each do

    schema_files = 
    [
      "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"
    ]
    data_files = 
    [
      "iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BCT.ttl"
    ]
    load_files(schema_files, data_files)

    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object

    visit '/users/sign_in'
    fill_in 'Email', with: 'content_admin@example.com'
    fill_in 'Password', with: '12345678'
    click_button 'Log in'
    expect(page).to have_content 'Signed in successfully'  
  end 

  after :each do
    #click_link 'logoff_button'
    #ui_visit('logoff_button')
  end 

  after :all do
    user = User.where(:email => "content_admin@example.com").first
    user.destroy
  end

    describe "The Content Admin User can", :type => :feature do

    ###  Manage Tags (MDR-TAG-20, MDR-TAG-30, MDR-TAG-40, MDR-TAG-45, MDR-TAG-60, MDR-TAG-110)
    it "only creat tags when both label and description is provided (REQ-MDR-TAG-040)", js: true do
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'
      ui_check_input("edit_label", 'Tags')  
      fill_in 'add_label', with: 'Tag1'
      click_button 'Add tag'
      ui_check_flash_message_present
      expect(page).to have_content 'Description contains invalid characters or is empty'
      fill_in 'add_description', with: 'Test description no label'
      click_button 'Add tag'   
      ui_check_flash_message_present
      expect(page).to have_content'Label is empty'
    end

    it "create tags (REQ-MDR-TAG-040)", js: true do
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'
      ui_check_input("edit_label", 'Tags')  
      fill_in 'add_label', with: 'Tag1'
      fill_in 'add_description', with: 'Tag 1 level 1'     
      click_button 'Add tag'
      expect(page).to have_content 'Tag1'      
    end

    it "create child tags organized in a hierarchical structure (REQ-MDR-TAG-020, REQ-MDR-TAG-040)", js: true do 
      create_tag_first_level("Tag1", "Tag 1 level 1")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'
      ui_click_node_name ("Tag1")
      fill_in 'add_label', with: 'Tag1_1'
      fill_in 'add_description', with: 'Tag 1 level 2'
      click_button 'Add tag'
      wait_for_ajax(120)
      expect(page).to have_content 'Tag1_1'    
    end

    it "create child tags with identical labels in different entities of the hierarchy (REQ-MDR-TAG-040)", js: true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_first_level("Tag2", "Tag 2 level 1")
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2") 
      ui_click_node_name ("Tag2")
      fill_in 'add_label', with: 'Tag1_1'
      fill_in 'add_description', with: 'similar child tag'
      click_button 'Add tag'
      wait_for_ajax
      key1 = ui_get_key_by_path('["Tags", "Tag2", "Tag1_1"]')
      ui_click_node_key(key1)
      ui_check_input('edit_label', "Tag1_1")
      ui_check_input('edit_description', "similar child tag")
    end

    it "still create tags with identical labels (REQ-MDR-TAG-040)", js: true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags' 
      expect(page).to have_content 'Tag1' 
      fill_in 'add_label', with: 'Tag1'
      fill_in 'add_description', with: 'Tag is identical with already existing tag!'
      click_button 'Add tag'
      #not implemented expect(page).to have_content 'You cannot create identical tags at the same level..........'      
    end

    it "view all managed items instances for each tag when managing tags (REQ-MDR-TAG-030), currently not working", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      #currently not working
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "TAG1-1-3")
      create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "TAG1-1-3")
      create_tag_term("TAGTERM", "Tag terminology")
      add_tags("Terminology", "TAGTERM", "TAG1-1-3")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      key1 = ui_get_key_by_path('["Tags", "TAG1", "TAG1-1", "TAG1-1-3"]')
      ui_click_node_key(key1)
      expect(page).to have_content 'TAGBC'
      expect(page).to have_content 'TAGFORM'
      expect(page).to have_content 'TAGTERM'
    end

    it "not delete tags with children (REQ-MDR-TAG-045)", js: true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      ui_check_input("edit_label", 'Tag1') 
      click_button 'Delete'
      expect(page).to have_content 'Cannot destroy tag as it has children tags'
    end
  
    it "deleted tags and child tags (REQ-MDR-TAG-045)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG4-1-1")
      ui_check_input('edit_label','TAG4-1-1')
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'TAG4-1-1'
      expect(page).to have_content 'TAG4'
      ui_click_node_name ("TAG4-1")
      ui_check_input('edit_label','TAG4-1')
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'TAG4-1'
      expect(page).to have_content 'TAG4'
      ui_click_node_name ("TAG4")
      ui_check_input('edit_label','TAG4')
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'TAG4'
    end

    #not implemented
    it "still (not) delete tags used by managed items (REQ-MDR-TAG-060), currently not working", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      #currently not working
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "TAG4-1-1")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG4-1-1")
      ui_check_input('edit_label','TAG4-1-1')
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'TAG4-1-1' 
    end

    it "update tag labels (REQ-MDR-TAG-110)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG1")
      ui_check_input("edit_label", 'TAG1')  
      ui_check_input("edit_description", 'Tag number 1')
      fill_in 'edit_label', with: 'UPDTAG1'
      fill_in 'edit_description', with: 'Tag 1 updated'
      click_button 'Update'
      wait_for_ajax
      ui_click_node_name ("UPDTAG1")
      ui_check_input("edit_label", 'UPDTAG1')  
      ui_check_input("edit_description", 'Tag 1 updated')     
    end

     ### Add Tags to Content (MDR-TAG-15, MDR-TAG-50, MDR-TAG-70, MDR-TAG-100)
    
    it "add tags to forms auto add child tags when created (REQ-MDR-15, REQ-MDR-TAG-050), currently not working", js: true do
      #currently not working
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_form("TAGFORM", "Form for Tag Testing" )
      add_tags("Forms", "TAGFORM", "Tag1")
      wait_for_ajax
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGFORM')
      #1. check child tag is added to TAGFORM
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGFORM')
      #2. check child tag is added to TAGFORM
      click_navbar_forms
      expect(page).to have_content 'Index: Forms' 
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Update Tags').click 
      #not implemented find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1_1")
    end

     it "add tags to BCs auto add child tags when created (REQ-MDR-15, REQ-MDR-TAG-050), currently not working", js: true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      #currently not working
      create_tag_bc("TAGBC", "BC for Tag Testing", "Obs PQR")
#pause
      add_tags("Biomedical Concepts", "TAGBC", "Tag1")
      wait_for_ajax
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGBC')
      #1. check child tag is added to TAGBC
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGBC')
      #2. check child tag is added to TAGFORM
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts' 
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Update Tags').click 
      #not implemented find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1_1")
    end

     it "add tags to terminology auto add child tags when created (REQ-MDR-15, REQ-MDR-TAG-050). Currently not working", js: true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_term("TAGTERM", "Terminology for Tag Testing")
      add_tags_term("TAGTERM", "Tag1")

      wait_for_ajax(120)
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGTERM')
#pause
      #1. check child tag is added to TAGTERM
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGTERM')
      #2. check child tag is added to TAGTERM
      # click_navbar_dashboard
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology' 
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'History').click
#pause
      #find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'Update Tags').click 
#pause
      #not implemented find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1_1")
    end

     it "remove tags and child tags from forms (REQ-MDR-15). Currently not working", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_form("TAGFORM", "Form for Tag Testing" )
      add_tags("Forms", "TAGFORM", "Tag1")
      click_navbar_tags
      wait_for_ajax
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGFORM")
      click_navbar_forms
      expect(page).to have_content 'Index: Forms' 
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Update Tags').click
      wait_for_ajax
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1").click
      X = find(:xpath, "//div[@id='tags_container']", visible: false).text
      expect(X).to have_content "" 
    end
 
     it "remove tags and child tags from BCs (REQ-MDR-15). Currently not working", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_bc("TAGBC", "BC for Tag Testing", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "Tag1")
      click_navbar_tags
      wait_for_ajax
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGBC")
      main_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts' 
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Update Tags').click
      wait_for_ajax
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1").click
      X = find(:xpath, "//div[@id='tags_container']", visible: false).text
      expect(X).to have_content "" 
    end

     it "remove tags and child tags from terminology (REQ-MDR-15). Not working", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_term("TAGTERM", "Term for Tag Testing")
      add_tags("Terminology", "TAGTERM", "Tag1")
      click_navbar_tags
      wait_for_ajax
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGTERM")
      click_navbar_terminology
      expect(page).to have_content 'Index: Terminology' 
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'Update Tags').click
      wait_for_ajax
      find(:xpath, "//div[@id='tags_container']/span", :text => "Tag1").click
      X = find(:xpath, "//div[@id='tags_container']", visible: false).text
      expect(X).to have_content "" 
    end

     it "view a list of managed items being tagged to a selected tag when adding tags to a form,  (REQ-MDR-TAG-100) Not working: The value is not a string or an existing URI", js:true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      create_tag_form("TAGFORM", "Form for Tag Test" )
      create_tag_bc("TAGBC", "BC for Tag Test", "Obs PQR")
      create_tag_term("TAGTERM", "Term for Tag Test")
      add_tags("Form", "TAGFORM", "TAG1-1-1")
      add_tags("Biomedical Concepts", "TAGBC", "TAG1-1-1")
      add_tags("Biomedical Concepts", "TAGBC", "TAG2-1")
      add_tags("Terminology", "TAGTERM", "TAG1-1-1")
      click_navbar_terminology
      expect(page).to have_content 'Index: Forms' 
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Update Tags').click 
      wait_for_ajax
      ui_click_node_name ("TAG1-1-1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGBC")
      ui_check_table_cell("iso_managed_table", 2, 1, "TAGFORM")
      ui_check_table_cell("iso_managed_table", 3, 1, "TAGTERM")
      wait_for_ajax
      ui_click_node_name ("TAG2-1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGBC")
    end
    
    it "view both managed items tagged to the parent tag and managed items tagged to child tags within the same entity when searching for the parent tag (REQ-MDR_TAG-80)"


    it "can performed a search from the Managed Tags(REQ-MDR-TAG-120)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_navbar_tags
      expect(page).to have_content 'Manage Tags'  
      fill_in 'search for tag', with: 'TAG1-3'
      ui_hit_return("d3Search_input")
      wait_for_ajax
      result = ui_get_search_results
      expect(result.count).to eq(1)
      expect(result[0]).to eq("TAG1-3")
      fill_in 'd3Search_input', with: 'Tag2_2'
      ui_hit_return("d3Search_input")
      result = ui_get_search_results
      expect(result.count).to eq(0)
      fill_in 'd3Search_input', with: 'Tag3'
      ui_hit_return("d3Search_input")
      result = ui_get_search_results
      expect(result.count).to eq(4)
      ["TAG3", "TAG3-2", "TAG3-1", "TAG3-3"].each {|x| expect(result.include?(x)).to eq(true)}
      fill_in 'd3Search_input', with: 'Tag6'
      ui_hit_return("d3Search_input")
      result = ui_get_search_results
      expect(result.count).to eq(0)
    end
  
  end

end
