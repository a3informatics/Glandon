require 'rails_helper'

describe "SDTM IG Domains", :type => :feature do

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

  describe "SDTM IG Domains Features", :type => :feature do

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

    it "allows for a IG Domain to be exported as JSON", js: true do
      clear_downloads
      click_navbar_ig_domain
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
      find(:xpath, "//tr[contains(.,'3.2')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      find(:xpath, "//tr[contains(.,'SDTM IG AE')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export JSON'
      file = download_content
    #Xwrite_yaml_file(file, sub_dir, "sdtm_ig_domain_export.json")
      expected = read_yaml_file(sub_dir, "sdtm_ig_domain_export.json")
      expect(file).to eq(expected)
    end

    it "allows for a IG Domain to be exported as TTL", js: true do
      clear_downloads
      click_navbar_ig_domain
      expect(page).to have_content 'History: CDISC SDTM Implementation Guide'
      find(:xpath, "//tr[contains(.,'3.2')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      find(:xpath, "//tr[contains(.,'SDTM IG AE')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: '
      wait_for_ajax
      click_link 'Export Turtle'
      file = download_content
    #Xwrite_text_file_2(file, sub_dir, "sdtm_ig_domain_export.ttl")
      write_text_file_2(file, sub_dir, "sdtm_ig_domain_export_results.ttl")
      expected = read_text_file_2(sub_dir, "sdtm_ig_domain_export.ttl")
      check_triples("sdtm_ig_domain_export_results.ttl", "sdtm_ig_domain_export.ttl")
      delete_data_file(sub_dir, "sdtm_ig_domain_export_results.ttl")
    end

  end

end
