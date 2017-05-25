require 'rails_helper'

describe 'cdisc_terms/file.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/cdisc_terms"
  end

  before :all do
    clear_triple_store
  end

  it 'displays the form, import and files' do 

    files = [ "a.yaml", "b.yaml", "c.yaml" ]

    assign(:files, files)
    
    render

  puts response.body

    expect(rendered).to have_content("Files:")
    expect(rendered).to have_xpath("//input[@id = 'cb_1' and @value = 'a.yaml']")
    expect(rendered).to have_xpath("//input[@id = 'cb_2' and @value = 'b.yaml']")
    expect(rendered).to have_xpath("//input[@id = 'cb_3' and @value = 'c.yaml']")
    
    expect(rendered).to have_button "Delete"
    expect(rendered).to have_link "Close"
    
  end

end