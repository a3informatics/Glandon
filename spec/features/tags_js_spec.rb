require 'rails_helper'

describe "Tags", :type => :feature do
  
  include PauseHelpers
  include DataHelpers
  include UiHelpers
  include TagHelper
  include WaitForAjaxHelper

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Basic.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Data.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("form_crf_test_ds.ttl")
    #load_test_file_into_triple_store("tag_test_data.ttl")
    @user = User.create :email => "content_admin@example.com", :password => "12345678" 
    @user.add_role :content_admin
  end

  after :all do
    user = User.where(:email => "content_admin@example.com").first
    user.destroy
  end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'content_admin@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully'  
    end

    after :each do
      click_link 'logoff_button'
    end

  describe "The Content Admin User can", :type => :feature do
  
    
    ###  Manage Tags (MDR-TAG-20, MDR-TAG-30, MDR-TAG-40, MDR-TAG-45, MDR-TAG-60, MDR-TAG-110)
    it "only creat tags when both label and description is provided", js: true do
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'
      wait_for_ajax
      ui_check_input("edit_label", 'Tags')  
      fill_in 'add_label', with: 'Tag1'
      click_button 'Add tag'
      expect(page).to have_content 'Description contains invalid characters or is empty'
      fill_in 'add_description', with: 'Test description no label'
      click_button 'Add tag'   
      wait_for_ajax
      ui_click_node_name ("")
      pause
      ui_check_input('edit_description', "Test description no label")
      #not implemented expect(page).to have_content 'Description contains invalid characters or is empty'
    end


    it "create tags (REQ-MDR-TAG-040)", js: true do
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'
      wait_for_ajax
      ui_check_input("edit_label", 'Tags')  
      fill_in 'add_label', with: 'Tag1'
      fill_in 'add_description', with: 'Tag 1 level 1'     
      click_button 'Add tag'
      wait_for_ajax
      expect(page).to have_content 'Tag1'      
    end


    it "create child tags organized in a hierarchical structure (REQ-MDR-TAG-020, REQ-MDR-TAG-040)", js: true do
      visit '/dashboard' 
      create_tag_first_level("Tag1", "Tag 1 level 1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'
      ui_click_node_name ("Tag1")
      fill_in 'add_label', with: 'Tag1_1'
      fill_in 'add_description', with: 'Tag 1 level 2'
      click_button 'Add tag'
      expect(page).to have_content 'Tag1_1'    
    end

    it "create child tags with identical labels in different entities of the hierarchy (REQ-MDR-TAG-040)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_first_level("Tag2", "Tag 2 level 1")
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2") 
      ui_click_node_name ("Tag2")
      fill_in 'add_label', with: 'Tag1_1'
      fill_in 'add_description', with: 'similar child tag'
      click_button 'Add tag'
      key1 = ui_get_key_by_path('["Tags", "Tag2", "Tag1_1"]')
      ui_click_node_key(key1)
      pause
      ui_check_input('edit_label', "Tag1_1")
      ui_check_input('edit_description', "similar child tag")
    end

    it "not create tags with identical labels (REQ-MDR-TAG-040)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags' 
      expect(page).to have_content 'Tag1' 
      pause
      fill_in 'add_label', with: 'Tag1'
      fill_in 'add_description', with: 'Tag is identical with already existing tag!'
      click_button 'Add tag'
      pause
      #not implemented expect(page).to have_content 'You cannot create identical tags at the same level..........'      
    end

    it "view all managed items instances for each tag when managing tags (REQ-MDR-TAG-030)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "TAG1-1-3")
      create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "TAG1-1-3")
      create_tag_term("TAGTERM", "Tag terminology")
      add_tags("Terminology", "TAGTERM", "TAG1-1-3")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      key1 = ui_get_key_by_path('["Tags", "TAG1", "TAG1-1", "TAG1-1-3"]')
      ui_click_node_key(key1)
      pause
      expect(page).to have_content 'TAGBC'
      expect(page).to have_content 'TAGFORM'
      expect(page).to have_content 'TAGTERM'
    end

    it "not delete tags with children (REQ-MDR-TAG-045)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      ui_check_input("edit_label", 'Tag1') 
      click_button 'Delete'
      expect(page).to have_content 'Cannot destroy tag as it has children tags'
    end
  
    it "deleted tags and child tags (REQ-MDR-TAG-045)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG4-1-1")
      ui_check_input('edit_label','TAG4-1-1')
      click_button 'Delete'
      wait_for_ajax
      pause
      expect(page).not_to have_content 'TAG4-1-1'
      expect(page).to have_content 'TAG4'
      ui_click_node_name ("TAG4-1")
      ui_check_input('edit_label','TAG4-1')
      click_button 'Delete'
      wait_for_ajax
      pause
      expect(page).not_to have_content 'TAG4-1'
      expect(page).to have_content 'TAG4'
      ui_click_node_name ("TAG4")
      ui_check_input('edit_label','TAG4')
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'TAG4'
      pause
    end

    #not implemented
    it "not delete tags used by managed items (REQ-MDR-TAG-060)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "TAG4-1-1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG4-1-1")
      ui_check_input('edit_label','TAG4-1-1')
      pause
      click_button 'Delete'
      wait_for_ajax
      expect(page).not_to have_content 'Tag cannot be deleted' 
    end

    it "update tag labels (REQ-MDR-TAG-110)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("TAG1")
      ui_check_input("edit_label", 'TAG1')  
      ui_check_input("edit_description", 'Tag number 1')
      fill_in 'edit_label', with: 'UPDTAG1'
      fill_in 'edit_description', with: 'Tag 1 updated'
      click_button 'Update'
      wait_for_ajax
      ui_click_node_name ("UPDTAG1")
      pause
      ui_check_input("edit_label", 'UPDTAG1')  
      ui_check_input("edit_description", 'Tag 1 updated')     
    end

     ### Add Tags to Content (MDR-TAG-15, MDR-TAG-50, MDR-TAG-70, MDR-TAG-100)
    
    it "add tags and child tags to forms (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      pause
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGFORM')
      pause
      #check child tag is added to TAGFORM
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGFORM')
      pause
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms' 
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Tags').click 
      # not implemented ui_check_table_cell("iso_managed_tag_table", 1, 2, "Tag1_1")
    end

     it "add tags and child tags to BCs (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGBC')
      pause
      #check child tag is added to TAGTERM
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGBC')
      pause
      click_link 'Biomedical Concepts'
      expect(page).to have_content 'Index: Biomedical Concepts' 
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Tags').click 
      #not implemented ui_check_table_cell("iso_managed_tag_table", 1, 2, "Tag1_1")
    end

     it "add tags and child tags to terminology (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_term("TAGTERM", "Tag terminology")
      add_tags("Terminology", "TAGTERM", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      ui_click_node_name ("Tag1")
      ui_check_table_cell('iso_managed_table',1,1,'TAGTERM')
      pause
      #check child tag is added to TAGTERM
      ui_click_node_name ("Tag1_1")
      #not implemented ui_check_table_cell('iso_managed_table',1,1,'TAGTERM')
      #check child tag is added to TAGTERM
      pause
      click_link 'Terminology'
      expect(page).to have_content 'Index: Terminology' 
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'Tags').click 
      #not implemented ui_check_table_cell("iso_managed_tag_table", 1, 2, "Tag1_1")
    end

     it "remove tags and child tags from forms (REQ-MDR-15)", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "Tag1")
      wait_for_ajax
      click_link 'Tags'
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGFORM")
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms' 
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Tags').click
      wait_for_ajax
      ui_table_row_click("iso_managed_tag_table", "Tag1")
      ui_click_tag_delete
      pause
      #ui_check_table_cell('iso_managed_tag_table',1,1,'') 
    end
 
     it "remove tags and child tags from BCs (REQ-MDR-15)", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "Tag1")
      wait_for_ajax
      click_link 'Tags'
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGBC")
      click_link 'Biomedical Concepts'
      expect(page).to have_content 'Index: Biomedical Concepts' 
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Tags').click
      wait_for_ajax
      ui_table_row_click("iso_managed_tag_table", "Tag1")
      ui_click_tag_delete
      pause
      #ui_check_table_cell('iso_managed_tag_table',1,1,'') 
    end

     it "remove tags and child tags from terminology (REQ-MDR-15)", js:true do
      create_tag_first_level("Tag1", "Tag 1 level 1")
      create_tag_term("TAGTERM", "Tag test term")
      add_tags("Terminology", "TAGTERM", "Tag1")
      wait_for_ajax
      click_link 'Tags'
      ui_click_node_name ("Tag1")
      ui_check_table_cell("iso_managed_table", 1, 1, "TAGTERM")
      click_link 'Terminology'
      expect(page).to have_content 'Index: Terminology' 
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'History').click
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'Tags').click
      wait_for_ajax
      ui_table_row_click("iso_managed_tag_table", "Tag1")
      ui_click_tag_delete
      pause
      #ui_check_table_cell('iso_managed_tag_table',1,1,'') 
    end

     it "view a list of managed items being tagged to a selected tag when adding tags to an item,  (REQ-MDR-TAG-100)", js:true 
     # create_tag_form("TAGFORM", "Tag test form" )
     # create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
     # create_tag_term("TAGTERM", "Tag test term")
     # load_test_file_into_triple_store ("tag_test_ds.ttl")
     #add_tags("Form", "TAGFORM", "TAG1-1-1")
     #add_tags("Biomedical Concept", "TAGBC", "TAG1-1-1")
     #add_tags("Terminology", "TAGTERM", "TAG1-1-1")
     #wait_for_ajax
     #click_link 'Forms'
     #expect(page).to have_content 'Index: Forms' 
     #find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
     #find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Tags').click 
     #ui_click_node_name "#{TAG1-1-1}"
     #ui_check_table_cell("iso_managed_table", 1, 1, "TAGBC")
     #ui_check_table_cell("iso_managed_table", 1, 2, "TAGFORM")
     #ui_check_table_cell("iso_managed_table", 1, 3, "TAGTERM")
    end
    
    it "view both managed items tagged to the parent tag and managed items tagged to child tags within the same entity when searching for the parent tag (REQ-MDR_TAG-80)"


    it "can performed a search from the Managed Taga(REQ-MDR-TAG-120)", js: true do
      load_test_file_into_triple_store("tag_test_data.ttl")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      pause
      fill_in 'Search', with: 'Tag1_3'
      expect(display_labet).to have_content 'Tag1_1_3'
      fill_in 'Search', with: 'Tag2_2'
      #add a path for the graph display
      expect(display_labet).to have_content 'Tag2_2'
      #add a path for the graph display
      fill_in 'Search', with: 'Tag3'
      expect(display_labet).to have_content 'Tag3'
      #add a path for the graph display
      fill_in 'Search', with: 'Tag4'
      expect(page).to have_content 'No Tags found'
    end

    it "can view tagged managed items when searching for a specific tag (REQ-MDR-TAG-120)", js: true 

  end

end
