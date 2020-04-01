require 'rails_helper'

describe Annotations::ChangeInstructionsController do

  include DataHelpers

  describe "Authrorized User" do

    login_curator

    def sub_dir
      return "controllers/annotations/change_instructions"
    end

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..42)
    end

    it "add references to a change instruction" do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
      uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
      item = Annotation::ChangeInstruction.create(description: "D", reference: "R")
      item = Annotation::ChangeInstruction.find(item.id)
      put :add_references, {:id => item.id, :change_instruction => {previous: [uri2.to_id], current: [uri3.to_id, uri4.to_id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "add_references_expected_1.yaml")
    end

  end

end
