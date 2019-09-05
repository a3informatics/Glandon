# Import Rectangular. Import a rectangular excel structure
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::ChangeInstructions < Import

  C_CLASS_NAME = self.name

  # Import. Import the change instructions
  #
  # @param [Hash] params a parameter hash
  # @option params [URI] :previous_ct
  # @option params [URI] :current_cy
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @changes = []
    @previous_ct = Thesaurus.find_minimum(params[:previous_ct])
    @current_ct = Thesaurus.find_minimum(params[:current_ct])
    read_all_excel(params)
    objects = self.errors.empty? ? process_changes : []
    !self.errors.empty? || object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def self.configuration
    {
      description: "Import of CDISC Change Instructions",
      parent_klass: Import::ChangeInstructions::Instruction,
      import_type: :cdisc_change_instructions,
      reader_klass: Excel,
      sheet_name: :format,
      #version_label: :date,
    }
  end
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    self.class.configuration
  end

  def save_error_file(objects)
    objects.each {|c| merge_errors(c, self) if c.errors.any?}
    self.update(output_file: "", error_file: ImportFileHelpers.save_errors(self.errors.full_messages, 
      "#{configuration[:import_type]}_#{self.id}_errors.yml"), success: false)
  end

  # Save Load File. Will save the import load file and load if auto load set
  def save_load_file(objects)
    path = Rails.application.routes.url_helpers.thesauri_path(@current_ct)
    sparql = Sparql::Update.new()
    sparql.default_namespace(Uri.namespaces.namespace_from_prefix(:bo))
    objects.each do |c| 
      c.to_sparql(sparql, true)
    end
    filename = sparql.to_file
    response = CRUD.file(filename) if self.auto_load
    self.update(output_file: ImportFileHelpers.move(filename, "#{configuration[:import_type]}_#{self.id}_load.ttl"), 
      error_file: "", success: true, success_path: path)
  end

  # Format. Returns the key for the sheet info
  # 
  # @return [Symbol] the key
  def format(params)
    return :main
  end

private

  # Read all the Excel files
  def read_all_excel(params)
    params[:files].each do |file|
      reader = configuration[:reader_klass].new(file)
      merge_errors(reader, self)
      next if !reader.errors.empty?
      reader.check_and_process_sheet(configuration[:import_type], self.send(configuration[:sheet_name], params))
      merge_errors(reader, self)
      next if !reader.errors.empty?
      @changes += reader.engine.parent_set.map {|k,v| v}
    end
  end


  # Check no errors in the objects structure.
  def object_errors?(objects)
    objects.each {|c| return true if c.errors.any?}
    return false
  end

  # Process all the changes
  def process_changes
    results = []
    @changes.each_with_index do |change, index|
      ci = CrossReference::ChangeInstruction.new(ordinal: index + 1, description: change.description, semantic: "related terminology")
      ci.uri = ci.create_uri(@current_ct.uri)
      change.previous.each {|p| ci.add_previous(@previous_ct, p)}
      change.current.each {|p| ci.add_current(@current_ct, p)}
      results << ci
    end
    results
  end
  
end