require 'rails_helper'

describe Annotations::ChangeInstructionsController do

  include DataHelpers

  describe "Authorized User" do

    login_curator

    def sub_dir
      return "controllers/annotations/change_instructions"
    end

    def load_versions(range)
      range.each {|n| load_data_file_into_triple_store("cdisc/ct/CT_V#{n}.ttl")}
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl", "change_instructions_v53.ttl"]
      load_files(schema_files, data_files)
      load_versions(1..42)
    end

    it "create change instruction" do
      request.env['HTTP_ACCEPT'] = "application/json"
      post :create
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:edit_path]
      check_file_actual_expected(actual, sub_dir, "create_expected.yaml")
    end

    it "add references to a change instruction" do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
      uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
      item = Annotation::ChangeInstruction.create
      item = Annotation::ChangeInstruction.find(item.id)
      put :add_references, {:id => item.id, :change_instruction => {previous: [uri2.to_id], current: [uri3.to_id, uri4.to_id]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "remove reference" do
      request.env['HTTP_ACCEPT'] = "application/json"
      uri1 = Uri.new(uri: "http://www.cdisc.org/C96779/V26#C96779")
      uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
      uri3 = Uri.new(uri: "http://www.cdisc.org/C96779/V37#C96779")
      uri4 = Uri.new(uri: "http://www.cdisc.org/C96779/V40#C96779")
      item = Annotation::ChangeInstruction.create
      item = Annotation::ChangeInstruction.find(item.id)
      item.add_references(previous: [uri1.to_id, uri2.to_id], current: [uri3.to_id, uri4.to_id])
      put :remove_reference, {:id => item.id, :change_instruction => {concept_id: uri3.to_id, type: "current"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
    end

    it "returns the change instructions links" do
    uri1 = Uri.new(uri: "http://www.cdisc.org/C74456/V37#C74456_C32955")
    uri2 = Uri.new(uri: "http://www.cdisc.org/C96779/V33#C96779")
    item = Annotation::ChangeInstruction.create
    item.update(description: "D", reference: "R", semantic: "S")
    item = Annotation::ChangeInstruction.find(item.id)
    item.add_references(previous: [uri1.to_id], current: [uri2.to_id])
    item = Annotation::ChangeInstruction.find(item.id)
      # expected =
      # {
      #   :description=>"This term replaces term from the Microbiology Susceptibility TEST codelist. Per FDA guidance, for tests concerning 50% inhibition on microbial growth/replication, please use the newly released EC50 terms; for tests concerning 50% inhibition on microbial enzymatic activity, please use the newly released IC50 and IC95 terms.", 
      #   :previous=>
      #   [
      #     {
      #       :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw==", :identifier=>"C128687", :notation=>"MSTEST", :date=>"2017-06-30T00:00:00+00:00"}, 
      #       :child=>{:identifier=>"C116252", :notation=>"IC95 Reference Control Result"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjUy", 
      #       :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjUy?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjUzI1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw%3D%3D"}, 
      #       {
      #         :parent=>{:id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw==", :identifier=>"C128687", :notation=>"MSTEST", :date=>"2017-06-30T00:00:00+00:00"}, 
      #         :child=>{:identifier=>"C116248", :notation=>"IC50 Reference Control Result"}, :id=>"aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjQ4", 
      #         :show_path=>"/thesauri/unmanaged_concepts/aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNDkjQzEyODY4N19DMTE2MjQ4?unmanaged_concept%5Bcontext_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQ1QvVjUzI1RI&unmanaged_concept%5Bparent_id%5D=aHR0cDovL3d3dy5jZGlzYy5vcmcvQzEyODY4Ny9WNTIjQzEyODY4Nw%3D%3D"
      #       }
      #     ], 
      #     :current=>[]
      # }
      request.env['HTTP_ACCEPT'] = "application/json"
      get :show, {id: item.id}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      # expect(JSON.parse(response.body).deep_symbolize_keys[:data]).to hash_equal(expected)
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "get_data_expected.yaml", write_file: true)
    end

  end

end
