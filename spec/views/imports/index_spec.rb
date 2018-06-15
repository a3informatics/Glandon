require 'rails_helper'

describe 'imports/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the form history' do 

    render

  	#puts response.body

    expect(rendered).to have_content("Form Import - ALS")
    expect(rendered).to have_content("Form Import - ODM")
    expect(rendered).to have_content("Import Terminology - EXCEL")
    expect(rendered).to have_content("Import Terminology - ODM")
    expect(rendered).to have_link "Import ALS Form"
    expect(rendered).to have_link "Import ODM Form"
    expect(rendered).to have_link "Import Excel Terminology"
    expect(rendered).to have_link "Import ODM Terminology"    
  end

end