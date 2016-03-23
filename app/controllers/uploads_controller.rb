class UploadsController < ApplicationController
  
    def index
      authorize Upload
    	@upload = Upload.new
    end
    
    def create
      authorize Upload
      post = Upload.save(params[:upload])
      redirect_to uploads_path
    end
  
end
