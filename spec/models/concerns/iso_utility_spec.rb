require 'rails_helper'

describe IsoUtility do
	
	it "builds a URI" do
		expect(IsoUtility.uri("http://www.example.com/", "fred" ).to_s).to eq("http://www.example.com/#fred")
	end

  it "obtains a URI in reference form" do
    expect(IsoUtility.uri_ref("http://www.example.com/", "fred" )).to eq("<http://www.example.com/#fred>")
  end

  it "extracts the CID from an URI" do
    expect(IsoUtility.extract_cid("http://www.example.com/path#fred")).to eq("fred")
  end

  it "extracts the namespace from an URI" do
    expect(IsoUtility.extract_namespace("http://www.example.com/path#fred")).to eq("http://www.example.com/path")
  end

end