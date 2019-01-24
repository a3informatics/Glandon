require 'rails_helper'

describe 'imports/crfs/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports/crfs"
  end

  before :each do
    clear_triple_store
  end

  it 'displays the ALS import screen' do 

    assign(:model, Import::Crf.new)
    assign(:files, ["fred.xlsx"])
    assign(:forms, [])
    assign(:file_type, 2)

    render

  	#puts response.body

    expect(rendered).to have_content("Import Forms from ALS")
    expect(rendered).to have_content("fred.xlsx")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"
    
  end

  it 'displays the ODM import screen' do 

    assign(:model, Import::Crf.new)
    assign(:files, ["fred.xlsx"])
    assign(:forms, [])
    assign(:file_type, 1)

    render

    #puts response.body

    expect(rendered).to have_content("Import Forms from ODM")
    expect(rendered).to have_content("fred.xlsx")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"
    
  end

end