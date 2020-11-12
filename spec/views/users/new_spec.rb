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

    expect(rendered).to have_content("New user account")
    expect(rendered).to have_selector("input#user_email")
    expect(rendered).to have_selector("input#user_name")
    expect(rendered).to have_selector("input#user_password")
    expect(rendered).to have_selector("input#user_password_confirmation")

    expect_button("create_button")

  end

end
