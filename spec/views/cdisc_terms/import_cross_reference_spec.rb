require 'rails_helper'

describe 'cdisc_terms/import_cross_reference.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessDomain.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..48)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, import and files' do

    files = [ "a.xlsx", "b.xlsx", "c.xlsx" ]
    cdisc_term = CdiscTerm.find_minimum(Uri.new(uri:"http://www.cdisc.org/CT/V48#TH"))
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
