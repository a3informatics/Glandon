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

  	before :all do
      IsoHelpers.clear_cache
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    it "build an instance title for a managed item" do
  		item = Form.new
  		item.scopedIdentifier.version = 10
  		item.scopedIdentifier.semantic_version = "2.3.1"
  		item.registrationState.registrationStatus = "Standard"
  		item.label = "Blah"
  		item.scopedIdentifier.identifier = "IDENT"
	  	expect(instance_title("Title", item)).to eq("Title Blah <span class='text-tiny'>IDENT (V2.3.1, 10, Standard)</span>")
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
			expect(true_false_glyphicon(true)).to eq("<td class=\"text-center\"><span class=\"icon-ok text-secondary-clr\"/></td>")
			expect(true_false_glyphicon(false)).to eq("<td class=\"text-center\"><span class=\"icon-times text-accent-2\"/></td>")
		end

    it "true false cell" do
      expect(true_false_cell(true, :left)).to eq("<td class=\"text-left\"><span class=\"icon-ok text-secondary-clr\"/></td>")
      expect(true_false_cell(false, :right)).to eq("<td class=\"text-right\"><span class=\"icon-times text-accent-2\"/></td>")
      expect(true_false_cell(false, :center)).to eq("<td class=\"text-center\"><span class=\"icon-times text-accent-2\"/></td>")
    end

		it "column ordering" do
		  expect(column_order(1, :asc)).to eq("[[1, 'asc']]")
		  expect(column_order(2, :desc)).to eq("[[2, 'desc']]")
		  expect(column_order(3, :something)).to eq("[[3, 'asc']]")
		end

	end

end
