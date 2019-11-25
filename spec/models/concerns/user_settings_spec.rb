require 'rails_helper'

describe UserSettings do

  C_EMAIL = "settings@example.com"

  # Note, easier to use User class that includes UserSettings module
  # Results depend on config.yml content

  include UserSettingsHelpers
  include UserAccountHelpers

  before :all do
    @user = ua_add_user(email: C_EMAIL)
  end

  after :all do
    ua_remove_user(C_EMAIL)
  end

  it "read and write a setting" do
    @user.write_setting(:test1, true)
    setting = @user.read_setting(:test1)
		expect(setting.value.to_bool).to eq(true)
	end

  it "read settings" do
    user = ua_add_user(email: C_EMAIL)
    the_settings = @user.settings
    expected =
    	{
    		:paper_size => "A4",
    		:table_rows=>"10",
        :dashboard_layout => "terminologies, stats",
    		:edit_lock_warning=>"60",
    		:user_name_display=>"Yes",
    		:user_role_display=>"Yes",
    		:max_term_display=>"4"
    	}
    expect(the_settings).to eq(expected)
  end

  it "read setting metadata" do
    expect(@user.settings_metadata).to eq(us_expected_metadata)
  end

  it "returns the datatables settings" do
    expect(UserSettings.datatable_settings).to eq("[[5,10,15,25,50,100,-1], [\"5\",\"10\",\"15\",\"25\",\"50\",\"100\",\"All\"]]")
  end

  it "returns the datatables settings, default" do
    UserSettings.clear_settings_metadata
    expect(UserSettings.datatable_settings).to eq("[[5,10,25,50,100,-1], [\"5\",\"10\",\"25\",\"50\",\"100\",\"All\"]]")
  end

  it "returns the default user dashboard layout setting" do
    setting = @user.read_setting :dashboard_layout
    expect(setting.value).to eq("terminologies, stats")
  end

end
