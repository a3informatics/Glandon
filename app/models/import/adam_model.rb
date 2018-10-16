class Import::AdamModel < Import

  C_CLASS_NAME = self.name
  C_IMPORT_DESC = "Import of ADaM Model"

  attr_reader :filename

  def import(params, job)
    #adam = AdamModelExcel.new(params[:filename])
    #object = adam.model(job)
    #adam.errors.empty? ? load_file(object, :adam_model) : error_file(adam, :adam_model)
    # @todo we need to unlock the import.
    job.end("Job complete")   
  rescue => e
    job.exception("An exception was detected the ADaM Model import processes.", e)
  end 
  #handle_asynchronously :import unless Rails.env.test?

end