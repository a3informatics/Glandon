require 'rails_helper'

describe IsoNamespace do
	it "is valid with a id, namespace, name and shortName" do
		namespace = IsoNamespace.new()
		expect(namespace).to be_valid
	end
	it "is invalid without a id"
	it "is invalid without a namespace"
	it "is invalid without an name"
	it "is invalid without an shortName"
	it "returns a namespace object"
end