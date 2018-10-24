class Import::AdamModel < Import

  C_CLASS_NAME = self.name
  C_IMPORT_DESC = "Import of ADaM Model"

  attr_reader :filename

  def import(params, job)
    #adam = Excel::AdamModel.new(params[:filename])
    #object = adam.import(job)
    #object.errors.empty? ? save_load_file(object) : save_error_file(object)
    # @todo we need to unlock the import.
    job.end("Complete")   
  rescue => e
    msg = "An exception was detected during the ADaM model import processes."
    save_exception(e, msg)
    job.exception(msg, e)
  end 
  #handle_asynchronously :import unless Rails.env.test?

end