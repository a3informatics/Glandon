require 'rails_helper'

describe "SDTM Models", :type => :feature do

  include DataHelpers
  include UiHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include ValidationHelpers
  include DownloadHelpers
  include SparqlHelpers
  include UserAccountHelpers

  def sub_dir
    return "features"
  end

  describe "SDTM Model Features, Curator", :type => :feature do

    before :all do
      Token.destroy_all
      Token.set_timeout(5)
      schema_files = ["ISO11179Types.ttl","ISO11179Identification.ttl", "ISO11179Registration.ttl","ISO11179Concepts.ttl", "thesaurus.ttl",
        "CDISCBiomedicalConcept.ttl", "BusinessOperational.ttl", "BusinessForm.ttl"]
      data_files = ["iso_registration_authority_real.ttl", "iso_namespace_real.ttl", "CT_ACME_V1.ttl", "BCT.ttl", "BC.ttl", "sdtm_model_and_ig.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
      ua_create
    end

    after :all do
      ua_destroy
      Token.restore_timeout
    end

    before :each do
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows for a Model to be exported as JSON", js: true do
      clear_downloads
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export JSON'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_model_export.json")
      expected = read_text_file_2(sub_dir, "sdtm_model_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a Model to be exported as TTL", js: true do
      clear_downloads
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export Turtle'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_model_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_model_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_model_export.ttl")
      check_triples("sdtm_model_export_results.ttl", "sdtm_model_export.ttl")
      delete_data_file(sub_dir, "sdtm_model_export_results.ttl")
    end

  end

  describe "SDTM IGs Features, Content Admin", :type => :feature do

    before :all do
      Background.destroy_all
      Token.destroy_all
      Token.set_timeout(5)
      schema_files = ["ISO11179Types.ttl","ISO11179Identification.ttl", "ISO11179Registration.ttl","ISO11179Concepts.ttl", "thesaurus.ttl",
        "CDISCBiomedicalConcept.ttl", "BusinessOperational.ttl", "BusinessForm.ttl", "BusinessDomain.ttl"]
      data_files = ["iso_registration_authority_real.ttl", "iso_namespace_real.ttl", "CT_ACME_V1.ttl", "BCT.ttl", "BC.ttl", "sdtm_model_and_ig.ttl"]
      load_files(schema_files, data_files)
      load_cdisc_term_versions(1..43)
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
      click_navbar_sdtm_model
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
