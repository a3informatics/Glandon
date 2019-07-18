require 'rails_helper'

describe 'cdisc_terms/history.html.erb', :type => :view do

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

    assign(:cdisc_term_id, "aaa")

    render

  	#puts response.body

    expect(rendered).to have_content("History: CDISC Terminology")
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(1)", text: 'Version')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(2)", text: 'Owner')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(3)", text: 'Identifier')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(4)", text: 'Version Label')
    expect(rendered).to have_selector("table#history thead tr:nth-of-type(1) th:nth-of-type(5)", text: 'Label')

    expect(rendered).to have_link "Changes"
    expect(rendered).to have_link "Submission"
    
  end

end