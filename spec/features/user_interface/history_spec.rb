require 'rails_helper'

describe "History", :type => :feature do
  
  include DataHelpers
	include PauseHelpers
  include UserAccountHelpers

  before :all do
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
    load_test_file_into_triple_store("form_example_dm1.ttl")
    load_test_file_into_triple_store("form_example_dm1_branch.ttl")
    load_test_file_into_triple_store("form_example_vs_baseline_new.ttl")
    load_test_file_into_triple_store("form_example_general.ttl")
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

  describe "Check Views", :type => :feature do
  
    it "reader"  do
      ua_reader_login
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
    #save_and_open_page
      expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '0.0.0')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Demographics')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'DM1 01')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Show')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: 'View')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(9)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(10)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Candidate')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(12)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(13)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(14)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(15)", text: 'T Gr- Gr+')
    end

    it "curator"  do
      ua_curator_login
      visit '/forms'
      expect(page).to have_content 'Index: Forms'
      find(:xpath, "//tr[contains(.,'DM1 01')]/td/a", :text => 'History').click
      expect(page).to have_content 'History: DM1 01'
    #save_and_open_page
      expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '0.0.0')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Demographics')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'DM1 01')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Show')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: 'View')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(9)", text: 'Edit')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(10)", text: 'Tags')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Candidate')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(12)", text: 'Status')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(13)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(14)", text: '')
	    expect(page).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(15)", text: 'T Gr- Gr+')
    end

  end

end