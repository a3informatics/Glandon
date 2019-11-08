require 'rails_helper'

describe "SDTM Model Domains", :type => :feature do

  include DataHelpers
  include UiHelpers
  include UserAccountHelpers
  include PauseHelpers
  include WaitForAjaxHelper
  include ValidationHelpers
  include DownloadHelpers
  include SparqlHelpers

  def sub_dir
    return "features"
  end

  describe "SDTM Model Domains Features", :type => :feature do

    before :all do
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
      ua_curator_login
    end

    after :each do
      ua_logoff
    end

    it "allows for a Model Domain to be exported as JSON", js: true do
      clear_downloads
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      find(:xpath, "//tr[.//text()='SDTMMODEL FINDINGS']/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      click_link 'Export JSON'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_model_domain_export.json")
      expected = read_text_file_2(sub_dir, "sdtm_model_domain_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a Model Domain to be exported as TTL", js: true do
      clear_downloads
      click_navbar_sdtm_model
      expect(page).to have_content 'History: CDISC SDTM Model'
      find(:xpath, "//tr[contains(.,'1.4')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      find(:xpath, "//tr[contains(.,'SDTMMODEL EVENTS')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      click_link 'Export Turtle'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_model_domain_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_model_domain_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_model_domain_export.ttl")
      check_triples("sdtm_model_domain_export_results.ttl", "sdtm_model_domain_export.ttl")
      delete_data_file(sub_dir, "sdtm_model_domain_export_results.ttl")
    end

  end

end
