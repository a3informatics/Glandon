require 'rails_helper'

describe 'cdisc_terms/history.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Types.ttl")
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_schema_file_into_triple_store("ISO11179Concepts.ttl")
    load_schema_file_into_triple_store("ISO25964.ttl")
    load_schema_file_into_triple_store("CDISCBiomedicalConcept.ttl")
    load_schema_file_into_triple_store("BusinessOperational.ttl")
    load_schema_file_into_triple_store("BusinessDomain.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")
    load_test_file_into_triple_store("CT_V47.ttl")
    load_test_file_into_triple_store("CT_V48.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, import and files' do 

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(import?: true, edit?: true, destroy?: true)

    terms = CdiscTerm.history
    assign(:cdiscTerms, terms)

    render

  	#puts response.body

    expect(rendered).to have_content("History: CDISC Terminology")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '48.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'CDISC Terminology 2017-03-31')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '2017-03-31')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'CDISC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Standard')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '47.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'CDISC Terminology 2016-12-13')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '2016-12-13')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'CDISC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(11)", text: 'Standard')

    expect(rendered).to have_link "Import"
    expect(rendered).to have_link "Changes"
    expect(rendered).to have_link "Submission"
    expect(rendered).to have_link "Files"
    
  end

  it 'displays the form, no import or files' do 

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(import?: false, edit?: true, destroy?: true)

    terms = CdiscTerm.history
    assign(:cdiscTerms, terms)

    render
    expect(rendered).to have_content("History: CDISC Terminology")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '48.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'CDISC Terminology 2017-03-31')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '2017-03-31')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'CDISC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Standard')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '47.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'CDISC Terminology 2016-12-13')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '2016-12-13')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'CDISC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(11)", text: 'Standard')

    expect(rendered).to_not have_link "Import"
    expect(rendered).to have_link "Changes"
    expect(rendered).to have_link "Submission"
    expect(rendered).to_not have_link "Files"

  end

end