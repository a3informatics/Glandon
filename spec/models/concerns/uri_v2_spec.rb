require 'rails_helper'

describe UriV2 do
	
  it "can create a blank uri" do
    uri = UriV2.new({})
    expect(uri.to_s).to eq("http://www.assero.co.uk/")
    expect(uri.to_ref).to eq("<http://www.assero.co.uk/>")
  end
  
  it "can create a uri from a uri" do
    uri = UriV2.new({uri: "http://www.example.com/path1/path2#fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and id" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", id: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and CID components, no version" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX")
  end

  it "can create a uri from a namespace and CID components incl version" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX", :version => "1"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX-1")
  end

  it "allows the uri to be retrieved as a string" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX", :version => 1})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX-1")
  end

  it "allows the uri to be retrieved as a ref" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXXXXX-1>")
  end

  it "allows the uri to be retrieved as JSON" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.to_json).to eq({ namespace: "http://www.example.com/path1/path2", id: "AA-ORG_XXXXXX-1"})
  end

  it "allows the namespace to be retrieved" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.namespace).to eq("http://www.example.com/path1/path2")
  end

  it "allows the id to be retrieved" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.id).to eq("AA-ORG_XXXXXX-1")
  end

  it "prevents fragments including invalid content" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", id: "AAAA?£-11aaa"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AAAA-11aaa")
  end

  it "prevents organization namea including invalid content" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG*&-", identifier: "XXX XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXXXXX-1>")
  end

  it "prevents identifers including invalid content" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX@£$-_XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXX_XXX-1>")
  end

  it "allows the prefix to be updated" do
    uri = UriV2.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX@£$-_XXX", :version => 1})
    uri.update_prefix("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#BBB-ORG_XXX_XXX-1>")
  end
  
end