require 'rails_helper'

describe 'dashboard/admin.html.erb' do

  include UiHelpers

  it 'displays the admin screen' do
    
    def view.policy(name)
     # Do nothing
  	end
  
  	allow(view).to receive(:policy).exactly(5).times.and_return double(index?: true)

    render

    expect(rendered).to have_content("Users")
    expect(rendered).to have_content("Edit Locks")
    expect(rendered).to have_content("Audit Trail")
    expect(rendered).to have_content("Managed Items")
    expect(rendered).to have_content("Background Jobs")

  end

  it 'displays the admin screen' do
    
    def view.policy(name)
     # Do nothing
  	end
  
  	allow(view).to receive(:policy).and_return(double(index?: false), double(index?: true), double(index?: false), double(index?: false), double(index?: false))

    render

    expect(rendered).to_not have_content("Users")
    expect(rendered).to have_content("Edit Locks")
    expect(rendered).to_not have_content("Audit Trail")
    expect(rendered).to_not have_content("Managed Items")
    expect(rendered).to_not have_content("Background Jobs")

  end

end