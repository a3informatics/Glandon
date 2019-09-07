class Imports::ChangeInstructionsController < Imports::BaseController
  
  C_FILE_TYPE = "*.xlsx"
  
  def new
    super
    @history = Thesaurus.history(identifier: CdiscTerm::C_IDENTIFIER, scope: IsoRegistrationAuthority.cdisc_scope)
  end

  def create
    model = ImportErrors.import_params_valid?(the_params)
    if model.errors.empty?
      super
    else
      flash[:error] = model.errors.full_messages.to_sentence
      redirect_to request.referrer
    end
  end

private

  class ImportErrors
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
  
    attr_reader :errors

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end

    def self.import_params_valid?(params)
      object = self.new
      object.errors.add(:base, "A terminology version must be selected") if params[:current_id].blank?
      FieldValidation::valid_files?(:files, params[:files], object)
      return object
    end

  end
    
  def the_params
    super([:current_id])
  end

end
