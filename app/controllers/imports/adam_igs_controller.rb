class Imports::AdamIgsController < Imports::BaseController
  
  C_FILE_TYPE = "*.xlsx"
  
private

  def the_params
    super([:version, :version_label, :date])
  end

end
