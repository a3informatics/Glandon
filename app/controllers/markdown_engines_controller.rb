class MarkdownEnginesController < ApplicationController

  before_action :authenticate_user!
  
  def index
    authorize MarkdownEngine
  end

  def create
    # TODO: This should really be a view operation not a create?
  	authorize MarkdownEngine, :view?
    render :json => { :result => MarkdownEngine::render(the_params[:markdown])}, :status => 200
  end

private

  def the_params
    params.require(:markdown_engine).permit(:markdown)
  end  

end
