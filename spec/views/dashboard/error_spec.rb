require 'rails_helper'

describe 'dashboard/error.html.erb' do

  include UiHelpers

  it 'displays the error screen, reader & curator' do
    
    def view.policy(name)
     # Do nothing
  	end
  
  	user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"
  	user.add_role :curator

    allow(view).to receive(:user_signed_in?) { true }
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to have_content("Invalid Roles Detected")
    expect(rendered).to have_content("Current role list is: Curator, Reader")

    user.destroy

  end

  it 'displays the error screen, no role' do
    
    def view.policy(name)
     # Do nothing
  	end
  
  	user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"
  	user.remove_role :reader

    allow(view).to receive(:user_signed_in?) { true }
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to have_content("Invalid Roles Detected")
    expect(rendered).to have_content("Current role list is:")

    user.destroy

  end

end