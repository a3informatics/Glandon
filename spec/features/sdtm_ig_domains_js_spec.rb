require 'rails_helper'

describe "SDTM IG Domains", :type => :feature do
  
  include DataHelpers
  include UiHelpers
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
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_schema_file_into_triple_store("BusinessDomain.ttl")
      load_test_file_into_triple_store("iso_registration_authority_real.ttl")
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
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
      Token.restore_timeout
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    after :each do
      click_link 'logoff_button'
    end

    it "allows for a IG Domain to be exported as JSON", js: true do
      clear_downloads
      visit '/sdtm_igs/history'
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
      visit '/sdtm_igs/history'
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