class Import < ActiveRecord::Base

  enum file_type: [:excel, :odm, :als]

  belongs_to :background, required: true

  # List. List the available imports
  #
  # @return [Array] array of hash each containing an import entry.
  def self.list
    return Rails.configuration.imports[:imports]
  end

  def create(params)
    job = Background.create
    self.update(input_file: params[:filename], auto_load: params[:auto_load], identifier: params[:identifier], 
      owner: self.class::C_IMPORT_OWNER, background_id: job.id, file_type: params[:file_type].to_i)
    # @todo We need to lock the import somehow.
    job.start(self.description, "Starting ...") {self.import(params, job)} 
  rescue => e
    job.exception("An exception was detected the import processes.", e)
  end  
  
  def save_error_file(object)
    self.update(output_file: "", error_file: ImportFileHelpers.save(object.errors.full_messages, 
      "#{self.class::C_IMPORT_TYPE}_#{self.id}_errors.yml"), success: false)
  end

  def load_error_file
    return [] if self.error_file.blank?
    return [] if self.success
    return ImportFileHelpers.read(self.error_file) 
  end

  def save_load_file(object)
    path = TypePathManagement.history_url(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    triples = object.to_sparql_v2
    response = CRUD.update(triples.to_s) if self.auto_load
    self.update(output_file: ImportFileHelpers.save(triples.to_s, "#{self.class::C_IMPORT_TYPE}_#{self.id}_load.ttl"), 
      error_file: "", success: true, success_path: path)
  end

  def save_result(object)
    path = TypePathManagement.history_url(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    self.update(output_file: ImportFileHelpers.save(triples.to_s, "#{self.class::C_IMPORT_TYPE}_#{self.id}_load.ttl"), 
      error_file: "", success: true, success_path: path)
  end

  def description
    "#{self.class::C_IMPORT_DESC} from #{self.file_type_humanize}. Identifier: #{self.identifier}, Owner: #{self.owner}"
  end

  def complete
    Background.find(self.background_id).complete
  rescue => e
    true
  end

  def file_type_humanize
    self.class.file_type_humanize(Import.file_types[self.file_type])
  end

  def self.file_type_humanize(value)
    return %W(Excel ODM ALS)[value]
  end

private

  def locked?
    false
  end

  def to_file_type(value)
    Import.file_types[value.to_sym].to_i
  end

end