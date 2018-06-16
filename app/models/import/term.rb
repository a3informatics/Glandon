class Import::Term

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  C_CLASS_NAME = self.name

  attr_reader :filename
  attr_reader :identifier

  def list(params)
    if odm?(params)
      odm = OdmXml.new(params[:filename])
      return odm.terminology.list
    else
      excel = TermExcel.new(params[:filename])
      return excel.list("SN") # @todo Bit naughty but will do for the moment
    end
  end

  def import(params)
    results = []
    uri = UriV2.new(uri: params[:uri])
    th = Thesaurus.find(uri.id, uri.namespace)
    if odm?(params)
      odm = OdmXml.new(params[:filename])
      return odm if !odm.errors.empty?
      results = odm.terminology.code_list(params[:identifier])
    else
      excel = TermExcel.new(params[:filename])
      return excel if !excel.errors.empty?
      results = excel.code_list(params[:identifier])
    end
    add_params(results[:code_list], th.namespace)
    cl = th.add_child(results[:code_list])
    return cl if !cl.errors.empty?
    results[:items].each do |cli| 
      add_params(cli, th.namespace)
      cli = cl.add_child(cli)
      cl.copy_errors(cli, "Item:")
    end
    return cl
  end  

  def add_params(params, namespace)
    params[:namespace] = namespace
    params[:type] = ThesaurusConcept::C_RDF_TYPE_URI.to_s
  end

private

  def odm?(params)
    params[:file_type].to_sym == :odm
  end

end

    