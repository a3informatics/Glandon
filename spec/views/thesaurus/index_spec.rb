require 'rails_helper'

describe 'thesauri/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers

  it 'displays index, new enabled' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(new?: true)

    thesauri = []
    thesauri << { :owner => "ABC", :identifier => "ID1", :label => "Number 1", :scope_id => "ABC_ID" }
    thesauri << { :owner => "ABC", :identifier => "ID2", :label => "Number 2", :scope_id => "ABC_ID" }
    thesauri << { :owner => "XYZ", :identifier => "ID3", :label => "Number 3", :scope_id => "XYZ_ID" }
    assign(:thesauri, thesauri)

    render

    expect(rendered).to have_content("Index: Terminology")
    expect(rendered).to have_content("New Terminology")
    expect(rendered).to have_content("Search across all current versions")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Number 1?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Owner: ABC?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Identifier: ID1?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Number 2?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Owner: ABC?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Identifier: ID2?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Number 3?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Owner: XYZ?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Identifier: ID3?/i)
  end

  it 'displays index, new disabled' do

    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(new?: false)

    thesauri = []
    thesauri << { :owner => "ABC", :identifier => "ID1", :label => "Number 1", :scope_id => "ABC_ID" }
    thesauri << { :owner => "ABC", :identifier => "ID2", :label => "Number 2", :scope_id => "ABC_ID" }
    thesauri << { :owner => "XYZ", :identifier => "ID3", :label => "Number 3", :scope_id => "XYZ_ID" }
    assign(:thesauri, thesauri)

    render
    expect(rendered).to have_content("Index: Terminology")
    expect(rendered).to have_content("Search across all current versions")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Number 1?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Owner: ABC?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: /Identifier: ID1?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Number 2?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Owner: ABC?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: /Identifier: ID2?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Number 3?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Owner: XYZ?/i)
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: /Identifier: ID3?/i)
  end

end
