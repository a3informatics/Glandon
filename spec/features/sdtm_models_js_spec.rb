require 'rails_helper'

describe "SDTM Models", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include ValidationHelpers
  include DownloadHelpers
  include TurtleHelpers
  include UserAccountHelpers
  
  def sub_dir
    return "features"
  end

  describe "SDTM Model Features, Curator", :type => :feature do
  
    before :all do
      Token.destroy_all
      Token.set_timeout(5)
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
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_curator_login
    end

    after :each do
      click_link 'logoff_button'
    end

    it "allows for a Model to be exported as JSON", js: true do
      clear_downloads
      visit '/sdtm_models/history'
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export JSON'
      file = download_content 
    #write_text_file_2(file, sub_dir, "sdtm_model_export.json")
      expected = read_text_file_2(sub_dir, "sdtm_model_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a Model to be exported as TTL", js: true do
      clear_downloads
      visit '/sdtm_models/history'
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export Turtle'
      file = download_content
    #write_text_file_2(file, sub_dir, "sdtm_model_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_model_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_model_export.ttl")
      check_ttl("sdtm_model_export_results.ttl", "sdtm_model_export.ttl")
    end
    
  end

  describe "SDTM IGs Features, Content Admin", :type => :feature do
  
    before :all do
      Background.destroy_all
      Token.destroy_all
      Token.set_timeout(5)
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
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("sdtm_model_and_ig.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
      ua_create
    end

    after :all do
      ua_destroy
    end

    before :each do
      ua_content_admin_login
    end

    after :each do
      click_link 'logoff_button'
    end

    it "allows an IG to be imported", js: true do
      visit '/sdtm_models/history'
      expect(page).to have_content 'History: CDISC SDTM Model'
      click_link 'import_button'
      expect(page).to have_content 'Import CDISC SDTM Model Version'
      ui_check_input("sdtm_model_version", 4)
      fill_in 'sdtm_model_version_label', with: '4.0'
      fill_in 'sdtm_model_date', with: "24-10-2017"
      select 'sdtm-3-2-excel.xlsx', from: "sdtm_model_files_"
      click_button 'Create'
      expect(page).to have_content 'Background Jobs'
    #pause
    	ui_check_table_cell("main", 1, 1, "Import CDISC SDTM Model. Date: 2017-10-24, Internal Version: 4.")
    	ui_check_table_cell("main", 1, 2, "Complete. Successful import.")
    end

  end

end