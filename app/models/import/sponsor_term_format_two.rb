# Sponsor Term Format 2 Importer. Sanofi new code list format
#
# @author Dave Iberson-Hurst
# @since 2.39.0
class Import::SponsorTermFormatTwo < Import

  include Import::Utility
  include Import::STFOClasses

  C_V1 = "01/01/1900".to_datetime 
  C_V2 = "01/01/2100".to_datetime 
  C_FORMAT_MAP = [
    {range: (C_V1...C_V2), sheet: :version_1}]
  C_DEFAULT = :version_1

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    readers = read_all_sources(params)
    merge_reader_data(readers)
    objects = self.errors.empty? ? process_results : {parent: self, managed_children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects)
    # @todo we need to unlock the import.
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
  def configuration
    {
      description: "Import of New Sponsor Code List(s)",
      parent_klass: Import::STFOClasses::STFOThesaurus,
      reader_klass: Excel,
      import_type: :sponsor_term_format_two,
      format: :format,
      version_label: :date,
      label: "Controlled Terminology"
    }
  end

  # Get the format
  #
  # @param [Hash] params a set of parameters
  # @option [String] :date a day date as a string
  # @return [Symbol] the format as a symbol. Default to C_DEFAULT if non found.
  def format(params)
    result = C_FORMAT_MAP.select{|x| x[:range].cover?(Time.now.to_datetime)}
    return C_DEFAULT if result.empty?
    return result.first[:sheet]
  end

  # Save Load File. Will save the import load file and load if auto load set
  #
  # @param [Hash] objects a hash containing the object(s) being imported
  # @option objects [Object] :parent the parent object
  # @option objects [Object] :children array of children objects, may be empty
  # @return [Void] no return
  def save_load_file(objects)
byebug
    sparql = Sparql::Update.new()
    objects[:managed_children].each do |c|
      c.to_sparql(sparql, true)
    end
    filename = sparql.to_file
    response = CRUD.file(filename) if self.auto_load
    self.update(output_file: ImportFileHelpers.move(filename, "#{configuration[:import_type]}_#{self.id}_load.ttl"),
      error_file: "", success: true, success_path: "thesauri/managed_concept")
  end

private

  # Merge the parent sets. 
  def merge_reader_data(readers)
    readers.each do |reader|
      reader.engine.parent_set.each do |k, v|
        @parent_set[k] = v
        merge_errors(@parent_set[k], self)
      end
    end
  end

  # Process the results
  def process_results
    ordinal = 1
    filtered = []
    date = Time.now.strftime('%Y-%m-%d')
    @parent_set.each do |key, parent| 
      child_identifiers(parent)
      parent.set_import(identifier: Thesaurus::ManagedConcept.new_identifier, label: parent.label, 
        semantic_version: SemanticVersion.first, version_label: "", 
        version: IsoScopedIdentifierV2.first_version, date: date, ordinal: ordinal)
      filtered << parent
      ordinal += 1
    end
    {parent: self, managed_children: filtered, tags: []}
  end

  def child_identifiers(parent)
    parent.narrower.each {|c| c.identifier = Thesaurus::UnmanagedConcept.new_identifier}
  end

end