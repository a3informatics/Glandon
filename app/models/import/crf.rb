class Import::Crf < Import

  C_CLASS_NAME = self.name
  C_IMPORT_DESC = "Import of form"
  C_IMPORT_OWNER = IsoRegistrationAuthority.owner.namespace.name
  C_IMPORT_TYPE = "form"

  #attr_reader :filename
  #attr_reader :identifier

  def list(params)
    odm?(params[:file_type]) ? OdmXml::Forms.new(params[:filename]).list : AlsExcel.new(params[:filename]).list
  end

  def import(params, job)
    model = odm?(params[:file_type]) ? OdmXml::Forms.new(params[:filename]) : AlsExcel.new(params[:filename])
    if model.errors.empty? 
      object = model.form(params[:identifier]) # , job) @todo progress
      object = do_import(object)
      object.errors.empty? ? save_load_file(object) : save_error_file(object)
    else
      save_error_file(model)
    end
    job.end("Complete")   
  rescue => e
    job.exception("An exception was detected during the form import processes.", e)
  end 
  #handle_asynchronously :import unless Rails.env.test?

private
  
  def odm?(file_type)
    file_type.to_i == Import.file_types["odm"]
  end

  def do_import(object)
    return object unless object.errors.empty?
    return Form.create_no_load(object.to_operation)
  end

end