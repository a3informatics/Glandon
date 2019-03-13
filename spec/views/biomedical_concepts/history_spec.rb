require 'rails_helper'

describe 'biomedical_concepts/history.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/biomedical_concepts"
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
    load_test_file_into_triple_store("BCT.ttl")
    load_test_file_into_triple_store("BC.ttl")
    load_test_file_into_triple_store("CT_V42.ttl")
    clear_iso_concept_object
    clear_iso_namespace_object
    clear_iso_registration_authority_object
    clear_iso_registration_state_object
    clear_cdisc_term_object
  end

  it 'displays the history, edit and destroy' do 

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(edit?: true, destroy?: true)

    bc1 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2.scopedIdentifier.version = 1 # Leave this at 1, makes the version management checks think it is the latest version!!!
    bc2.scopedIdentifier.semantic_version = "1.1.0"
    bc2.scopedIdentifier.versionLabel = "0.2"
    bc2.registrationState.registrationStatus = "Incomplete"

    bc = []
    bc << bc1
    bc << bc2

    assign(:bc, bc)
    assign(:identifier, bc1.scopedIdentifier.identifier)
    
    render
    expect(rendered).to have_content("History: BC C25347")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '0.1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(9)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(10)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Standard')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(12)", text: 'Status')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(14)", text: '')

    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '0.2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(9)", text: 'Edit')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(10)", text: 'Tags')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(11)", text: 'Incomplete')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(12)", text: 'Status')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(14)", text: 'Delete')
    
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(2)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(6)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')

  end

it 'displays the history, edit, no destroy' do 

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(edit?: true, destroy?: false)

    bc1 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2.scopedIdentifier.version = 1 # Leave this at 1, makes the version management checks think it is the latest version!!!
    bc2.scopedIdentifier.semantic_version = "1.1.0"
    bc2.scopedIdentifier.versionLabel = "0.2"
    bc2.registrationState.registrationStatus = "Incomplete"

    bc = []
    bc << bc1
    bc << bc2

    assign(:bc, bc)
    assign(:identifier, bc1.scopedIdentifier.identifier)
    
    render
    expect(rendered).to have_content("History: BC C25347")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '0.1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(9)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(10)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Standard')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(12)", text: 'Status')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(14)", text: '')

    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '0.2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(9)", text: 'Edit')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(10)", text: 'Tags')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(11)", text: 'Incomplete')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(12)", text: 'Status')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(14)", text: '')
    
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(2)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(6)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')

  end

  it 'displays the history, no edit or destroy' do 

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(edit?: false, destroy?: false)

    bc1 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2 = BiomedicalConcept.find("BC-ACME_BC_C25347", "http://www.assero.co.uk/MDRBCs/V1")
    bc2.scopedIdentifier.version = 1 # Leave this at 1, makes the version management checks think it is the latest version!!!
    bc2.scopedIdentifier.semantic_version = "1.1.0"
    bc2.scopedIdentifier.versionLabel = "0.2"
    bc2.registrationState.registrationStatus = "Incomplete"

    bc = []
    bc << bc1
    bc << bc2

    assign(:bc, bc)
    assign(:identifier, bc1.scopedIdentifier.identifier)
    
    render
    expect(rendered).to have_content("History: BC C25347")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '0.1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(9)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(10)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(11)", text: 'Standard')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(12)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(14)", text: '')

    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'Height (BC C25347)')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'BC C25347')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(4)", text: '0.2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(5)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(6)", text: 'Show')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(7)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(8)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(9)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(10)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(11)", text: 'Incomplete')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(12)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(13)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(14)", text: '')
    
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(1)", text: '1.0.0')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(2)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '2016-Jan-01, 00:00')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(4)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(5)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(1) td:nth-of-type(6)", text: '')
    expect(rendered).to have_selector("table#secondary tbody tr:nth-of-type(2) td:nth-of-type(1)", text: '1.1.0')

  end
end