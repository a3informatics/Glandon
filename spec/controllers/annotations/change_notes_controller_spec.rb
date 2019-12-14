require 'rails_helper'

describe Annotations::ChangeNotesController do

  include DataHelpers
  include ChangeNoteHelpers

  describe "Authrorized User" do

    login_curator

    def sub_dir
      return "controllers/annotations/change_notes"
    end

    before :each do
      data_files = ["iso_namespace_fake.ttl", "iso_registration_authority_fake.ttl"]
      load_files(schema_files, data_files)
    end

    it "update a change note" do
      request.env['HTTP_ACCEPT'] = "application/json"
      item = create_change_note("UR", "D", "R", "1234-5678-9012-3456")
      put :update, {:id => item.id, :change_note => {:reference => "Updated Ref", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      check_file_actual_expected(actual, sub_dir, "update_expected_1.yaml")
    end

    it "update a node, errors" do
      request.env['HTTP_ACCEPT'] = "application/json"
      item = create_change_note("UR", "D", "R", "1234-5678-9012-3456")
      put :update, {:id => item.id, :change_note => {:reference => "Updated Ref±±±", :description => "Updated Description"}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("400")
      actual = JSON.parse(response.body).deep_symbolize_keys[:data]
      errors = JSON.parse(response.body).deep_symbolize_keys[:errors]
      expect(errors).to eq(["Reference contains invalid characters"])
      check_file_actual_expected(actual, sub_dir, "update_expected_2.yaml")
    end

    it "allows a node to be destroyed" do
      request.env['HTTP_ACCEPT'] = "application/json"
      allow(Time).to receive(:now).and_return(Time.parse("Jan 1 12:00:00 2000"))
      allow(SecureRandom).to receive(:uuid).and_return("1234-5678-9012-3456")
      cn_1 = Annotation::ChangeNote.create(user_reference: "UR1", description: "D2", reference: "R2")
      or_1 = OperationalReferenceV3.create({reference: nil, context: nil}, cn_1)
      cn_1.current << or_1
      cn_1.save
      delete :destroy, :id => cn_1.id
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect{Annotation::ChangeNote.find(cn_1.uri)}.to raise_error(Errors::NotFoundError, "Failed to find http://www.assero.co.uk/CN#1234-5678-9012-3456 in Annotation::ChangeNote.")
    end

  end

  describe "Unauthorized User" do

    it "add a chnage note" do
      put :update, {id: "aaa"}
      expect(response).to redirect_to("/users/sign_in")
    end

    it "destroy a change note" do
      put :destroy, {id: "aaa"}
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
