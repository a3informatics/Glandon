class Thesauri::SubsetsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "ThesaurusConceptsController"

  def add
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(params[:id])
    if check_token_valid? (subset)
      sm = subset.add(the_params[:cli_ids])
      render json: {data: " "}, status: 200 and return
    end
  end

  def remove
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(params[:id])
    if check_token_valid? (subset)
      sm = subset.remove(the_params[:member_id])
      render json: {data: subset.uri.to_id}, status: 200 and return
    end
  end

  def remove_all
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(params[:id])
    if check_token_valid? (subset)
      sm = subset.remove_all
      render json: {data: " "}, status: 200
    end
  end


  def move_after
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(params[:id])
    if check_token_valid? (subset)
      sm = subset.move_after(the_params[:member_id], the_params[:after_id])
      render json: { }, status: 200 and return
    end
  end

  def list_children
    authorize Thesaurus, :show?
    subset = Thesaurus::Subset.find(params[:id])
    lp = subset.list_pagination(params)
    render json: {data: lp, offset: params[:offset] , count: lp.count }, status: 200
  end

  private
    def the_params
      params.require(:subset).permit(:member_id, :after_id, :cli_ids => [])
    end

    def check_token_valid?(subset)
      parent_mc = Thesaurus::ManagedConcept.find_minimum(subset.find_mc.id)
      token = Token.find_token(parent_mc, current_user)
      if token.nil?
        render :json => {:errors => ["The edit lock has timed out."] }, :status => 422
        false
      else
        true
      end
    end

end
