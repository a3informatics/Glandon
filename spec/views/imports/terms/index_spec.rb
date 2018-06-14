require 'rails_helper'

describe 'imports/terms/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports/terms"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the Terminology import screen' do 
    
    th_1 = Thesaurus.new
    th_1.label = "XXX Label"
    assign(:th, [th_1])
    assign(:term, Import::Term.new)
    assign(:files, ["fred.xlsx"])
    assign(:code_lists, [])

    render

  	#puts response.body

    expect(rendered).to have_content("Import Terminology - Excel")
    expect(rendered).to have_content("Code Lists")
    expect(rendered).to have_content("XXX Label")
    expect(rendered).to have_content("fred.xlsx")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"
    
  end

end