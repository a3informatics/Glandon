require 'rails_helper'

describe 'dashboard/index.html.erb', :type => :view do

  include UiHelpers
  include UserAccountHelpers
  include DataHelpers
  include PublicFileHelpers

  def sub_dir
    return "views/dashboard"
  end

  it 'displays the panels' do
    def view.policy(name)
      # Do nothing
    end

    allow(view).to receive(:policy).and_return double(index?: true)

    UserSettings.reset_settings_metadata
    user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"
    unforce_first_pass_change user

    allow(view).to receive(:current_user).and_return(user)

    assign(:settings_metadata, user.settings_metadata)
    assign(:settings, user.settings)
    assign(:user, user)

  	render

    expect(rendered).to have_content("Dashboard")
  	expect(rendered).to have_content("Terminologies")

  end

end
