require 'rails_helper'

describe "CDISC Library API" do
	
	include DataHelpers

  before :all do
    clear_triple_store
  end

  def sub_dir
    return "models/concerns/rest/cdisc_library_api"
  end
    
  def send_request(url)
    headers = {"Accept" => "application/json"}
    response = Rest.send_request(url, :get, ENV["cdisc_library_api_username"], 
      ENV["cdisc_library_api_password"], "", headers)
    JSON.parse(response.body).deep_symbolize_keys
  end

  it "sends package list request" do
    response = send_request("https://library.cdisc.org/api/mdr/ct/packages")
    puts response
  end

  it "sends package list request" do
    result = Hash.new {|h,k| h[k] = [] }
  	response = send_request("https://library.cdisc.org/api/mdr/ct/packages")
    response[:_links][:packages].each do |source|
      date = source[:title].scan(/(\d\d\d\d-\d\d-\d\d)/).last.first
      package = source[:title].scan(/( \d+ )/).last.first.strip.to_i
      result[date] << {title: source[:title], date: date, package: package, href: source[:href]}
    end
    result = result.sort.to_h
    check_file_actual_expected(result, sub_dir, "package_list_expected_1.yaml", equate_method: :hash_equal)
    puts result
	end

  it "sends package request" do
    response = send_request("https://library.cdisc.org/api/mdr/ct/packages/protocolct-2018-06-29")
    puts response
  end

end