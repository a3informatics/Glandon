require 'rails_helper'

describe 'iso_namespaces/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    schema_files = ["ISO11179Identification.ttl", "ISO11179Registration.ttl"]
    data_files = []
    load_files(schema_files, data_files)
  end

  it 'displays the form' do

    ns = IsoNamespace.new
    assign(:namespace, ns)

    render

    expect(rendered).to have_content("New Scope Namespace")
    expect(rendered).to have_content("Short Name:")
    expect(rendered).to have_content("Name:")
    expect(rendered).to have_content("Authority:")

    expect(rendered).to have_button 'Submit'
    expect(rendered).to have_link 'Close'

  end

end
