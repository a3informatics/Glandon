require 'rails_helper'

describe 'iso_namespaces/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include IsoHelpers

  before :all do
    schema_files = ["ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", "ISO11179Concepts.ttl"]
    data_files = ["iso_namespace_real.ttl"]
    load_files(schema_files, data_files)
  end

  it 'displays the form' do

    namespaces = IsoNamespace.all

    assign(:namespaces, namespaces)

    IsoHelpers.mark_as_used(namespaces.first.uri)

    render

    expect(rendered).to have_content("Namespaces")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'Clinical Data Interchange Standards Consortium')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'CDISC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'ACME Pharma')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'ACME')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'Delete')

    expect(rendered).to have_link 'New'
    expect(rendered).to have_link 'Close'

  end

end
