require 'rails_helper'

describe SemanticVersion do
	
	it "allows the object to be initialized, none" do
		result = SemanticVersion.new({})
    expect(result.major).to eq(0)
    expect(result.minor).to eq(0)
    expect(result.patch).to eq(0)
	end

  it "allows the object to be initialized, major" do
    result = SemanticVersion.new( major: 2)
    expect(result.major).to eq(2)
    expect(result.minor).to eq(0)
    expect(result.patch).to eq(0)
  end

  it "allows the object to be initialized, minor" do
    result = SemanticVersion.new( minor: 3)
    expect(result.major).to eq(0)
    expect(result.minor).to eq(3)
    expect(result.patch).to eq(0)
  end

  it "allows the object to be initialized, patch" do
    result = SemanticVersion.new( patch: 1)
    expect(result.major).to eq(0)
    expect(result.minor).to eq(0)
    expect(result.patch).to eq(1)
  end

  it "allows the object to be initialized, all" do
    result = SemanticVersion.new( major: 1, minor: 1, patch: 1)
    expect(result.major).to eq(1)
    expect(result.minor).to eq(1)
    expect(result.patch).to eq(1)
  end

  it "allows the object to be initialized from a string, all valid 1" do
    result = SemanticVersion.from_s("1.1.1")
    expect(result.major).to eq(1)
    expect(result.minor).to eq(1)
    expect(result.patch).to eq(1)
  end

  it "allows the object to be initialized from a string, all valid 2" do
    result = SemanticVersion.from_s("1.12.0")
    expect(result.major).to eq(1)
    expect(result.minor).to eq(12)
    expect(result.patch).to eq(0)
  end

  it "allows the object to be initialized from a string, invalid 1" do
    result = SemanticVersion.from_s("1.1.")
    expect(result.major).to eq(0)
    expect(result.minor).to eq(0)
    expect(result.patch).to eq(0)
  end

  it "allows the major to be incremented" do
    result = SemanticVersion.from_s("1.1.1")
    result.increment_major
    expect(result.major).to eq(2)
    expect(result.minor).to eq(0)
    expect(result.patch).to eq(0)
  end

  it "allows the minor to be incremented" do
    result = SemanticVersion.from_s("1.1.1")
    result.increment_minor
    expect(result.major).to eq(1)
    expect(result.minor).to eq(2)
    expect(result.patch).to eq(0)
  end

  it "outputs as a string" do
    result = SemanticVersion.from_s("1.2.3")
    expect(result.to_s).to eq("1.2.3")
    expect(result.to_s(:partial)).to eq("1.2")
  end

end