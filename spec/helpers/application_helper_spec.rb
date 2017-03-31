require 'rails_helper'

describe ApplicationHelper do
  
  describe "utilities" do

  	class Test
  		attr_accessor :label, :current
  		def current?
  			return current
  		end
  	end

  	def new_test(label, current)
  		object = Test.new
  		object.label = label
  		object.current = current
  		return object
  	end

  	it "bootstrap alert class" do
	  	expect(bootstrap_class_for("success")).to eq("alert-success")
	  	expect(bootstrap_class_for("error")).to eq("alert-danger")
	  	expect(bootstrap_class_for("alert")).to eq("alert-warning")
	  	expect(bootstrap_class_for("notice")).to eq("alert-info")
	  	expect(bootstrap_class_for("something")).to eq("something")
	  end

    it "current items, I" do
    	test1 = new_test("1", true)
    	test2 = new_test("2", false)
    	test3 = new_test("3", false)
    	test4 = new_test("4", false)
    	items = [test1, test2, test3, test4]
    	result = get_current_item(items)
			expect(result.label).to eq("1")
	  end

    it "current items, II" do
    	test1 = new_test("1", true)
    	test2 = new_test("2", false)
    	test3 = new_test("3", true)
    	test4 = new_test("4", false)
    	items = [test1, test2, test3, test4]
    	result = get_current_item(items)
			expect(result).to eq(nil)
	  end

    it "current items, III" do
    	test1 = new_test("1", false)
    	test2 = new_test("2", false)
    	test3 = new_test("3", false)
    	test4 = new_test("4", false)
    	items = [test1, test2, test3, test4]
    	result = get_current_item(items)
			expect(result).to eq(nil)
	  end

    it "difference glyphicon" do
    	data = {}
			data[:status] = :no_change
			expect(diff_glyphicon(data)).to eq("<td class=\"text-center\"><span class=\"glyphicon glyphicon-arrow-down text-success\"/></td>")
			data[:status] = :something_else
			expect(diff_glyphicon(data)).to eq("<td>#{data[:difference]}</td>")
		end

    it "true false glyphicon" do
			expect(true_false_glyphicon(true)).to eq("<td class=\"text-center\"><span class=\"glyphicon glyphicon-ok text-success\"/></td>")
			expect(true_false_glyphicon(false)).to eq("<td class=\"text-center\"><span class=\"glyphicon glyphicon-remove text-danger\"/></td>")
		end

		it "column ordering" do
		  expect(column_order(1, :asc)).to eq("[[1, 'asc']]")
		  expect(column_order(2, :desc)).to eq("[[2, 'desc']]")
		  expect(column_order(3, :something)).to eq("[[3, 'asc']]")
		end
	
	end

  describe "breadcrumb" do
    
    it "singe item" do
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
  
  	it "top level" do
    	helper.top_level_breadcrumb("Top")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\" class=\"active\">Top</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "second level" do
    	helper.second_level_breadcrumb("Top", "/test/top", "2nd Level")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/top\">Top</a></li><li " + 
      	"id=\"breadcrumb_2\" class=\"active\">2nd Level</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "third level" do
    	helper.third_level_breadcrumb("Top", "/test/top", "2nd Level", "/test/level2", "3rd Level")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/top\">Top</a></li><li id=\"breadcrumb_2\">" +
      	"<a href=\"/test/level2\">2nd Level</a></li><li id=\"breadcrumb_3\" class=\"active\">3rd Level</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "fourth level" do
    	helper.fourth_level_breadcrumb("Top", "/test/top", "2nd Level", "/test/level2", "3rd Level", "/test/level3", "4th Level")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/top\">Top</a></li><li id=\"breadcrumb_2\">" +
      	"<a href=\"/test/level2\">2nd Level</a></li><li id=\"breadcrumb_3\"><a href=\"/test/level3\">3rd Level</a></li><li id=\"breadcrumb_4\" " + 
      	"class=\"active\">4th Level</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "third level, managed item" do
  		mi = IsoManaged.new
  		mi.scopedIdentifier.identifier = "BREADCRUMB"
  		mi.scopedIdentifier.semantic_version = "1.2.3"
    	helper.third_level_managed_item_breadcrumb(mi, "Top", "/test/top", "/test/level2", "Action 3")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/top\">Top</a></li><li id=\"breadcrumb_2\"><a " + 
      	"href=\"/test/level2\">BREADCRUMB</a></li><li id=\"breadcrumb_3\" class=\"active\">Action 3 V1.2.3</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  	it "fourth level, managed item" do
  		mi = IsoManaged.new
  		mi.scopedIdentifier.identifier = "BREADCRUMB"
  		mi.scopedIdentifier.semantic_version = "1.2.3"
    	helper.fourth_level_managed_item_breadcrumb(mi, "Top", "/test/top", "/test/level2", "Action 3", "/test/level3", "Action 4")
      expected = "<ol class=\"breadcrumb\"><li id=\"breadcrumb_1\"><a href=\"/test/top\">Top</a></li><li id=\"breadcrumb_2\"><a " + 
      	"href=\"/test/level2\">BREADCRUMB</a></li><li id=\"breadcrumb_3\"><a href=\"/test/level3\">Action 3 V1.2.3</a></li><li " + 
      	"id=\"breadcrumb_4\" class=\"active\">Action 4</li></ol>"
      expect(session[:breadcrumbs]).to eq(expected)
    end

  end 

end