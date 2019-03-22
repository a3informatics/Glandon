require 'rails_helper'

describe 'iso_namespaces/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include IsoHelpers

  before :all do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
  end
      
  it 'displays the form' do 

    namespaces = [IsoNamespace.new, IsoNamespace.new]
    namespaces.first.uri = Uri.new(uri: "http://www.assero.co.uk/NS#AAA")
    namespaces.first.short_name = "AAA"
    namespaces.first.name = "AAA Long Name"
    namespaces.last.uri = Uri.new(uri: "http://www.assero.co.uk/NS#BBB")
    namespaces.last.short_name = "BBB"
    namespaces.last.name = "BBB Long Name"
    assign(:namespaces, namespaces)

    IsoHelpers.mark_as_used(namespaces.first.uri)
    
    render
    
    expect(rendered).to have_content("Namespaces")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'AAA Long Name')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'AAA')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: '')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'BBB Long Name')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'BBB')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'Delete')

    expect(rendered).to have_link 'New'
    expect(rendered).to have_link 'Close'

  end

end