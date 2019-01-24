require 'rails_helper'

describe Imports::TermsController do

  include DataHelpers
  include PublicFileHelpers
  
  describe "Authorized User" do
    
    def sub_dir
      return "controllers/imports/terms"
    end

    login_content_admin

    def test_files
      copy_file_to_public_files(sub_dir, "new_1.xml", "test")
      copy_file_to_public_files(sub_dir, "new_2.xml", "test")
      copy_file_to_public_files(sub_dir, "new_3.txt", "test")
      copy_file_to_public_files(sub_dir, "new_4.xlsx", "test")
      @file_1 = public_path("test", "new_1.xml").to_s
      @file_2 = public_path("test", "new_2.xml").to_s
      @file_3 = public_path("test", "new_3.txt").to_s
      @file_4 = public_path("test", "new_4.xlsx").to_s
    end

    before :each do
      clear_triple_store
      Token.delete_all
      delete_all_public_test_files
    end

    it "new, no files" do
      get :new, {imports: {file_type: "1"}}
      expect(assigns(:model)).to_not be_nil
      expect(assigns(:files)).to eq([])
      expect(response.code).to eq("200")
      expect(response).to render_template("new")
    end

    it "new, files" do
      test_files
      get :new, {imports: {file_type: "1"}}
      expect(assigns(:model)).to_not be_nil
      expect(assigns(:files)).to match_array([@file_1, @file_2])
      expect(response.code).to eq("200")
      expect(response).to render_template("new")
      delete_all_public_test_files
    end

    it "items" do
      test_files
      request.env['HTTP_ACCEPT'] = "application/json"
      expected = [{something: "X"}, {something: "Y"}]
      expect_any_instance_of(Import::Term).to receive(:list).and_return(expected)
      expected.each {|x| x[:filename] = @file_1}
      get :items, {imports: {file_type: 1, files: [@file_1]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"data\":#{expected.to_json}}")
    end

    it "items, no params" do
      request.env['HTTP_ACCEPT'] = "application/json"
      get :items, {imports: {}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"data\":[]}")
    end

    it "create, json request" do
      request.env['HTTP_ACCEPT'] = "application/json"
      expect_any_instance_of(Import::Term).to receive(:create)
      post :create, {imports: {identifier: "AAA", files: [@file_1]}}
      expect(response.content_type).to eq("application/json")
      expect(response.code).to eq("200")
      expect(response.body).to eq("{\"data\":[]}")
    end

    it "create, http request" do
      id = 1 
      expect_any_instance_of(Import::Term).to receive(:create) do |arg|
        arg.id = id
        arg.save
      end
      post :create, {imports: {identifier: "AAA", files: [@file_1]}}
      expect(response).to redirect_to(import_path(id))
    end

  end

  describe "Reader User" do
    
    login_reader

    it "new" do
      get :new
      expect(response).to redirect_to("/")
    end

    it "items" do
      delete :items
      expect(response).to redirect_to("/")
    end

    it "create" do
      delete :create, {imports: {identifier: "AAA", filename: @file_1}}
      expect(response).to redirect_to("/")
    end

  end 
    
  describe "Unauthorized User" do
    
    it "new" do
      get :new
      expect(response).to redirect_to("/users/sign_in")
    end

    it "items" do
      get :items
      expect(response).to redirect_to("/users/sign_in")
    end

    it "create" do
      post :create
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end