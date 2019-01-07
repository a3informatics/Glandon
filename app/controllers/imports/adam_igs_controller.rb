class Imports::AdamIgsController < Imports::BaseController
  
  C_FILE_TYPE = "*.xlsx"
  
  def new
    super
    @next_version = AdamIg.next_version
  end

  def create
    model = AdamIg.import_params_valid?(the_params)
    if model.errors.empty?
      super
    else
      flash[:error] = model.errors.full_messages.to_sentence
      redirect_to request.referrer
    end
  end

private

  def the_params
    super([:version, :semantic_version, :date])
  end

end
