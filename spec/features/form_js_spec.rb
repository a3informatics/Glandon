require 'rails_helper'

describe "Forms", :type => :feature do
  
  include DataHelpers
  include UiHelpers
  include PauseHelpers

  def sub_dir
    return "features"
  end

  describe "Forms", :type => :feature do
  
    before :all do
      user = User.create :email => "reader@example.com", :password => "12345678" 
      user.add_role :curator
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("BusinessOperational.ttl")
      load_schema_file_into_triple_store("BusinessForm.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("CT_V42.ttl")
      load_test_file_into_triple_store("CT_V43.ttl")
      load_test_file_into_triple_store("CT_ACME_V1.ttl")
      load_test_file_into_triple_store("BCT.ttl")
      load_test_file_into_triple_store("BC.ttl")
      load_test_file_into_triple_store("form_example_dm1.ttl")
      load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
      load_test_file_into_triple_store("form_example_general.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      clear_cdisc_term_object
    end

    after :all do
      user = User.where(:email => "reader@example.com").first
      user.destroy
    end

    before :each do
      visit '/users/sign_in'
      fill_in 'Email', with: 'reader@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
    end

    it "allows a placeholder form to be created", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      click_link 'New Placeholder'
      expect(page).to have_content 'New Placeholder Form:'
      fill_in 'form[identifier]', with: 'A PLACEHOLDER FORM'
      fill_in 'form[label]', with: 'Test Placeholder Form'
      fill_in 'form[freeText]', with: 'This is **some** mardown with a little mardown in *it*'
      click_button 'markdown_preview'
      ui_check_div_text('generic_markdown', 'This is some mardown with a little mardown in it') # Need Javascript for this
      click_button 'Create'
      expect(page).to have_content 'Index: Forms'
      expect(page).to have_content 'Test Placeholder Form'
    end

    it "allows a CRF and aCRF to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'CRF'
      #pause
      expect(page).to have_content 'CRF: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      click_link 'aCRF'
      #pause
      expect(page).to have_content 'CRF: Demographics DM1 01 (, V1, Candidate)'
    end

    it "allows a form show page to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'Show').click
      expect(page).to have_content 'Show: Demographics DM1 01 (, V1, Candidate)'
      #show_body = page.body
      click_link 'Close'
      #write_text_file_2(show_body, sub_dir, "form_show.txt")
      #expected = read_text_file_2(sub_dir, "form_show.txt")
      #expect(show_body).to eq(expected)
    end

    it "allows a form show page to be viewed", js: true do
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'View').click
      expect(page).to have_content 'View: Demographics DM1 01 (, V1, Candidate)'
      click_link 'Close'
    end

    it "allows a form to be deleted"
    
  end

end