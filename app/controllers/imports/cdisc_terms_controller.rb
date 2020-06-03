class Imports::CdiscTermsController < Imports::BaseController
  
  C_FILE_TYPE = "*.xlsx"
  
  def new
    super
    @next_version = CdiscTerm.next_version
  end

  def create
    model = Import.params_valid?(the_params)
    if model.errors.empty?
      super
    else
      flash[:error] = model.errors.full_messages.to_sentence
      redirect_to request.referrer
    end
  end

private

  def the_params
    super([:version, :semantic_version, :date, :file_type])
  end

end
