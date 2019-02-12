require 'rails_helper'

describe Sparql::Namespace do
	
  include Sparql::Namespace

	it "provides the optional set" do
  	expect(optional_namespaces).to eq(Rails.configuration.namespaces[:optional])
	end

  it "provides the required set" do
    expect(required_namespaces).to eq(Rails.configuration.namespaces[:required])
  end

  it "allows the prefix to be obtained for a namespace" do
    expect(prefix_from_namespace("http://www.assero.co.uk/BusinessDomain")).to eq(:bd)
    expect(prefix_from_namespace("http://www.assero.co.uk/BusinessCrossReference")).to eq(:bcr)
  end

  it "handles the error for namespace that does not exist" do
    expect(prefix_from_namespace("http://www.assero.co.uk/")).to eq(nil)
  end

  it "allows the namespace to be obtained for a prefix" do
    expect(namespace_from_prefix(:isoC)).to eq("http://www.assero.co.uk/ISO11179Concepts")
  end

  it "handles the error for prefix that does not exist" do
    expect(namespace_from_prefix(:sss)).to eq(nil)
  end

end