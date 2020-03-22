require 'rails_helper'

describe UploadsController do

  include DataHelpers
  include UploadHelpers
  
  def sub_dir
    return "controllers/uploads"
  end

  describe "Authorized User" do

    login_content_admin

    it "index users" do
      get :index
      expect(assigns(:upload).to_json).to eq(Upload.new.to_json)
      expect(response).to render_template("index")
    end

    it 'uploads file' do
      file = Hash.new
      file['datafile'] = fixture_file_upload(upload_path(sub_dir, "upload.txt"), 'text/html')
      post :create, :upload => file
      expect(response).to redirect_to("/uploads")
    end

    it 'upload, file nil' do
      post :create, :upload => nil
      expect(response).to redirect_to("/uploads")
    end

  end

  describe "Unauthorized User" do

    it "index user" do
      get :index
      expect(response).to redirect_to("/users/sign_in")
    end

    it 'uploads file' do
      post :create
      expect(response).to redirect_to("/users/sign_in")
    end

  end

end
