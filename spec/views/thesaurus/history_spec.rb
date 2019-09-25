require 'rails_helper'

describe 'thesauri/history.html.erb', :type => :view do

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

    def view.policy(name)
      # Do nothing
    end

    assign(:identifier, "aaa")
    assign(:scope_id, "123")

    render

  	#puts response.body

    expect(rendered).to have_content("History: aaa")
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Owner')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Identifier')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Label')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Version Label')

    expect(rendered).to have_content("Comments By Version")
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Creation Date')
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Last Change Date')
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Description')
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Comments')
    expect(rendered).to have_selector("table#comments_table thead tr:nth-of-type(1) th:nth-of-type(6)", text: 'References')

  end

end
