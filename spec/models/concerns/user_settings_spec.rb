require 'rails_helper'

describe UserSettings do

  # Note, easier to use User class that includes UserSettings module
  # Results depend on config.yml content

  include UserSettingsHelpers

  it "read and write a setting" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    user.write_setting(:test1, true)
    setting = user.read_setting(:test1)
		expect(setting.value.to_bool).to eq(true)
	end

  it "read settings" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    the_settings = user.settings
    expect(the_settings).to eq({:paper_size => "A4", :table_rows=>"10", :edit_lock_warning=>"60"})
  end

  it "read setting metadata" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    expect(user.settings_metadata).to eq(us_expected_metadata)
  end

  it "returns the datatables settings" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    expect(UserSettings.datatable_settings).to eq("[[5,10,15,25,50,100,-1], [\"5\",\"10\",\"15\",\"25\",\"50\",\"100\",\"All\"]]")
  end

  it "returns the datatables settings, default" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    UserSettings.clear_settings_metadata
    expect(UserSettings.datatable_settings).to eq("[[5,10,25,50,100,-1], [\"5\",\"10\",\"25\",\"50\",\"100\",\"All\"]]")
  end

end