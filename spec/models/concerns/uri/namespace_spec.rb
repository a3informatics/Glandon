require 'rails_helper'

describe Uri::Namespace do
	
  before :each do
    @namespaces = Uri::Namespace.new
  end

	it "provides the optional set" do
  	expect(@namespaces.optional_namespaces).to eq(Rails.configuration.namespaces[:optional])
	end

  it "provides the required set" do
    expect(@namespaces.required_namespaces).to eq(Rails.configuration.namespaces[:required])
  end

  it "allows the prefix to be obtained for a namespace" do
    expect(@namespaces.prefix_from_namespace("http://www.assero.co.uk/BusinessDomain")).to eq(:bd)
    expect(@namespaces.prefix_from_namespace("http://www.assero.co.uk/BusinessCrossReference")).to eq(:bcr)
  end

  it "handles the error for namespace that does not exist" do
    expect(@namespaces.prefix_from_namespace("http://www.assero.co.uk/")).to eq(nil)
  end

  it "allows the namespace to be obtained for a prefix" do
    expect(@namespaces.namespace_from_prefix(:isoC)).to eq("http://www.assero.co.uk/ISO11179Concepts")
  end

  it "allows the namespace to be obtained for a prefix, protect from strings" do
    expect(@namespaces.namespace_from_prefix("isoC")).to eq("http://www.assero.co.uk/ISO11179Concepts")
  end

  it "handles the error for prefix that does not exist" do
    expect(@namespaces.namespace_from_prefix(:sss)).to eq(nil)
  end

  it "provides via the class as well" do
    expect(Uri.namespaces.namespace_from_prefix("isoC")).to eq("http://www.assero.co.uk/ISO11179Concepts")
    expect(Uri.namespaces.namespace_from_prefix(:sss)).to eq(nil)
  end

  it "required prefix" do
    expect(Uri.namespaces.required_prefix?("isoC")).to eq(false)
    expect(Uri.namespaces.required_prefix?("rdf")).to eq(true)
  end

  it "owl prefix" do
    expect(@namespaces.owl_prefix).to eq(:owl)
  end

end