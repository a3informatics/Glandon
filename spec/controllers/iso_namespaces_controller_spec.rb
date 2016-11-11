require 'rails_helper'

describe IsoNamespacesController do

  include DataHelpers

  describe "GET #index" do
  	
    login_user
    puts "XXXXXX"
    
  	it "clears triple store and loads test data" do
      clear_triple_store
      load_test_file_into_triple_store("IsoNamespace.ttl")
    end
    
    it "assigns all namespaces" do
      results = Hash.new
      result = IsoNamespace.new
      result.id = "NS-AAA"
      result.namespace = "http://www.assero.co.uk/MDRItems"
      result.name = "AAA Long"
      result.shortName = "AAA"
      results["NS-AAA"] = result
      result = IsoNamespace.new
      result.id = "NS-BBB"
      result.namespace = "http://www.assero.co.uk/MDRItems"
      result.name = "BBB Long"
      result.shortName = "BBB"
      results["NS-BBB"] = result
  		controller.stub(:authenticate_user!)
      puts "2"
      controller.stub(:authorize)
      puts "3"
      get :index
      puts "3"
      expect(assigns(@namespaces)).to eq(results)
      #controller.stub(:verify_authorized)
  	end

  end

end