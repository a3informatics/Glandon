require 'rails_helper'

describe 'users/new.html.erb', :type => :view do

  include UserAccountHelpers
  include ViewHelpers

  it 'creates new user' do
    
    def view.policy(name)
      # Do nothing
    end

    render

    #page_to_s

    expect(rendered).to have_content("New: User")
    expect(rendered).to have_content("Email:")
    expect(rendered).to have_content("Display Name:")
    expect(rendered).to have_content("Password:")
    expect(rendered).to have_content("Password Confirmation:")

    expect_button("create_button")

  end

end