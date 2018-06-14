require 'rails_helper'

describe 'imports/als/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports/als"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the ALS import screen' do 

    assign(:als, Import::Als.new)
    assign(:files, ["fred.xlsx"])
    assign(:forms, [])

    render

  	#puts response.body

    expect(rendered).to have_content("Form Import - ALS")
    expect(rendered).to have_content("Forms")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"
    
  end

end