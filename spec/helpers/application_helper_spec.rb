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
      item.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#A00001")
      item.has_state = IsoRegistrationStateV2.new
      item.has_state.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#RS_A00001")
      item.has_state.by_authority = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
      item.has_state.registration_status = "Standard"
      item.has_identifier = IsoScopedIdentifierV2.new
      item.has_identifier.uri = Uri.new(uri:"http://www.acme-pharma.com/A00001/V3#SI_A00001")
      item.has_identifier.identifier = "IDENT"
      item.has_identifier.semantic_version = "2.3.1"
      item.has_identifier.version = 10
  		item.label = "Blah"
	  	expect(instance_title("Title", item)).to eq("Title Blah <span class='text-tiny'>IDENT (V2.3.1, 10, Standard)</span>")
	  end

    it "bootstrap alert class" do
	  	expect(bootstrap_class_for("success")).to eq("alert-success")
	  	expect(bootstrap_class_for("error")).to eq("alert-danger")
	  	expect(bootstrap_class_for("alert")).to eq("alert-warning")
	  	expect(bootstrap_class_for("notice")).to eq("alert-info")
	  	expect(bootstrap_class_for("something")).to eq("something")
	  end

    it "difference glyphicon" do
    	data = {}
			data[:status] = :no_change
			expect(diff_glyphicon(data)).to eq("<td class=\"text-center\"><span class=\"glyphicon glyphicon-arrow-down text-success\"/></td>")
			data[:status] = :something_else
			expect(diff_glyphicon(data)).to eq("<td>#{data[:difference]}</td>")
		end

    it "true false glyphicon" do
			expect(true_false_glyphicon(true)).to eq("<td class=\"text-center\"><span class=\"text-normal icon-sel-filled text-link\"/></td>")
			expect(true_false_glyphicon(false)).to eq("<td class=\"text-center\"><span class=\"text-normal icon-times-circle text-accent-2\"/></td>")
		end

    it "true false cell" do
      expect(true_false_cell(true, :left)).to eq("<td class=\"text-left\"><span class=\"text-normal icon-sel-filled text-link\"/></td>")
      expect(true_false_cell(false, :right)).to eq("<td class=\"text-right\"><span class=\"text-normal icon-times-circle text-accent-2\"/></td>")
      expect(true_false_cell(false, :center)).to eq("<td class=\"text-center\"><span class=\"text-normal icon-times-circle text-accent-2\"/></td>")
    end

	end

end
