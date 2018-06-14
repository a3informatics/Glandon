require 'rails_helper'
require_dependency 'import/odm' # Needed becuase Odm is alos name of a gem.

describe 'imports/odm/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports/odm"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the ODM import screen' do 
    
    assign(:odm, Import::Odm.new)
    assign(:files, ["fred.xml"])
    assign(:forms, [])

    render

  	#puts response.body

    expect(rendered).to have_content("Form Import - ODM")
    expect(rendered).to have_content("Forms")
    expect(rendered).to have_link "Close"
    expect(rendered).to have_button "List"
    
  end

end