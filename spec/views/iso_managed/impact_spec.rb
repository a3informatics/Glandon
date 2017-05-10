require 'rails_helper'

describe 'iso_concept/impact.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/iso_concept"
  end

  it 'displays the basic page' do 

    item = IsoManaged.new
    item.label = "Test Label"

    managed_items = []
    managed_items << { uri: "http://www.example.com/1", rdf_type: "http://www.example.com/type_A" }
    managed_items << { uri: "http://www.example.com/2", rdf_type: "http://www.example.com/type_B" }
    results = {item: item.to_json, children: managed_items}

    assign(:item, item)
    assign(:results, results)
    
    render

  #puts response.body

    expect(rendered).to have_content("Impact Analysis: #{item.label}")
    expect(rendered).to have_content("Items Impacted")
    expect(rendered).to have_content("Impact Graph")
    expect(rendered).to have_xpath("//table[@id = 'managed_item_table']")
    expect(rendered).to have_button "Close"
    
  end

end