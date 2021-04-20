require 'rails_helper'

describe "Studies", :type => :feature do

  include DataHelpers
  include DownloadHelpers
  include UserAccountHelpers
  include UiHelpers
  include WaitForAjaxHelper
  include ItemsPickerHelpers

  after :all do
    ua_destroy
  end

  before :each do
    ua_curator_login
  end

  after :each do
    ua_logoff
  end

  describe "Basic Operations, curator", :type => :feature, js:true do

    before :all do
      data_files = ["study_history.ttl"]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("mdr_transcelerate_identification.ttl")
      ua_create
    end

    it "allows access to index page" do
      click_navbar_studies
      wait_for_ajax 10
      expect(page).to have_content 'Index: Studies'
      find(:xpath, "//th[contains(.,'Identifier')]").click # Order
      ui_check_table_info("index", 1, 3, 3)
      ui_check_table_cell("index", 1, 2, "STUDY ONE")
      ui_check_table_cell("index", 1, 3, "Study One")
    end

    it "allows the history page to be viewed" do
      click_navbar_studies
      wait_for_ajax 10
      find(:xpath, "//tr[contains(.,'STUDY TWO')]/td/a", :text => 'History').click
      wait_for_ajax 10
      expect(page).to have_content 'Version History of \'STUDY TWO\''
      ui_check_table_cell("history", 1, 1, "0.1.0")
      ui_check_table_cell("history", 1, 5, "Study Two")
    end

    it "history allows the show page to be viewed" 

  end

  describe "Create, delete actions", :type => :feature, js:true do

    before :all do
      data_files = ["SDTM_Sponsor_Domain.ttl"]
      load_files(schema_files, data_files)
      ua_create
    end
      
    it "allows to create a new Study" 

    it "allows to create a new Study, field validation" 

    it "allows to delete a Study" 

  end 

end
