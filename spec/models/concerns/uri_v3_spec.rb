require 'rails_helper'

describe UriV3 do
	
  it "can create a blank uri" do
    uri = UriV3.new({})
    expect(uri.to_s).to eq("http://www.assero.co.uk/")
    expect(uri.to_ref).to eq("<http://www.assero.co.uk/>")
  end
  
  it "can create a uri from a unique id" do
    id = Base64.strict_encode64("http://www.example.com/path1/path2#fragment")
    uri = UriV3.new(id: id)
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a uri" do
    uri = UriV3.new({uri: "http://www.example.com/path1/path2#fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and fragment" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and CID components, no version" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX")
  end

  it "can create a uri from a namespace and CID components incl version" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX", :version => "1"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX-1")
  end

  it "allows the uri to be retrieved as a string" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXXXXX", :version => 1})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AA-ORG_XXXXXX-1")
  end

  it "allows the uri to be retrieved as a ref" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXXXXX-1>")
  end

  it "allows the uri to be retrieved as a hash" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.to_hash).to eq({ uri: "http://www.example.com/path1/path2#AA-ORG_XXXXXX-1"})
  end

  it "allows the namespace to be retrieved" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.namespace).to eq("http://www.example.com/path1/path2")
  end

  it "allows the id to be retrieved" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX XXX", :version => 1})
    expect(uri.fragment).to eq("AA-ORG_XXXXXX-1")
  end

  it "prevents fragments including invalid content" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", fragment: "AAAA?£-11aaa"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AAAA-11aaa")
  end

  it "prevents organization namea including invalid content" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG*&-", identifier: "XXX XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXXXXX-1>")
  end

  it "prevents identifers including invalid content" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX@£$-_XXX", :version => 1})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#AA-ORG_XXX_XXX-1>")
  end

  it "allows the prefix to be updated" do
    uri = UriV3.new({namespace: "http://www.example.com/path1/path2", prefix: "AA", org_name: "ORG", identifier: "XXX@£$-_XXX", :version => 1})
    uri.update_prefix("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#BBB-ORG_XXX_XXX-1>")
  end
  
end