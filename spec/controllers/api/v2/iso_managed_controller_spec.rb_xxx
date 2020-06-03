require 'rails_helper'

describe Api::V2::IsoManagedController, type: :controller do

  include DataHelpers
  include ValidationHelpers

  def sub_dir
    return "controllers/api/v2/thesaurus_concepts"
  end

  def set_http_request
  	# JSON and username, password
  	request.env['HTTP_ACCEPT'] = "application/json"
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
  end

  describe "Read Access" do

    before :all do
    	clear_triple_store
    end
    
    after :all do
    end
    
    def set_http_request
  		# JSON and username, password
  		request.env['HTTP_ACCEPT'] = "application/json"
    	request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(ENV['api_username'],ENV['api_password'])
  	end

  	it "performs a search" do
  		expect(IsoManaged).to receive(:find_by_property).with({text: "Weekly"}).and_return([{type: :a}, {type: :b}]) 
      set_http_request
      get :index, {text: "Weekly"}
      results = JSON.parse(response.body)
      expect(results).to eq([{"type"=>"a"}, {"type"=>"b"}])
      expect(response.status).to eq 200
    end

    it "empty request, no search" do
      set_http_request
      get :index, {text: ""}
      expect(response.status).to eq 404
    end

  end

  describe "Unauthorized User" do
    
    it "rejects unauthorised user, index" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :index
      expect(response.status).to eq 401
    end

  end

end
