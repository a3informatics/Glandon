# Import Model. Provides generic capabilities for imports.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
# @!attribute type
#   @return [String] the class type for STI operation
# @!attribute input_file
#   @return [String] the full path of the input file used in the import
# @!attribute output_file
#   @return [String] the full path of the input file created from running the import
# @!attribute error_file
#   @return [String] the full path of the error file created from running the import
# @!attribute success_path
#   @return [String] the path for a succesful import
# @!attribute error_path
#   @return [String] the path for an unseccesful import. Not currently used.
# @!attribute success
#   @return [Boolean] success flag
# @!attribute background_id
#   @return [Integer] foreign key to the background job
# @!attribute token_id
#   @return [Integer] foreign key to the tokens lock
# @!attribute auto_load
#   @return [Boolean] True: automatic load of import into database. False: No load into database
# @!attribute identifier
#   @return [String] the identifier of the item being imported
# @!attribute owner
#   @return [String] the owner of the item being imported
# @!attribute file_type
#   @return [Symbol] the file type of the import. Enumerated :excel, :odm: :als
class Import < ActiveRecord::Base

  enum file_type: [:excel, :odm, :als]

  belongs_to :background, required: true

  # List. List the available imports
  #
  # @return [Array] array of hash each containing an import entry.
  def self.list
    return Rails.configuration.imports[:imports].values
  end

  # Create. Create the import starting the execution of the background job.
  #
  # @params [Hash] params on optiona hash
  # @option [String] :filename the input filename 
  # @option [Boolean] :autoload autoload the import if all checks and processing pass if true.
  # @option [String] :filetype the file_type as an integer string
  # @return [Void] no return.
  def create(params)
    job = Background.create
    klass = self.configuration[:parent_klass]
    update_params(params, klass, job)
    self.update(input_file: file_list(params), auto_load: params[:auto_load], identifier: params[:identifier], 
      owner: owner_short_name(klass), background_id: job.id, file_type: params[:file_type].to_i)
    # @todo We need to lock the import somehow.
    job.start(self.description(params), "Starting ...") {self.import(params)} 
  rescue => e
    save_error_file({parent: self, children:[]})
    job.exception("An exception was detected during the import processes.", e)
  end  
  
  # Save Error File. Will save the errors in a YAML file as an array of errors 
  #
  # @param [Hash] objects a hash containing the object(s) being imported
  # @option objects [Object] :parent the parent object
  # @option objects [Object] :children array of children objects, may be empty
  # @return [Void] no return
  def save_error_file(objects)
    parent = merge_all_errors(objects)
    self.update(output_file: "", error_file: ImportFileHelpers.save_errors(parent.errors.full_messages, 
      "#{configuration[:import_type]}_#{self.id}_errors.yml"), success: false)
  end

  # Load Error File. 
  #
  # @return [Array] array of error messages. Will be empty if no file or import a success.
  def load_error_file
    return [] if self.error_file.blank?
    return [] if self.success
    return ImportFileHelpers.read_errors(self.error_file)
  end

  # Save Load File. Will save the import load file and load if auto load set
  #
  # @param [Hash] objects a hash containing the object(s) being imported
  # @option objects [Object] :parent the parent object
  # @option objects [Object] :children array of children objects, may be empty
  # @return [Void] no return
  def save_load_file(objects)
    parent = objects[:parent]
    path = TypePathManagement.history_url(parent.rdf_type, parent.identifier, parent.scopedIdentifier.namespace.id)
    sparql = parent.to_sparql_v2
    objects[:children].each {|c| c.to_sparql_v2(sparql)}
    filename = sparql.to_file
    response = CRUD.file(filename) if self.auto_load
    self.update(output_file: ImportFileHelpers.move(filename, "#{configuration[:import_type]}_#{self.id}_load.ttl"), 
      error_file: "", success: true, success_path: path)
  end

  # Save Result. Saves the result where there is no output file.
  #
  # @param [Object] object to be loaded. Should be error free.
  # @return [Void] no return
  def save_result(object)
    path = TypePathManagement.history_url(object.rdf_type, object.identifier, object.scopedIdentifier.namespace.id)
    self.update(output_file: "", error_file: "", success: true, success_path: path)
  end

  # Save Exception. Saves an exception
  #
  # @param [Exception] e the exception raised
  # @param [String] msg additinal message
  # @return [Void] no return
  def save_exception(e, msg)
    text = "#{msg}\n#{e}\n#{e.backtrace}"
    self.update(output_file: "", error_file: ImportFileHelpers.save_errors([text], "#{configuration[:import_type]}_#{self.id}_errors.yml"), success: false)
    ConsoleLogger::log(self.class::C_CLASS_NAME, __method__.to_s, text)
  end

  # Description. Formatted description of the import
  #
  # @param [Hash] params a hash of parameters
  # @option [String] :identifier the identifier of the item being imported
  # @return [String] the description
  def description(params)
    klass = self.configuration[:parent_klass]
    "#{configuration[:description]} from #{self.file_type_humanize}. Identifier: #{params[:identifier]}, Owner: #{owner_short_name(klass)}"
  end

  # Complete. Is the background job complete
  #
  # @return [Boolean] complete flag. True if complete, false otherwise
  def complete
    Background.find(self.background_id).complete
  rescue => e
    true
  end

  # File Type Humanize. Instance version
  #
  # @return [String] file type as a string
  def file_type_humanize
    self.class.file_type_humanize(Import.file_types[self.file_type])
  end

  # File Type Humanize. Class version
  #
  # @param [integer] the file type as an integer
  # @return [String] file type as a string
  def self.file_type_humanize(value)
    return %W(Excel ODM ALS)[value]
  end

private

  def owner_short_name(klass)
    klass.owner.ra_namespace.short_name
  end

  def file_list(params)
    params[:files].map{|x| File.basename(x)}.join(", ")
  end

  def update_params(params, klass, job)
    params[:job] = job
    params[:identifier] = klass.configuration[:identifier] if !params.key?(:identifier)
    params[:version_label] = params[:semantic_version] if configuration[:version_label] == :semantic_version
    params[:version_label] = params[:date] if configuration[:version_label] == :date
    params[:label] = configuration[:label]
  end

  def result_hash(object)
    return {parent: object, children: []}
  end
  
  def merge_all_errors(objects)
    parent = objects[:parent]
    objects[:children].each {|child| merge_errors(child, parent)}
    return parent
  end

  def merge_errors(from, to)
    return if from.errors.empty?
    from.errors.full_messages.each {|msg| to.errors[:base] << "#{from.label}: #{msg}"}
  end

  def locked?
    false
  end

  def to_file_type(value)
    Import.file_types[value.to_sym].to_i
  end

end