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

  enum file_type: [:excel, :odm, :als, :api]

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
    save_error_file({parent: self, managed_children:[]})
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
    path = TypePathManagement.history_url_v2(parent)
    sparql = Sparql::Update.new()
    sparql.default_namespace(parent.uri.namespace)
    parent.to_sparql(sparql, true)
    objects[:managed_children].each do |c| 
      c.to_sparql(sparql, true)
    end
    objects[:tags].each do |c| 
      sparql.add({uri: c[:subject]}, {prefix: :isoC, fragment: "tagged"}, {uri: c[:object]})
    end
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
    path = TypePathManagement.history_url_v2(object)
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
    ConsoleLogger::log(self.class.name, __method__.to_s, text)
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
    return %W(Excel ODM ALS API)[value]
  end

  # API? Is the API file type being used?
  #
  # @return [Boolean] true if API, false otherwise
  def self.api?(params)
    return params[:file_type].to_i == Import.file_types[:api]
  end

  # Configuration. Sets the parameters for the import, class version
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {}
  end

  # # Configuration. Sets the parameters for the import, instance version
  # # 
  # # @return [Hash] the configuration hash
  # def configuration
  #   self.class.configuration
  # end

  # Raw Params Valid. Check the import parameters.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :type the import type
  # @option params [String] :version the version, integer
  # @option params [String] :date, a valid date
  # @option params [String] :files, at least one file
  # @option params [String] :semantic_version, a valid semantic version
  # @return [Errors] active record errors class
  def self.params_valid?(params)
    object = self.new
    FieldValidation::valid_version?(:version, params[:version], object)
    FieldValidation::valid_date?(:date, params[:date], object)
    FieldValidation::valid_files?(:files, params[:files], object) if !self.api?(params)
    FieldValidation::valid_semantic_version?(:semantic_version, params[:semantic_version], object)
    return object
  end

private

  # Get the owner short name
  def owner_short_name(klass)
    klass.owner.ra_namespace.short_name
  end

  # Return the file list
  def file_list(params)
    return "Using API" if self.class.api?(params)
    params[:files].map{|x| File.basename(x)}.join(", ")
  end

  # Update the import parameters
  def update_params(params, klass, job)
    params[:job] = job
    params[:identifier] = klass.identifier if !params.key?(:identifier)
    params[:version_label] = params[:semantic_version] if configuration[:version_label] == :semantic_version
    params[:version_label] = params[:date] if configuration[:version_label] == :date
    params[:label] = configuration[:label]
  end

  # Buid the result hash
  def result_hash(object)
    return {parent: object, managed_children: []}
  end
  
  # Merge all errors
  def merge_all_errors(objects)
    parent = objects[:parent]
    objects[:managed_children].each {|child| merge_errors(child, parent)}
    return parent
  end

  # Merge errors
  def merge_errors(from, to)
    return if from.errors.empty?
    from.errors.full_messages.each {|msg| to.errors[:base] << "#{from.label}: #{msg}"}
  end

  # Locked?
  def locked?
    false
  end

  # Get the file type
  def to_file_type(value)
    Import.file_types[value.to_sym].to_i
  end

end