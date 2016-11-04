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

end