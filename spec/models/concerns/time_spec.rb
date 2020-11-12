require 'rails_helper'

describe Time do
	
	it "checks creation of just date" do
		date = "2016-11-04"
    expect(date.to_time_with_default.iso8601).to eq("2016-11-04T00:00:00+00:00")
	end

  it "checks creation of date and time" do
    date = "2016-11-04T00:10:00+02:00"
    expect(date.to_time_with_default.iso8601).to eq("2016-11-04T00:10:00+02:00")
  end

  it "checks creation of date and time, error" do
    date = "2016-11-04000"
    expect(date.to_time_with_default.iso8601).to eq("2016-01-01T00:00:00+00:00")
  end

  it "formats a 8601 as date" do
    date = "2016-11-04T00:10:00+00:00"
    expect(date.format_as_date).to eq("2016-11-04")
    date = "2016-11-04T00:10:00+02:00"
    expect(date.format_as_date).to eq("2016-11-03")
  end

end