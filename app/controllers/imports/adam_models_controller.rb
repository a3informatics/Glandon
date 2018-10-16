class Imports::AdamModelsController < Imports::BaseController
  
private

  def the_params
    super([:version, :version_label, :date])
  end

end
