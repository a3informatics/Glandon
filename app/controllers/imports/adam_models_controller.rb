# Imports ADaM Model Controller.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Imports::AdamModelsController < Imports::BaseController
  
private

  def the_params
    super([:version, :version_label, :date])
  end

end
