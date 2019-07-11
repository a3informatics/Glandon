require 'rails_helper'

describe Uri do
	
  include TimeHelpers

  it "can create a blank args" do
    uri = Uri.new({})
    expect(uri.to_s).to eq("")
    expect(uri.to_ref).to eq("")
  end
  
  it "can create a uri from a unique id" do
    id = Base64.strict_encode64("http://www.example.com/path1/path2#fragment")
    uri = Uri.new(id: id)
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a prefixed uri I" do
    uri = Uri.new({uri: "isoC:fragment"})
    expect(uri.to_s).to eq("http://www.assero.co.uk/ISO11179Concepts#fragment")
  end
  
  it "can create a uri from a prefixed uri II" do
    uri = Uri.new({uri: "rdf:fragment"})
    expect(uri.to_s).to eq("http://www.w3.org/1999/02/22-rdf-syntax-ns#fragment")
  end
  
  it "can create a uri from namespace and fragment, character set issue" do
    uri = Uri.new({namespace: "http://www.w3.org/1999/02/22-rdf-syntax-ns", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.w3.org/1999/02/22-rdf-syntax-ns#fragment")
  end
  
  it "can create a uri from a uri" do
    uri = Uri.new({uri: "http://www.example.com/path1/path2#fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can handle a blank uri" do
    uri = Uri.new({uri: {}})
    expect(uri.to_s).to eq("")
  end
  
  it "can create a uri from a uri, no fragment, clear end separator" do
    uri = Uri.new({uri: "http://www.example.com/path1/path2/"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2")
  end
  
  it "can create a uri from a namespace and fragment" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace and fragment, separator" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2/", fragment: "fragment"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#fragment")
  end
  
  it "can create a uri from a namespace, identifier and version" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2/XXXXXX/V2")
  end

  it "can create a uri from an authority, identifier and version" do
    uri = Uri.new({authority: "www.example.com", identifier: "YYYYYY", version: 2})
    expect(uri.to_ref).to eq("<http://www.example.com/YYYYYY/V2>")
  end

  it "allows the uri to be retrieved as a string" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2/XXXXXX/V2")
  end

  it "allows the uri to be retrieved as a ref" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/YYYYYY/V2>")
  end

  it "allows the uri to be retrieved as a hash" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.to_h).to eq("http://www.example.com/path1/path2/YYYYYY/V2")
  end

  it "allows the uri to be retrieved in a prefixed form" do
    uri = Uri.new({uri: "isoC:fragment"})
    expect(uri.to_prefixed).to eq("isoC:fragment")
  end
  
  it "allows the namespace to be retrieved" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "YYYYYY", version: 2})
    expect(uri.namespace).to eq("http://www.example.com/path1/path2/YYYYYY/V2")
  end

  it "allows the fragment to be retrieved" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", fragment: "AAAAAAA"})
    expect(uri.fragment).to eq("AAAAAAA")
  end

  it "prevents fragments including invalid content" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", fragment: "AAAA?£-11aaa"})
    expect(uri.to_s).to eq("http://www.example.com/path1/path2#AAAA__-11aaa")
  end

  it "prevents namespace including invalid content" do
    uri = Uri.new({namespace: "http://www.example.com/path1/P?£$ath2", fragment: "AAAA"})
    expect(uri.to_s).to eq("http://www.example.com/path1/Path2#AAAA")
  end

  it "prevents identifers including invalid content, identifier" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "XXX@£$-_XXX", version: "1"})
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/XXX___-_XXX/V1>")
  end

  it "path to be extended, no path existing" do
    uri = Uri.new({uri: "http://www.example.com"})
    uri.extend_path("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/BBB>")
  end

  it "path to be extended" do
    uri = Uri.new({uri: "http://www.example.com/path1/path2"})
    uri.extend_path("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/BBB>")
  end

  it "fragment to be extended, no fragment" do
    uri = Uri.new({namespace: "http://www.example.com/path1/path2", identifier: "XXXXXX", version: 2})
    uri.extend_fragment("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2/XXXXXX/V2#BBB>")
  end

  it "fragment to be extended" do
    uri = Uri.new(uri: "http://www.example.com/path1/path2#XXX")
    uri.extend_fragment("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#XXX_BBB>")
  end

  it "fragment to be replaced" do
    uri = Uri.new(uri: "http://www.example.com/path1/path2#XXX")
    uri.replace_fragment("BBB")
    expect(uri.to_ref).to eq("<http://www.example.com/path1/path2#BBB>")
  end

  it "access to the namespace class" do
    namespaces_1 = Uri.namespaces
    namespaces_2 = Uri.new(uri: "http://www.example.com/path1/path2#XXX").namespaces
    expect(namespaces_1).to be_a Uri::Namespace
    expect(namespaces_2).to be_a Uri::Namespace
  end

  it "compares two URIs" do
    uri_1 = Uri.new({uri: "http://www.example.com/path1/path2#1"})
    uri_2 = Uri.new({uri: "http://www.example.com/path1/path2#2"})
    uri_3 = Uri.new({uri: "http://www.example.com/path1/path2#1"})
    expect(uri_1==uri_2).to eq(false)
    expect(uri_1==uri_3).to eq(true)
  end

  it "speed test" do
    timer_start
    (1..10000).each {|x| uri = Uri.new({uri: "http://www.example.com/path1/path2#1"})}
    timer_stop("10000 URI calls")
  end

end