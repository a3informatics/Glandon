require 'rails_helper'

describe 'biomedical_concepts/show.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/biomedical_concepts"
  end

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl", "thesaurus.ttl",
      "BusinessOperational.ttl", "BusinessDomain.ttl", "CDISCBiomedicalConcept.ttl"]
    data_files = ["iso_namespace_real.ttl", "iso_registration_authority_real.ttl", "BC.ttl", "BCT.ttl"]
    load_files(schema_files, data_files)
    load_cdisc_term_versions(1..42)
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the form, clone and upgrade' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(clone?: true, upgrade?: true)

    bc = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    items = bc.get_properties(true)
    references = BiomedicalConcept.get_unique_references(items)
    assign(:bc, bc)
    assign(:items, items)
    assign(:references, references)

    render
    expect(rendered).to have_content("Show: Height (BC C25347) BC C25347 (V1.0.0, 1, Standard)")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'Baseline (--BLFL)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Question text')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'Prompt text')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'boolean')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: 'N (C49487)')

    expect(rendered).to have_link "Clone"
    #expect(rendered).to have_link "Upgrade"

    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'C49487')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'N')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'CDISC')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(4)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '42.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(6)", text: '2015-09-25')

  end

  it 'displays the form, clone, no upgrade' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(clone?: false, upgrade?: true)

    bc = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    items = bc.get_properties(true)
    references = BiomedicalConcept.get_unique_references(items)
    assign(:bc, bc)
    assign(:items, items)
    assign(:references, references)

    render
    expect(rendered).to have_content("Show: Height (BC C25347) BC C25347 (V1.0.0, 1, Standard)")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'Result Value (--ORRES)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Result value?')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'Result')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'float')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(7)", text: '')

    expect(rendered).to_not have_link "Clone"
    #expect(rendered).to have_link "Upgrade"

    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(1)", text: 'C49668')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(2)", text: 'cm')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(3)", text: 'CDISC')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(4)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(5)", text: '42.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(3) td:nth-of-type(6)", text: '2015-09-25')

  end

  it 'displays the form, no clone or upgrade' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(clone?: false, upgrade?: false)

    bc = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    items = bc.get_properties(true)
    references = BiomedicalConcept.get_unique_references(items)
    assign(:bc, bc)
    assign(:items, items)
    assign(:references, references)

    render
    expect(rendered).to have_content("Show: Height (BC C25347) BC C25347 (V1.0.0, 1, Standard)")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(1)", text: 'Test Code (--TESTCD)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(2)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(3)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(6)", text: 'string')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(5) td:nth-of-type(8)", text: 'HEIGHT (C25347)')

    expect(rendered).to_not have_link "Clone"
    expect(rendered).to_not have_link "Upgrade"

    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(1)", text: 'C25347')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(2)", text: 'Height')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(3)", text: 'CDISC')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(4)", text: 'CDISC Terminology')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(5)", text: '42.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(7) td:nth-of-type(6)", text: '2015-09-25')

  end
end
