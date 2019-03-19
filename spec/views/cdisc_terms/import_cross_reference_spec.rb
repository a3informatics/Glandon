require 'rails_helper'

describe 'cdisc_terms/import_cross_reference.html.erb', :type => :view do

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
    load_test_file_into_triple_store("iso_registration_authority_real.ttl")
    load_test_file_into_triple_store("iso_namespace_real.ttl")

    load_test_file_into_triple_store("CT_V48.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, import and files' do 

    files = [ "a.xlsx", "b.xlsx", "c.xlsx" ]
    cdisc_term = CdiscTerm.find("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", false)
    assign(:cdisc_term, cdisc_term)
    assign(:files, files)
    
    render

  #puts response.body

    expect(rendered).to have_content("Import Change Instructions: CDISC Terminology 2017-03-31 CDISC Terminology (V48.0.0, 48, Standard)")
    expect(rendered).to have_selector("select option", text: 'a.xlsx')
    expect(rendered).to have_selector("select option", text: 'b.xlsx')
    expect(rendered).to have_selector("select option", text: 'c.xlsx')
    
    expect(rendered).to have_button "Import"
    expect(rendered).to have_link "Close"
    
  end

end