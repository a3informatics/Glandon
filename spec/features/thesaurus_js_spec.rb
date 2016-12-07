require 'rails_helper'

describe "Thesaurus", :type => :feature do

  include PauseHelpers
  include DataHelpers
  include UiHelpers

  describe "Curator User", :type => :feature do

    before :all do
      clear_triple_store
      load_schema_file_into_triple_store("ISO11179Types.ttl")
      load_schema_file_into_triple_store("ISO11179Basic.ttl")
      load_schema_file_into_triple_store("ISO11179Identification.ttl")
      load_schema_file_into_triple_store("ISO11179Registration.ttl")
      load_schema_file_into_triple_store("ISO11179Data.ttl")
      load_schema_file_into_triple_store("ISO11179Concepts.ttl")
      load_schema_file_into_triple_store("ISO25964.ttl")
      load_test_file_into_triple_store("iso_namespace_real.ttl")
      load_test_file_into_triple_store("thesaurus_concept.ttl")
      clear_iso_concept_object
      clear_iso_namespace_object
      clear_iso_registration_authority_object
      clear_iso_registration_state_object
      user = User.create :email => "curator@example.com", :password => "12345678" 
      user.add_role :curator
      Token.set_timeout(60)
    end

    after :all do
      user = User.where(:email => "curator@example.com").first
      user.destroy
    end
  
    it "allows terminology to be edited", js: true do
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      find(:xpath, "//a[@href='/thesauri']").click # Clash with 'CDISC Terminology', so use this method to make unique
      expect(page).to have_content 'Index: Terminology'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: CDISC EXT'
      find(:xpath, "//tr[contains(.,'CDISC EXT')]/td/a", :text => 'Edit').click
      expect(page).to have_content 'Edit: CDISC Extensions CDISC EXT (0.1, V2, Incomplete)' # Note up version
      fill_in 'Identifier', with: 'A00030'
      click_button 'New'
      expect(page).to have_content 'A00030' # Note up version
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[3]").click
      fill_in "DTE_Field_notation", with: "SUBMISSION\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[4]").click
      fill_in "DTE_Field_preferredTerm", with: "The PT\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as A; B\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky!\n"
      find(:xpath, "//tr[contains(.,'Same as A; B')]/td/button", :text => 'Edit').click
      expect(page).to have_content 'Edit: Label text A00030'
      fill_in 'Identifier', with: 'A00031'
      click_button 'New'
      expect(page).to have_content 'A00031'
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text 31\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[3]").click
      fill_in "DTE_Field_notation", with: "SUBMISSION 31\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[4]").click
      fill_in "DTE_Field_preferredTerm", with: "The PT 31\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as 31\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[1]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky 31!\n"
      fill_in 'Identifier', with: 'A00032'
      click_button 'New'
      expect(page).to have_content 'A00032'
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[2]").click
      fill_in "DTE_Field_label", with: "Label text 32\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[3]").click
      fill_in "DTE_Field_notation", with: "SUBMISSION 32\t"
      #find(:xpath, "//table[@id='editor_table']/tbody/tr[4]/td[4]").click
      fill_in "DTE_Field_preferredTerm", with: "The PT 32\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[5]").click
      fill_in "DTE_Field_synonym", with: "Same as 32\n"
      find(:xpath, "//table[@id='editor_table']/tbody/tr[2]/td[6]").click
      fill_in "DTE_Field_definition", with: "We never fill this in, too tricky 32!\n"
      #pause
      find(:xpath, "//tr[contains(.,'Same as 32')]/td/button", :text => 'Delete').click
      ui_click_ok("Are you sure?")
      expect(page).to have_content 'A00031'
      expect(page).not_to have_content 'A00032'
    end

  end

end