require 'rails_helper'

describe 'cdisc_terms/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  before :all do
    clear_triple_store
  end

  it 'community dashboard' do

    def view.policy(name)
      # Do nothing
    end

    assign(:current_id, "bbb")
    assign(:latest_id, "ccc")
    assign(:versions,[{:id=>"aHR0c", :date=>"2007-03-06"}, {:id=>"aHR0cDovL", :date=>"2007-04-20"}, {:id=>"aHR0cDovLd", :date=>"2010-04-20"}])
    assign(:versions_normalized, [0.0, 1.0006671114076051] )
    assign(:versions_yr_span, ["2007", "2019"])

    render
  	#puts response.body
    expect(rendered).to have_content("Changes between two CDISC Terminology versions")
    expect(rendered).to have_content("Select versions by dragging the sliders and click Display to display changes:")
    expect(rendered).to have_content("Deleted Code List")
    expect(rendered).to have_content("Updated Code List")
    expect(rendered).to have_content("Created Code List")
    expect(rendered).to have_content("Display")
    expect(rendered).to have_content("Filter", count: 3)
    expect(rendered).to have_content("Total", count: 3)
    expect(rendered).to have_link "Browse every version of CDISC CT"
    expect(rendered).to have_link "See the changes across versions"
    expect(rendered).to have_link "See submission value changes across versions"
    expect(rendered).to have_link "Search the latest version of CDISC CT"

  end

end
