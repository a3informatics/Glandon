class Import::Term

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  C_CLASS_NAME = self.name

  attr_reader :filename
  attr_reader :identifier

  def list(params)
    excel = TermExcel.new(params[:filename])
    return excel.list("SN") # Bit naughty but will do for the moment
  end

  def import(params)
    results = []
    uri = UriV2.new(uri: params[:uri])
    th = Thesaurus.find(uri.id, uri.namespace)
    excel = TermExcel.new(params[:filename])
    return term if !excel.errors.empty?
    results = excel.code_list(params[:identifier])
    add_params(results[:code_list], th.namespace)
    cl = th.add_child(results[:code_list])
    return cl if !cl.errors.empty?
    results[:items].each do |cli| 
      add_params(cli, th.namespace)
      cli = cl.add_child(cli)
      cl.copy_errors(cli, "Item:")
    end
    return cl
    #job = Background.create
    #importer = importer.new
    #job.start("Load database", "Starting load ...") { importer.import(job, params) }
    #return job
  end  

  def add_params(params, namespace)
    params[:namespace] = namespace
    params[:type] = ThesaurusConcept::C_RDF_TYPE_URI.to_s
  end

=begin
  class Importer
    
    def import(job, params)
    rescue => e
      job.end("An exception was detected during form load.\nDetails: #{e}\n#{e.backtrace}")    
    end  
    #handle_asynchronously :load unless Rails.env.test?
  
  end
=end

end

    