require 'rails_helper'

describe UriV4 do
	
  it "can create a blank uri" do
    uri = UriV4.new({})
    expect(uri.to_s).to eq("")
    expect(uri.to_ref).to eq("")
  end
  
  it "can create a uri from a unique id" do
    id = Base64.strict_encode64("http://www.example.com/path1/path2#fragment")
    uri = UriV4.new(id: id)
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a uri, fragment" do
    uri = UriV4.new({uri: "http://www.example.com/path1/path2#fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a uri, no fragment, clear end separator" do
    uri = UriV4.new({uri: "http://www.example.com/path1/path2/"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2")
  end
  
  it "can create a uri from a namespace and fragment" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and fragment, separator" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2/", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace, identifier and version" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2/XXXXXX/V2")
  end

  it "allows the uri to be retrieved as a string" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2/XXXXXX/V2")
  end

  it "allows the uri to be retrieved as a ref" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/YYYYYY/V2>")
  end

  it "allows the uri to be retrieved as a hash" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.to_hash).to eq({ uri: "http://www.example.com/path1/path2/YYYYYY/V2"})
  end

  it "allows the namespace to be retrieved" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.namespace).to eq("http://www.example.com/path1/path2/YYYYYY/V2")
  end

  it "allows the fragment to be retrieved" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", fragment: "AAAAAAA"})
    expect(uri.fragment).to eq("AAAAAAA")
  end

  it "prevents fragments including invalid content" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", fragment: "AAAA?£-11aaa"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AAAA__-11aaa")
  end

  it "prevents identifers including invalid content, identifier" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "XXX@£$-_XXX", version: "1"})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/XXX___-_XXX/V1>")
  end

  it "path to be extended, no path existing" do
    uri = UriV4.new({uri: "http://www.example.com"})
    uri.extend_path("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/BBB>")
  end

  it "path to be extended" do
    uri = UriV4.new({uri: "http://www.example.com/path1/path2"})
    uri.extend_path("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/BBB>")
  end

  it "fragment to be extended, no fragment" do
    uri = UriV4.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    uri.extend_fragment("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/XXXXXX/V2#BBB>")
  end

  it "fragment to be extended" do
    uri = UriV4.new(uri: "http://www.example.com/path1/path2#XXX")
    uri.extend_fragment("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#XXX_BBB>")
  end
  
end