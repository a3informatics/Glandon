class Import::Term < Import

  C_CLASS_NAME = self.name
  C_IMPORT_DESC = "Import of terminology"
  C_IMPORT_OWNER = IsoRegistrationAuthority.owner.namespace.name
  C_IMPORT_TYPE = "term"

  #attr_reader :filename
  #attr_reader :identifier

  def list(params)
    odm?(params[:file_type]) ? OdmXml::Terminology.new(params[:filename]).list : TermExcel.new(params[:filename]).list("SN")
    # @todo Bit naughty (the SN bit) but will do for the moment
  end

  def import(params, job)
    results = []
    uri = UriV2.new(uri: params[:uri])
    th = Thesaurus.find(uri.id, uri.namespace)
    model = odm?(params[:file_type]) ? OdmXml::Terminology.new(params[:filename]) : TermExcel.new(params[:filename])
    if model.errors.empty?
      results = model.code_list(params[:identifier])
      cl = add_cl(th, results)
      cl = add_cli(cl, results) if cl.errors.empty?
      cl.errors.empty? ? save_result(th) : save_error_file(cl) 
    else
      save_error_file(model)
    end
    job.end("Complete")   
  rescue => e
    msg = "An exception was detected during the terminology import processes."
    save_exception(e, msg)
    job.exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?


private

  def add_cl(parent, results)
    cl = empty_results(results)
    return cl if cl.errors.any?
    add_params(results[:code_list], parent.namespace)
    return parent.add_child(results[:code_list])
  end

  def empty_results(results)
    cl = ThesaurusConcept.new
    return cl if !results.empty?
    cl.errors.add(:base, "Failed to find the code list, possible identifier mismatch.")
    return cl
  end

  def add_cli(parent, results)
    results[:items].each do |cli| 
      add_params(cli, parent.namespace)
      cli = parent.add_child(cli)
    end
    return parent
  end

  def add_params(params, namespace)
    params[:namespace] = namespace
    params[:type] = ThesaurusConcept::C_RDF_TYPE_URI.to_s
  end

  def odm?(file_type)
    file_type.to_i == Import.file_types["odm"]
  end
  
end

    