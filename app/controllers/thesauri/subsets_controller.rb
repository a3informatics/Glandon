class Thesauri::SubsetsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "ThesaurusConceptsController"

  def add
    authorize Thesaurus, :edit?
  byebug
    subset = Thesaurus::Subset.find(params[:id])
    sm = subset.add(the_params[:member_id])
    render json: {id: sm.uri.to_id}, status: 200
  end

  def remove
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find_minimum(params[:id])
    sm = subset.remove(the_params[:member_id])
    render json: {data: sm}, status: 200
  end

  def move_after
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find_minimum(params[:id])
    sm = subset.move_after(the_params[:member_id], the_params[:after_id])
    render json: { }, status: 200
  end

  private
    def the_params
      params.require(:subset).permit(:member_id, :after_id)
    end
  
end

