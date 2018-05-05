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

    expect(rendered).to have_content("Import Form From ALS")
    expect(rendered).to have_content("Import Form From ODM")
    expect(rendered).to have_content("Import Terminology From Excel")
    expect(rendered).to have_link "Import ALS Form"
    expect(rendered).to have_link "Import ODM Form"
    expect(rendered).to have_link "Import Terminology"
    
  end

end