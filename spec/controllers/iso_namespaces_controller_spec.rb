require 'rails_helper'

describe IsoNamespacesController do

  describe "GET #index" do
  	
  	results = Hash.new
    before do
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
      #IsoNamespace.stub(:all).and_return(results)
      expect(IsoNamespace).to receive(:all).and_return(results)
    end

    login_user
    puts "XXXXXX"
    it "assigns all namespaces" do
  		controller.stub(:authenticate_user!)
      puts "XXXXXX22222"
      #controller.stub(:authorize)
      get :index
      #expect(IsoNamespace).to receive(:all).and_return(results)
      expect(assigns(:namespaces)).to eq results
  	end

  end

end