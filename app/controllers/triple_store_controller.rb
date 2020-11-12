class TripleStoreController < ApplicationController

  before_action :authenticate_user!

  def show
  	authorize Dashboard, :view?
    @triples = TripleStore.find(protect_from_bad_id(params))
    @close_path = request.referer
  end

end
