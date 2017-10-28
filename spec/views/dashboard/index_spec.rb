require 'rails_helper'

describe 'dashboard/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/dashboard"
  end

  it 'displays the six panels' do 

  	render 

  	expect(rendered).to have_content("Terminology")
		expect(rendered).to have_content("Biomedical Concept Templates")
		expect(rendered).to have_content("Biomedical Concepts")
		expect(rendered).to have_content("Forms")
		expect(rendered).to have_content("Domains")
		expect(rendered).to have_content("Registration Status Counts")

  end

end