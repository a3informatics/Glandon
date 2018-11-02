class Import::Crf < Import

  C_CLASS_NAME = self.name

  def list(params)
    odm?(params[:file_type]) ? OdmXml::Forms.new(params[:filename]).list : AlsExcel.new(params[:filename]).list
  end

  def import(params)
    model = odm?(params[:file_type]) ? OdmXml::Forms.new(params[:filename]) : AlsExcel.new(params[:filename])
    if model.errors.empty? 
      object = model.form(params[:identifier]) # , job) @todo progress
      object = do_import(object)
      object.errors.empty? ? save_load_file(result_hash(object)) : save_error_file(result_hash(object))
    else
      save_error_file(result_hash(model))
    end
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the CRF import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  def description
    "Import of CRF"
  end

  def owner
    IsoRegistrationAuthority.owner.namespace.name
  end

  def import_type
    :form
  end

private
  
  def odm?(file_type)
    file_type.to_i == Import.file_types["odm"]
  end

  def do_import(object)
    return object unless object.errors.empty?
    return Form.create_no_load(object.to_operation)
  end

end