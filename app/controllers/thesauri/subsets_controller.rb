class Thesauri::SubsetsController < ManagedItemsController

  before_action :authenticate_user!

  def add
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(protect_from_bad_id(params))
    parent_mc = Thesaurus::ManagedConcept.find_minimum(subset.find_mc.id)
    source =  Thesaurus::ManagedConcept.find_minimum(parent_mc.subsets_links)
    return true unless check_lock_for_item(parent_mc)
    subset.add(the_params[:cli_ids], source)
    return true if lock_item_errors
    render json: { }, status: 200
  end

  def remove
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(protect_from_bad_id(params))
    parent_mc = Thesaurus::ManagedConcept.find_minimum(subset.find_mc.id)
    return true unless check_lock_for_item(parent_mc)
    sm = subset.remove(the_params[:member_id])
    return true if lock_item_errors
    render json: { }, status: 200
  end

  def remove_all
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(protect_from_bad_id(params))
    parent_mc = Thesaurus::ManagedConcept.find_minimum(subset.find_mc.id)
    return true unless check_lock_for_item(parent_mc)
    sm = subset.remove_all
    return true if lock_item_errors
    render json: { }, status: 200
  end


  def move_after
    authorize Thesaurus, :edit?
    subset = Thesaurus::Subset.find(protect_from_bad_id(params))
    parent_mc = Thesaurus::ManagedConcept.find_minimum(subset.find_mc.id)
    return true unless check_lock_for_item(parent_mc)
    sm = subset.move_after(the_params[:member_id], the_params[:after_id])
    return true if lock_item_errors
    render json: { }, status: 200
  end

  def list_children
    authorize Thesaurus, :show?
    subset = Thesaurus::Subset.find(protect_from_bad_id(params))
    lp = subset.list_pagination(the_params)
    render json: {data: lp, offset: params[:offset], count: lp.count}, status: 200
  end

  private

    def the_params
      params.require(:subset).permit(:member_id, :after_id, :offset, :count, :cli_ids => [])
    end

end
