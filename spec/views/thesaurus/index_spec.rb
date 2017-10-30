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
    thesauri << { :owner => "ABC", :identifier => "ID1", :label => "Number 1", :owner_id => "ABC_ID" }
    thesauri << { :owner => "ABC", :identifier => "ID2", :label => "Number 2", :owner_id => "ABC_ID" } 
    thesauri << { :owner => "XYZ", :identifier => "ID3", :label => "Number 3", :owner_id => "XYZ_ID" } 
    assign(:thesauri, thesauri)

    render
    expect(rendered).to have_content("Index: Terminology")
    expect(rendered).to have_content("New Terminology")
    expect(rendered).to have_content("Search Current Terminology")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'ABC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'ID1')  
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'Number 1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'ABC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'ID2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'Number 2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: 'XYZ')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(2)", text: 'ID3')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(3)", text: 'Number 3')
    
  end

  it 'displays index, new disabled' do
    
    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(new?: false)

    thesauri = []
    thesauri << { :owner => "ABC", :identifier => "ID1", :label => "Number 1", :owner_id => "ABC_ID" }
    thesauri << { :owner => "ABC", :identifier => "ID2", :label => "Number 2", :owner_id => "ABC_ID" } 
    thesauri << { :owner => "XYZ", :identifier => "ID3", :label => "Number 3", :owner_id => "XYZ_ID" } 
    assign(:thesauri, thesauri)

    render
    expect(rendered).to have_content("Index: Terminology")
    expect(rendered).to_not have_content("New Terminology")
    expect(rendered).to have_content("Search Current Terminology")
    #ui_check_breadcrumb("Background", "", "", "")
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(1)", text: 'ABC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(2)", text: 'ID1')  
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(1) td:nth-of-type(3)", text: 'Number 1')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(1)", text: 'ABC')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(2)", text: 'ID2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(2) td:nth-of-type(3)", text: 'Number 2')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(1)", text: 'XYZ')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(2)", text: 'ID3')
    expect(rendered).to have_selector("table#main tbody tr:nth-of-type(3) td:nth-of-type(3)", text: 'Number 3')
    
  end

end