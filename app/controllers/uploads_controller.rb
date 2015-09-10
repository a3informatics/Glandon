class UploadsController < ApplicationController
  
    def index
       @upload = Upload.new
    end
    
    def create
      post = Upload.save(params[:upload])
      #render :text => "File has been uploaded successfully"
      redirect_to uploads_path
    end
  
end
