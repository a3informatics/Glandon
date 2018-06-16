class Import::Odm

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  C_CLASS_NAME = self.name

  attr_reader :filename
  attr_reader :identifier

  # List. List the forms
  # 
  # @param [Hash] params
  # @option params [String] :filename the filename, full path.
  # @return [Array] array of form entries, each a hash
  def list(params)
    odm = OdmXml.new(params[:filename])
    return odm.forms.list
  end

  # Import. Importa s specified form
  # 
  # @param [Hash] params
  # @option params [String] :filename the filename, full path.
  # @option params [String] :identifier the form identifier.
  # @return [Form] the form object
  def import(params)
    odm = OdmXml.new(params[:filename])
    object = odm.forms.form(params[:identifier])
    return odm if !odm.errors.empty?
    object = Form.create(object.to_operation)
    return object
  end  

end

    