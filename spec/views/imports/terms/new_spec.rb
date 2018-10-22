require 'rails_helper'

describe 'imports/terms/new.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports/terms"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the Terminology Excel import screen' do 
    
    th_1 = Thesaurus.new
    th_1.label = "XXX Label"
    assign(:th, [th_1])
    assign(:model, Import::Term.new)
    assign(:files, ["fred.xlsx"])
    assign(:code_lists, [])
    assign(:file_type, 0)

    render

  	#puts response.body

    expect(rendered).to have_content("Import Terminology from Excel")
    expect(rendered).to have_content("Files")
    expect(rendered).to have_content("XXX Label")
    expect(rendered).to have_content("Select the target terminology (Status = 'Incomplete') ...")
    expect(rendered).to have_content("fred.xlsx")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"

  end

  it 'displays the Terminology ODM import screen' do 
    
    th_1 = Thesaurus.new
    th_1.label = "XXX Label"
    assign(:th, [th_1])
    assign(:model, Import::Term.new)
    assign(:files, ["fred.xlsx"])
    assign(:code_lists, [])
    assign(:file_type, 1)

    render

    #puts response.body

    expect(rendered).to have_content("Import Terminology from ODM")
    expect(rendered).to have_content("Files")
    expect(rendered).to have_content("XXX Label")
    expect(rendered).to have_content("Select the target terminology (Status = 'Incomplete') ...")
    expect(rendered).to have_content("fred.xlsx")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"

  end

end