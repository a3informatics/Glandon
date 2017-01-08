require 'rails_helper'

describe "ISO Concept JS", :type => :feature do
  
  include DataHelpers
  include PauseHelpers
  
  before :all do
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
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessForm.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")    
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline.ttl")
    clear_iso_concept_object
  end

  after :all do
    user = User.where(:email => "curator@example.com").first
    user.destroy
  end

  describe "Curator User", :type => :feature do

    it "allows the metadata graph to be viewed", js: true do
      audit_count = AuditTrail.count
      visit '/users/sign_in'
      fill_in 'Email', with: 'curator@example.com'
      fill_in 'Password', with: '12345678'
      click_button 'Log in'
      #pause
      click_link 'Biomedical Concepts'
      #pause
      expect(page).to have_content 'Index: Biomedical Concepts'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'History').click
      #pause
      expect(page).to have_content 'History: BC A00003'
      find(:xpath, "//tr[contains(.,'BC A00003')]/td/a", :text => 'Gr+').click
      expect(page).to have_content 'Metadata View:'
      expect(page).to have_button('graph_focus', disabled: true)
      expect(page).to have_field('concept_type', disabled: true)
      expect(page).to have_field('concept_label', disabled: true)
      click_button 'graph_stop'
      expect(page).to have_button('graph_focus', disabled: false)
      #pause
    end

    it "allows a impact page to be displayed"

  end

end