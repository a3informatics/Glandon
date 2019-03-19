require 'rails_helper'

describe 'cdisc_terms/import.html.erb', :type => :view do

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

    load_test_file_into_triple_store("CT_V47.ttl")
    load_test_file_into_triple_store("CT_V48.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, import and files' do 

    files = [ "a.owl", "b.owl", "c.owl" ]
    all = CdiscTerm.all
    next_version = all.last.next_version

    assign(:cdiscTerm, CdiscTerm.new)
    assign(:files, files)
    assign(:next_version, all.last.next_version)
    
    render

  #puts response.body

    expect(rendered).to have_content("New CDISC Terminology Version")
    expect(rendered).to have_xpath("//input[@id = 'cdisc_term_version' and @value = '49']")
    expect(rendered).to have_selector("select option", text: 'a.owl')
    expect(rendered).to have_selector("select option", text: 'b.owl')
    expect(rendered).to have_selector("select option", text: 'c.owl')
    
    expect(rendered).to have_button "Create"
    expect(rendered).to have_link "Close"
    
  end

end