class NotepadsController < ApplicationController

    def index
        user_id = current_user.id
        @items = Notepad.where(user_id: user_id, note_type: 0).find_each
    end

    def index_term
        results = {}
        user_id = current_user.id
        @items = Notepad.where(user_id: user_id, note_type: 0).find_each
        results[:count] = @items.count
        results[:data] = []
        @items.each do |item|
            results[:data] << item
        end
        respond_to do |format|
            format.html
            format.json { render :json => results, :status => 200 }
        end
    end

	def create_term
		user_id = current_user.id
		@cli = CdiscCli.find(the_params[:item_id], the_params[:item_ns])
        if (@cli != nil)
        	Notepad.create :uri_id => @cli.id, :uri_ns => @cli.namespace, :identifier => @cli.identifier, 
        		:useful_1 => @cli.notation, :useful_2 => "", :user_id => user_id, :note_type => :term
        	# There must be a better way og handling note_type parameter (should be :term not 0)
        	@items = Notepad.where(user_id: user_id, note_type: 0).find_each
        		render :json => { :count => @items.count }, :status => 200
        else
        	errors = []
        	errors << "Failed to find code list item."
        	render :json => { :errors => errors }, :status => 422
        end
	end

	def destroy
		Notepad.delete(params[:id])
		redirect_to notepads_path
	end	

private

  	def the_params
    	params.require(:notepad).permit(:item_id, :item_ns, :identifier, :useful_1, :useful_2, :user_id, :note_type)
  	end  

end