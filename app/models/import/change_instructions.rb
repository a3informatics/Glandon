# Import Rectangular. Import a rectangular excel structure
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::ChangeInstructions < Import

  @changes = []

  # Import. Import the change instructions
  #
  # @param [Hash] params a parameter hash
  # @option params [URI] :previous_ct
  # @option params [URI] :current_cy
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    previous_ct = Thesaurus.find_minimum(params[:previous_ct])
    current_ct = Thesaurus.find_minimum(params[:current_ct])
    read_all_excel(params)
    objects = self.errors.empty? ? process_changes(previous_ct, current_ct) : [self]
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
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
      import_type: :cdisc_change_instructions
    }
  end
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    self.class.configuration
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
      @changes = @changes + reader.engine.parent_set
    end
  end

  # Process all the changes
  def process_changes(previous_ct, current_ct)
    results = []
    @changes.each do |change|
      ci = CrossReference::ChangeInstruction.new
      change.previous.each {|p| ci.add_previous(previous_ct, x)}
      change.current.each {|p| ci.add_current(current_ct, x)}
      results << ci
    end
  end
  
end