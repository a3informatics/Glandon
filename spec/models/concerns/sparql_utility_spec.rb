require 'rails_helper'

describe SparqlUtility do
	
	it "replaces LF characters" do
		expect(SparqlUtility.replace_special_chars("A line\nAnother line")).to eq("A line\\nAnother line")
	end

  it "replaces CR characters" do
    expect(SparqlUtility.replace_special_chars("A line\rAnother line")).to eq("A line\\rAnother line")
  end

  it "replaces & characters" do
    expect(SparqlUtility.replace_special_chars("A line\r& Another line")).to eq("A line\\r%26 Another line")
  end

  it "replaces \\ character sequence" do
    expect(SparqlUtility.replace_special_chars("A line\\\r& Another line")).to eq("A line\\\\\\r%26 Another line")
  end

  it "replaces \\\" character sequence" do
    expect(SparqlUtility.replace_special_chars("A line\\\r& Another line\rAnd \\\"")).to eq("A line\\\\\\r%26 Another line\\rAnd \\\\\\\"")
  end

  it "replaces & characters" do
    expect(SparqlUtility.replace_special_chars("&")).to eq("%26")
  end

  it "replaces + characters" do
    expect(SparqlUtility.replace_special_chars("2012-10-11T14:34:34+00:00")).to eq("2012-10-11T14:34:34%2B00:00")
  end

end