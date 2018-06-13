class Import::Odm

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  C_CLASS_NAME = self.name

  attr_reader :filename
  attr_reader :identifier

  def list(params)
    odm = OdmXml.new(params[:filename])
    return odm.list
  end

  def import(params)
    odm = OdmXml.new(params[:filename])
    object = odm.form(params[:identifier])
    return odm if !odm.errors.empty?
    object = Form.create(object.to_operation)
    return object
    #job = Background.create
    #importer = importer.new
    #job.start("Load database", "Starting load ...") { importer.import(job, params) }
    #return job
  end  

=begin
  class Importer
    
    def import(job, params)
      job.running("Loading ALS file ...", 25)
      als = OdmXml.new(params[:filename])
      job.running("Loading form ...", 50)
      object = als.form(params[:identifier])
      if als.errors.empty?
        object = Form.create(object.to_operation)
        if object.errors.empty?
          job.end("Form has been loaded.")
        else
          job.end("Form load failed. Errors: #{object.errors.full_messages.to_sentence}")
        end
      else
        job.end("Form load failed. Errors: #{als.errors.full_messages.to_sentence}")
      end
    rescue => e
      job.end("An exception was detected during form load.\nDetails: #{e}\n#{e.backtrace}")    
    end  
    #handle_asynchronously :load unless Rails.env.test?
  
  end
=end

end

    