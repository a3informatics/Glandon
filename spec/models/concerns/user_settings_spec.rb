require 'rails_helper'

describe UserSettings do

  # Note, easier to use User class that includes UserSettings module
  # Results depend on config.yml content

  it "read and write a setting" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    user.write_setting(:test1, true)
    setting = user.read_setting(:test1)
		expect(setting.value.to_bool).to eq(true)
	end

  it "read settings" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    the_settings = user.settings
    expect(the_settings).to eq({:paper_size => "A4"})
  end

  it "read setting metadata" do
    user = User.create :email => "settings@example.com", :password => "changeme"
    the_settings_md = user.settings_metadata
    expect(the_settings_md).to eq(:paper_size => {:type=>"enum", :enum_values=>["A3", "A4", "Letter"], :label=>"Paper Size"})
  end

end