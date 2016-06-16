class MarkdownEnginesController < ApplicationController

  before_action :authenticate_user!
  
  def create
  	authorize MarkdownEngine
    render :json => { :result => MarkdownEngine::render(the_params[:markdown])}, :status => 200
  end

private

  def the_params
    params.require(:markdown_engine).permit(:markdown)
  end  

end
