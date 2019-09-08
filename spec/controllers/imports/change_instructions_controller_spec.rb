require 'rails_helper'

describe Imports::ChangeInstructionsController do

  include DataHelpers
  include PublicFileHelpers
  
  describe "Authorized User" do
  	
    def sub_dir
      return "controllers/imports/change_instructions"
    end

    login_content_admin

    def test_files
      copy_file_to_public_files(sub_dir, "new_1.xml", "test")
      copy_file_to_public_files(sub_dir, "new_2.xml", "test")
      copy_file_to_public_files(sub_dir, "new_3.txt", "test")
      @file_1 = public_path("test", "new_1.xml").to_s
      @file_2 = public_path("test", "new_2.xml").to_s
      @file_3 = public_path("test", "new_3.txt").to_s
    end

    before :each do
      schema_files = 
      [
        "ISO11179Types.ttl", "ISO11179Identification.ttl", "ISO11179Registration.ttl", 
        "ISO11179Concepts.ttl", "BusinessOperational.ttl", "thesaurus.ttl"
      ]
      data_files = 
      [
        "iso_namespace_real.ttl", "iso_registration_authority_real.ttl",     
      ]
      load_files(schema_files, data_files)
      load_data_file_into_triple_store("cdisc/ct/CT_V1.ttl")
      load_data_file_into_triple_store("cdisc/ct/CT_V2.ttl")
      Token.delete_all
      delete_all_public_test_files
    end

    it "new, no files" do
      get :new, {imports: {file_type: "1"}}
      expect(assigns(:model)).to_not be_nil
      expect(assigns(:files)).to eq([])
      expect(assigns(:history).count).to eq(2)
      expect(assigns(:history)[0].uri).to eq(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(assigns(:history)[1].uri).to eq(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      expect(response).to render_template("new")
    end

    it "new, files" do
      test_files
      get :new, {imports: {file_type: "1"}}
      expect(assigns(:model)).to_not be_nil
      expect(assigns(:files)).to match_array([@file_1, @file_2])
      expect(assigns(:history).count).to eq(2)
      expect(assigns(:history)[0].uri).to eq(Uri.new(uri: "http://www.cdisc.org/CT/V2#TH"))
      expect(assigns(:history)[1].uri).to eq(Uri.new(uri: "http://www.cdisc.org/CT/V1#TH"))
      expect(response).to render_template("new")
    end

    it "allows a cross reference to be created, empty file" do
      request.env['HTTP_REFERER'] = 'http://example.com'
      post :create, {imports: { current_id: Uri.new(uri: "http://www.cdisc.org/CT/V2#TH") }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to('http://example.com')
    end

    it "allows a cross reference to be created, empty current id" do
      request.env['HTTP_REFERER'] = 'http://example.com'
      copy_file_to_public_files(sub_dir, "create_cross_reference_1.xlsx", "upload")
      filename = public_path("upload", "create_cross_reference_1.xlsx")
      post :create, {imports: { current_id: "", files: ["#{filename}"] }}
      expect(flash[:error]).to be_present
      expect(response).to redirect_to('http://example.com')
    end

    it "allows a cross reference to be created" do
      id = 1
      uri = Uri.new(uri: "http://www.cdisc.org/CT/V2#TH")
      copy_file_to_public_files(sub_dir, "create_cross_reference_1.xlsx", "upload")
      filename = public_path("upload", "create_cross_reference_1.xlsx")
      expect_any_instance_of(Import::ChangeInstruction).to receive(:create).with({"current_id"=>uri.to_id, "files"=>["#{filename}"]}) do |arg|
        arg.id = id
        arg.save
      end
      post :create, {imports: { current_id: uri.to_id, files: ["#{filename}"] }}
      expect(response).to redirect_to(import_path(id))
    end

  end

  describe "Reader User" do
    
    login_reader

    it "new" do
      get :new
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

    it "create" do
      post :create
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end