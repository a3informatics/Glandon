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

    it "create tags (REQ-MDR-TAG-040)" do
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Root")
      fill_in 'Add New Tag', with: 'Tag1'
      fill_in 'Description', with: 'Tag 1 level 1'
      #fill_in 'iso_concept_system_label', with: 'Tag1'
      #fill_in 'iso_concept_system_description', with: 'Tag 1 level 1'
      click_button 'Add'
      expect(page).to have_content 'Tag: Tag1'      
    end


    it "create child tags organized in a hierarchical structure (REQ-MDR-TAG-020, REQ-MDR-TAG-040)", js: true do
      visit '/dashboard' 
      create_tag("Root", "Tag1", "Tag 1 level 1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      fill_in 'Add New Tag', with: 'Tag1_1'
      fill_in 'Description', with: 'Tag 1 level 2'
      #fill_in 'iso_concept_system_label', with: 'Tag1_1'
      #fill_in 'iso_concept_system_description', with: 'Tag 1 level 2'
      click_button 'Add'
      expect(page).to have_content 'Tag: Tag1_1'    
    end

    it "create child tags with identical labels in different entities of the hierarchy (REQ-MDR-TAG-040)", js: true do
      visit '/dashboard'
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Root", "Tag2", "Tag 2 level 1")
      create_tag("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag2")
      fill_in 'Add New Tag', with: 'Tag1_1'
      fill_in 'Description', with: 'Tag 1.1 level 2'
      #fill_in 'iso_concept_system_label', with: 'Tag2_1'
      #fill_in 'iso_concept_system_description', with: 'Tag 2 level 2'
      click_button 'Add'
      expect(page).to have_content 'Description: Tag 1 level 1' #need a path identifier     
    end

    it "not create tags with identical labels (REQ-MDR-TAG-040)", js: true do
      visit '/dashboard'
      create_tag("root", "Tag1", "Tag 1 level 1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Root")
      fill_in 'Add New Tag', with: 'Tag1'
      fill_in 'Description', with: 'Tag 1 level 1'
      #fill_in 'iso_concept_system_label', with: 'Tag1'
      #fill_in 'iso_concept_system_description', with: 'Tag 1 level 1'
      click_button 'Add'
      expect(page).to have_content 'You cannot create identical tags at the same level..........'      
    end

    it "view all managed items instances for each tag when managing tags (REQ-MDR-TAG-030)"
    
    it "not delete tags with children (REQ-MDR-TAG-045)", js: true do
      visit '/dashboard'
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      expect(display_label).to have_content 'Tag1'
      click_button 'Delete'
      expect(page).to have_content 'The tag cannot be deleted..........'
    end

    it "delete child tags, rejected by user (REQ-MDR-TAG-045)", js: true do
      visit '/dashboard'
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1_1")
      expect(display_label).to have_content 'Tag1_1'
      click_button 'Delete'
      ui_click_cancel("Are you sure?")
      expect(page).to have_content 'Tag1_1'
    end

    it "deleted child tags, accepted by user (REQ-MDR-TAG-045)", js: true do
      visit '/dashboard'
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1_1")
      expect(display_label).to have_content 'Tag1_1'
      click_button 'Delete'
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Concept system node was successfully deleted.'    
    end

    it "deleted tags (REQ-MDR-TAG-045)", js: true do
      visit '/dashboard'
      create_tag("Root", "Tag1", "Tag 1.1 level 1")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      expect(display_label).to have_content 'Tag1'
      click_button 'Delete'
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'Concept system node was successfully deleted.'
    end

    it "not delete tags used by managed items (REQ-MDR-TAG-060)"

    it "update tag labels (REQ-MDR-TAG-110)", js: true do
      visit 'dashboard'  
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Tag1", "Tag1_1", "Tag 1.1 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
      ui_click_node_name ("Tag1")
      expect(display_label).to have_content 'Tag1'
      expect(display_description).to have_content 'Tag 1.1 level 1'
      fill_in 'Tag', with: 'Tag2'
      fill_in 'Label', with: 'Tag 2.1 level 1'
      #fill_in 'iso_concept_system_label', with: 'Tag2_1'
      #fill_in 'iso_concept_system_description', with: 'Tag 2 level 2'
      click_button 'Add'
      expect(page).to have_content 'Tag: Tag2'     
    end

    

     ### Add Tags to Content (MDR-TAG-15, MDR-TAG-50, MDR-TAG-70, MDR-TAG-100)
    

    it "add tags and child tags to forms (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_classification #DS, must be removed when updated
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag_form("TAGFORM", "Tag test form" )
      add_tags("Forms", "TAGFORM", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      pause
      #check child tag is added to TAGFORM
      click_link 'Forms'
      expect(page).to have_content 'Index: Forms' 
      pause
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'History').click
      pause
      find(:xpath, "//tr[contains(.,'TAGFORM')]/td/a", :text => 'Tags').click 
      pause
      #ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1_1")
    end

     it "add tags and child tags to BCs (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_classification #DS, must be removed when updated
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag_bc("TAGBC", "Tag test BC", "Obs PQR")
      add_tags("Biomedical Concepts", "TAGBC", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      pause
      #check child tag is added to TAGBC
      click_link 'Biomedical Concepts'
      expect(page).to have_content 'Index: Biomedical Concepts' 
      pause
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
      pause
      find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Tags').click 
      pause
      #ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1_1")
    end

     it "add tags and child tags to terminology (REQ-MDR-15, REQ-MDR-TAG-050)", js: true do
      visit '/dashboard'
      create_classification #DS, must be removed when updated
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag_term("TAGTERM", "Tag terminology")
      add_tags("Terminology", "TAGTERM", "Tag1")
      wait_for_ajax
      ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1")
      #create child tag
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      pause
      #check child tag is added to TAGTERM
      click_link 'Terminology'
      expect(page).to have_content 'Index: Terminology' 
      pause
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'History').click
      pause
      find(:xpath, "//tr[contains(.,'TAGTERM')]/td/a", :text => 'Tags').click 
      pause
      #ui_check_table_cell("iso_managed_tag_table", 1, 1, "Tag1_1")
    end

     it "remove tags and child tags from forms (REQ-MDR-15)", js:true 
     

     it "remove tags and child tags from BCs (REQ-MDR-15)", js:true 

     it "remove tags and child tags from terminology (REQ-MDR-15)", js:true 

     it "view a list of managed items being tagged to a selected tag when adding tags to an item,  (REQ-MDR-TAG-100)", js:true 
     # load_test_file_into_triple_store("form_crf_test_ds.ttl")
     # load_test_file_into_triple_store("bc_test_ds.ttl")
     # load_test_file_into_triple_store("terminology_test_ds.ttl")
     # load_test_file_into_triple_store ("tag_test_ds.ttl")
     add_tags("Form", "TAGFORM", "Tag1")
     add_tags("Biomedical Concept", "TAGBC", "Tag1")
     add_tags("Terminology", "TAGTERM", "Tag1")
     wait_for_ajax
     click_link 'Forms'
     expect(page).to have_content 'Index: Forms' 
     find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'History').click
     find(:xpath, "//tr[contains(.,'TAGBC')]/td/a", :text => 'Tags').click 
     ui_click_node_name "#{Tag1}"
     ui_check_table_cell("name", 1, 1, "Tag1_1")
    ####  Search Tags (MDR-TAG-80, MDR-TAG-120) 
    
    it "view both managed items tagged to the parent tag and managed items tagged to child tags within the same entity when searching for the parent tag (REQ-MDR_TAG-80)"


    it "can performed a search (REQ-MDR-TAG-120)", js: true do
      visit '/dashboard'
      create_classification #DS, must be removed when updated
      create_tag("Root", "Tag1", "Tag 1 level 1")
      create_tag("Root", "Tag2", "Tag 2 level 1")
      create_tag("Root", "Tag3", "Tag 3 level 1")
      create_tag_child("Tag1", "Tag1_1", "Tag 1.1 level 2")
      create_tag_child("Tag1", "Tag1_2", "Tag 1.2 level 2")
      create_tag_child("Tag1", "Tag1_3", "Tag 1.3 level 2")
      create_tag("Tag1_1", "Tag1_1_1", "Tag 1.1.1 level 3")
      create_tag("Tag1_1", "Tag1_1_2", "Tag 1.1.2 level 3")
      create_tag("Tag1_1", "Tag1_1_3", "Tag 1.1.3 level 3")
      create_tag_child("Tag2", "Tag2_1", "Tag 2.1 level 2")
      create_tag_child("Tag2", "Tag2_2", "Tag 2.2 level 2")
      click_link 'Tags'
      expect(page).to have_content 'Manage Tags'  
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

    ### misc

    it "pre-set one or more tags as defaults in user settings (REQ-MDR-TAG-90)", js: true

  end

end
