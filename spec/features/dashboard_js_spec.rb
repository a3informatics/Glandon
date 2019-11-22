require 'rails_helper'

describe "Dashboard JS", :type => :feature do

  include DataHelpers
  include PauseHelpers
  include UiHelpers
  include UserAccountHelpers
  include WaitForAjaxHelper


  def triples_search(search_text)
    input = find(:xpath, '//*[@id="triplesTable_filter"]/label/input')
    input.set("#{search_text}")
    input.native.send_keys(:return)
  end

  before :all do
    ua_create

    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessForm.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BC.ttl", "form_example_vs_baseline.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..42)
    clear_iso_concept_object
  end

  after :all do
    ua_destroy
  end

  before :each do
    ua_reader_login
  end

  after :each do
    ua_logoff
  end

  describe "Reader User", :type => :feature do

    it "allows the triples to be viewed (REQ-MDR-UD-NONE)", js: true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      ui_main_search("C16358")
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C16358'
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => /\AT\z/).click
      expect(page).to have_content 'Triple Store View'
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRBCs/V1'
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'
      triples_search("BC_C16358-1")
      find(:xpath, "//tr[contains(.,'mdrItems:SI-ACME_BC_C16358-1')]/td", :text => 'Show').click
      expect(page).to have_content 'Triple Store View'
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRItems'
      expect(find('#subjectId').value).to eq 'SI-ACME_BC_C16358-1'
      find(:xpath, "//table[@id='main']/tbody/tr/td", :text => /\A1\z/).click
      click_button 'View'
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'
      click_link 'Close'
      expect(current_path).to eq("/dashboard")
    end

    it "allows the graph to be viewed (REQ-MDR-UD-NONE)", js: true do
      click_navbar_bc
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: BC C16358'
      find(:xpath, "//tr[contains(.,'BC C16358')]/td/a", :text => /\AT\z/).click
      expect(page).to have_content 'Triple Store View'
      expect(page).to have_field('subjectNs', disabled: true)
      expect(page).to have_field('subjectId', disabled: true)
      expect(find('#subjectNs').value).to eq 'http://www.assero.co.uk/MDRBCs/V1'
      expect(find('#subjectId').value).to eq 'BC-ACME_BC_C16358'
      click_button 'Gr+'
      expect(page).to have_content 'Graph:'
    end

    it "allows the dashboard to be viewed, header (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Terminologies'
      expect(page).to have_content 'Today is'
      expect(page).to have_content 'You have'
    end

    it "allows the dashboard to be viewed, customize, select items (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Customize'
      click_link 'Customize'
      find(:xpath, "//*[@id='dashboard-list']/div[1]/label/input").click #Uncheck Terminologies item
      click_button 'Save'
      wait_for_ajax(120)
      expect(page).not_to have_content 'Terminologies'
    end

    it "allows the dashboard to be viewed, customize, drag & drop items (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      //*[@id="dashboard-editor"]/div[1] #Header
      //*[@id="dashboard-editor"]/div[2] #Terminologies
      //*[@id="dashboard-editor"]/div[3] #Statistics
      source = page.find('#foo')
      target = page.find('#bar')
      source.drag_to(target)
      
    end

    it "allows the dashboard to be viewed, panels (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      
    end

    it "allows the dashboard to be viewed, terminologies panel (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      
    end

    it "allows the dashboard to be viewed, statistics panel (REQ-MDR-UD-NONE)", js: true do
      click_navbar_dashboard
      
    end

    # it "allows the history to be accessed (REQ-MDR-UD-NONE)", js: true do
    #   find(:xpath, "//tr[contains(.,'APGAR Score (BC A00002)')]/td/a", :text => /\AHistory\z/).click
    #   expect(page).to have_content 'History: BC A00002'
    # end

    it "displays the organization name (REQ-MDR-UD-NONE)", js: true do
      expect(page).to have_content "#{APP_CONFIG['application_name']} (v#{Version::VERSION})"
    end

  end

end
