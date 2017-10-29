require 'rails_helper'

describe 'user_settings/index.html.erb', :type => :view do

  include UserAccountHelpers

  it 'displays user details correctly, I' do
    
    def view.policy(name)
      # Do nothing
    end

    UserSettings.reset_settings_metadata
    user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"

    allow(view).to receive(:policy).and_return double(index?: true)
    allow(view).to receive(:user_signed_in?) { true }
    allow(view).to receive(:current_user).and_return(user)

    assign(:settings_metadata, user.settings_metadata)
    assign(:settings, user.settings)
    assign(:user, user)

    render

    expect(rendered).to have_content("Current Settings: User Fred (user@assero.co.uk)")
    expect(rendered).to have_content("Display Name:User Fred")
    expect(rendered).to have_content("Email:user@assero.co.uk")

    expect(rendered).to have_content("Change Password")
    expect(rendered).to have_content("New Password:")
    expect(rendered).to have_content("Confirm New Password:")
    expect(rendered).to have_content("Current Password:")
    
    expect(rendered).to have_content("Change Display Name")
    expect(rendered).to have_content("New Display Name:")

    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(1) td:nth-of-type(2) a", text: 'Yes')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(2) td:nth-of-type(2) a", text: 'Yes')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(2) a", text: '1m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(2) a", text: 'A4')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(2) a", text: '10')
    
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(1) td:nth-of-type(3) a", text: 'No')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(2) td:nth-of-type(3) a", text: 'No')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[1]", text: '30s')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[2]", text: '1m 30s')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[3]", text: '2m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[4]", text: '3m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[5]", text: '5m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(3) a[1]", text: 'A3')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(3) a[2]", text: 'Letter')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[1]", text: '5')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[2]", text: '15')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[3]", text: '25')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[4]", text: '50')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[5]", text: '100')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[6]", text: 'All')
    
    expect(rendered).to have_selector("input#password_update_button")
    expect(rendered).to have_selector("input#name_update_button")

  end

  it 'displays user details correctly, II' do
    
    def view.policy(name)
      # Do nothing
    end

    user = User.create :email => "user@assero.co.uk", :password => "cHangeMe14%", :name => "User Fred"
    allow(view).to receive(:policy).and_return double(index?: true)
    allow(view).to receive(:user_signed_in?) { true }
    allow(view).to receive(:current_user).and_return(user)
    user.save # Need to save such that the settings can be saved

    user.user_name_display = "No"
    user.table_rows = "25"

    assign(:settings_metadata, user.settings_metadata)
    assign(:settings, user.settings)
    assign(:user, user)

    render
    expect(rendered).to have_content("Current Settings: User Fred (user@assero.co.uk)")
    expect(rendered).to have_content("Display Name:User Fred")
    expect(rendered).to have_content("Email:user@assero.co.uk")

    expect(rendered).to have_content("Change Password")
    expect(rendered).to have_content("New Password:")
    expect(rendered).to have_content("Confirm New Password:")
    expect(rendered).to have_content("Current Password:")
    
    expect(rendered).to have_content("Change Display Name")
    expect(rendered).to have_content("New Display Name:")

    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(1) td:nth-of-type(2) a", text: 'No')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(2) td:nth-of-type(2) a", text: 'Yes')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(2) a", text: '1m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(2) a", text: 'A4')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(2) a", text: '25')
    
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(1) td:nth-of-type(3) a", text: 'Yes')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(2) td:nth-of-type(3) a", text: 'No')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[1]", text: '30s')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[2]", text: '1m 30s')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[3]", text: '2m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[4]", text: '3m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(3) td:nth-of-type(3) a[5]", text: '5m')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(3) a[1]", text: 'A3')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(4) td:nth-of-type(3) a[2]", text: 'Letter')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[1]", text: '5')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[2]", text: '10')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[3]", text: '15')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[4]", text: '50')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[5]", text: '100')
    expect(rendered).to have_selector("table#user_settings tbody tr:nth-of-type(5) td:nth-of-type(3) a[6]", text: 'All')
    
    expect(rendered).to have_selector("input#password_update_button")
    expect(rendered).to have_selector("input#name_update_button")

  end

end