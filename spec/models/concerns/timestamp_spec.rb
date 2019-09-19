require 'rails_helper'

describe Timestamp do
	
	it "allows for the class to be created with no initial value" do
		timestamp = Timestamp.new()
    expect(timestamp.to_8601.to_time).to be_within(1.second).of Time.now
	end

  it "allows for the class to be created with an initial value" do
    timestamp = Timestamp.new("2016-11-04")
    expect(timestamp.time.strftime("%Y-%b-%d").to_s).to eq("2016-Nov-04")
  end

  it "allows the time to be set" do
    timestamp = Timestamp.new()
    timestamp.from_timestamp("2016-11-04 16:00:01")
    expect(timestamp.time.strftime("%Y-%b-%d, %H:%M")).to eq("2016-Nov-04, 16:00")
  end

  it "supports multiple output formats" do
    timestamp = Timestamp.new()
    timestamp.from_timestamp("2016-11-04 16:00:01")
    expect(timestamp.to_datetime).to eq("2016-Nov-04, 16:00")
    expect(timestamp.to_date).to eq("2016-Nov-04")
    expect(timestamp.to_8601).to eq("2016-11-04T16:00:01Z")
  end

end