# Managed Items Controller
#
# @author Clarisa Romero
# @since 3.2.0
class ManagedItemsController < ApplicationController

  def index
    respond_to do |format|
      format.json do
        item = model_klass.unique
        item = item.map{|x| x.reverse_merge!(history_path_for(x[:identifier], x[:scope_id]))}
        render json: {data: item}, status: 200
      end
      format.html
    end
  end

  def history
    respond_to do |format|
      format.html do
        result = model_klass.latest({identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id])})
        if result.nil?
          redirect_to close_path_for
        else
          @item = result
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
          @close_path = close_path_for
        end
      end
      format.json do
        results = []
        history_results = model_klass.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = model_klass.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = model_klass.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(model_klass, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

private

  # Lock for editing. Used for edit operations! :)
  def edit_lock(item)
    @edit = ManagedItemsController::Edit.new(item, current_user, flash)
    return true unless @edit.error?
    redirect_to request.referrer if request.format.html?
    render :json => {:errors => [@edit.lock.error]}, :status => 422 if request.format.json?
    false
  end

  # Lock item. Used for delete and similar operations
  def get_lock_for_item(item)
    @lock = ManagedItemsController::Lock.new(:get, item, current_user, flash)
    return true unless @lock.error?
    redirect_to request.referrer if request.format.html?
    render :json => {:errors => [@lock.error]}, :status => 422 if request.format.json?
    false
  end

  # Check item locked. Used for updates and similar
  def check_lock_for_item(item)
    @lock = ManagedItemsController::Lock.new(:keep, item, current_user, flash)
    return true unless @lock.error?
    redirect_to request.referrer if request.format.html?
    render :json => {:errors => [@lock.error]}, :status => 422 if request.format.json?
    false
  end

  def lock_item_errors
    return false if @lock.item.errors.empty?
    render :json => {:errors => @lock.item.errors.full_messages}, :status => 422
    true
  end

  def item_errors(item)
    return false if item.errors.empty?
    render :json => {:errors => item.errors.full_messages}, :status => 422
    true
  end

end