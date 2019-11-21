require 'rails_helper'

describe BreadcrumbsHelper do
  
  include DataHelpers


  describe "breadcrumb" do
    
    before :each do
      data_files = ["iso_namespace_fake.ttl"]
      load_files(schema_files, data_files)
    end
    
    it "single item" do
    	param = [{link: "/test", text: "Click"}]
    	helper.breadcrumb(param)
      expect(session[:breadcrumbs]).to eq("<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\" class=\"active\">Click</li></ol>")
    end
  
  	it "multiple items" do
    	param = [{link: "/test/1", text: "Click 1"}, {link: "/test/2", text: "Click 2"}]
    	helper.breadcrumb(param)
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/1\">Click 1</a></li><li id=\"breadcrumb_2\" " + 
      	"class=\"active\">Click 2</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end
  
  	it "first level" do
    	helper.first_level_breadcrumb({link: "/test", text: "First"})
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\" class=\"active\">First</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "second level" do
      item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "XXX"
      item.has_identifier.has_scope = IsoNamespace.all.first.id
    	helper.second_level_breadcrumb({link: "/test", text: "First"}, item.has_identifier.has_scope, item.has_identifier.identifier ) 
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test\">First</a></li><li " + 
      	"id=\"breadcrumb_2\" class=\"active\">BBB, XXX</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "third level" do
  		item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "BREADCRUMB"
      item.has_identifier.has_scope = IsoNamespace.new(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD Long", short_name: "DDD", authority: "www.ddd.com")
      item.has_identifier.semantic_version = "1.2.3"
    	helper.third_level_breadcrumb({link: "/test", text: "First"}, item, "/test/level2")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test\">First</a></li><li id=\"breadcrumb_2\"><a " + 
      	"href=\"/test/level2\">DDD, BREADCRUMB</a></li><li id=\"breadcrumb_3\" class=\"active\">V1.2.3</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "fourth level" do
  		item = IsoManagedV2.new
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.identifier = "BREADCRUMB"
      item.has_identifier.has_scope = IsoNamespace.new(uri: Uri.new(uri: "http://www.assero.co.uk/NS#DDD"), name: "DDD Long", short_name: "DDD", authority: "www.ddd.com")
      item.has_identifier.semantic_version = "1.2.3"
    	helper.fourth_level_breadcrumb({link: "/test", text: "First"}, item, "/test/level2", "/test/level3", "Action 4")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test\">First</a></li><li id=\"breadcrumb_2\"><a " + 
      	"href=\"/test/level2\">DDD, BREADCRUMB</a></li><li id=\"breadcrumb_3\"><a href=\"/test/level3\">V1.2.3</a></li><li " + 
      	"id=\"breadcrumb_4\" class=\"active\">Action 4</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  end 

end