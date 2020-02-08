require 'rails_helper'

describe 'imports/list.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers

  def sub_dir
    return "views/imports"
  end

  before :all do
    clear_triple_store
  end

  it 'Lists the imports' do

    assign(:items, Import.list)
    render

  #puts response.body

    # expect(rendered).to have_content("CDISC ADaM IG Import - Excel")
    expect(rendered).to have_content("Import Centre")
    expect(rendered).to have_content("CDISC Terminology Import - Excel")
    expect(rendered).to have_content("CDISC Terminology Import - API")
    # expect(rendered).to have_content("Form Import - ALS")
    # expect(rendered).to have_content("Form Import - ODM")
    # expect(rendered).to have_content("Import Terminology - EXCEL")
    # expect(rendered).to have_content("Import Terminology - ODM")
    # expect(rendered).to have_link "Import CDISC ADaM IG"
    # expect(rendered).to have_link "Import CDISC Term"
    # expect(rendered).to have_link "Import Form from ALS"
    # expect(rendered).to have_link "Import Form from ODM"
    # expect(rendered).to have_link "Import Terminology from Excel"
    # expect(rendered).to have_link "Import Terminology from ODM"
    expect(rendered).to have_link "Current Imports"
  end

end
