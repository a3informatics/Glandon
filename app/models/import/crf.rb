# CRF Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::Crf < Import

  C_CLASS_NAME = self.name

  # List. List the available imports
  #
  # @option params [String] :fule_type the type of file being imported
  # @option params [Array] :files
  # @return [Array] array of hash each containing an import entry.
  def list(params)
    odm?(params[:file_type]) ? OdmXml::Forms.new(params[:files].first).list : AlsExcel.new(params[:files].first).list
  end

    # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :identifier the identifier
  # @option params [String] :fule_type the type of file being imported
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    model = odm?(params[:file_type]) ? OdmXml::Forms.new(params[:files].first) : AlsExcel.new(params[:files].first)
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

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    {
      description: "Import of CRF",
      parent_klass: ::Form,
      import_type: :form
    }
  end
  
private
  
  # ODM import?
  def odm?(file_type)
    file_type.to_i == Import.file_types["odm"]
  end

  # Do the import.
  def do_import(object)
    return object unless object.errors.empty?
    return Form.create_no_load(object.to_operation)
  end

end