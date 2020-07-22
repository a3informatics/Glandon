# Managed Items Controller.
#
class ManagedItemsController < ApplicationController

  def index
    respond_to do |format|
      format.json do
        item = model_klass.unique
        item = @item.map{|x| x.reverse_merge!(history_path_for(x[:identifier], x[:scope_id]))}
        render json: {data: item}, status: 200
      end
      format.html
    end
  end

  def history
    respond_to do |format|
      format.json do
        results = []
        history_results = model_klass.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = model_klass.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = model_klass.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(model_klass, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
      format.html do
        @item = model_klass.latest({identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id])})
        @identifier = the_params[:identifier]
        @scope_id = the_params[:scope_id]
        @close_path = close_path_for
      end
    end
  end

end
  


