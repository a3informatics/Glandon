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
    #params[:job].running("Running ...", 0)
    @parent_identifier = 1
    @child_identifier = 1
    @tags = []
    @parent_set = {}
    readers = read_all_sources(params)
    merge_reader_data(readers)
    #params[:job].running("File loaded", 50)
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

  # Raw Params Valid. Check the import parameters.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :type the import type
  # @option params [String] :files, at least one file
  # @return [Errors] active record errors class
  def self.params_valid?(params)
    object = self.new
    FieldValidation::valid_file?(:files, params[:files], object) if !self.api?(params)
    return object
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
    sparql = Sparql::Update.new()
    sparql.default_namespace(objects[:managed_children].first.uri.namespace)
    objects[:managed_children].each do |c|
      c.to_sparql(sparql, true)
    end
    filename = sparql.to_file
    response = CRUD.file(filename) if self.auto_load
    self.update(output_file: ImportFileHelpers.move(filename, "#{configuration[:import_type]}_#{self.id}_load.ttl"),
      error_file: "", success: true, success_path: "/thesauri/managed_concepts")
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
    results = validation_pass
    return results if failed_validation?(results)
    final_pass
  end

  # Process the results
  def validation_pass
    return {parent: self, managed_children: [], tags: []} if empty_set?
    filtered = []
    @parent_set.each do |key, parent|
      parent_child_tweaks(parent, false)
      parent.set_initial(parent.identifier)
      parent_child_valid?(parent)
      filtered << parent
    end
    {parent: self, managed_children: filtered, tags: []}
  end

  # Empty set, i.e. nothing to process
  def empty_set?
    return false if @parent_set.any?
    self.errors.add(:base, "Did not find any items to import")
    true
  end
    
  # Empty set, i.e. nothing to process
  def failed_validation?(results)
    return true if results[:parent].errors.any?
    results[:managed_children].each {|x| return true if x.errors.any?}
    false
  end
    
  # Process the results
  def final_pass
    filtered = []
    @parent_set.each do |key, parent|
      parent_child_tweaks(parent)
      parent.set_initial(parent.identifier)
      filtered << parent
    end
    {parent: self, managed_children: filtered, tags: []}
  end

  # Tweak parent and child. Set identifiers and labels
  def parent_child_tweaks(parent, final_pass=true)
    parent.identifier = parent_identifier(parent.identifier, final_pass) 
    parent.narrower.each do |c|
      c.identifier = child_identifier(c.identifier, final_pass) 
      c.label = c.preferred_term.label
    end
  end

  # Parent Identifier
  def parent_identifier(identifier, final_pass=true)
    final_pass && self.auto_load ? Thesaurus::ManagedConcept.new_identifier : local_parent_identifier(identifier)
  end

  # Child Identifier
  def child_identifier(identifier, final_pass=true)
    final_pass && self.auto_load ? Thesaurus::UnmanagedConcept.new_identifier : local_child_identifier(identifier)
  end

  # Local Parent Identifier
  def local_parent_identifier(identifier)
    return identifier unless identifier.blank?
    @parent_identifier += 1
    "P#{@parent_identifier}"
  end

  # Local Child Identifier
  def local_child_identifier(identifier)
    return identifier unless identifier.blank?
    @child_identifier += 1
    "C#{@child_identifier}"
  end

  # Check valid
  def parent_child_valid?(parent)
    result = true
    parent.narrower.each do |c| 
      next if c.valid?
      result = false
      merge_child_errors(c, parent)
    end
    result = result && parent.valid? # Parent valid
    result = result && parent.valid_children? # Parent valid
    result
  end

  # Merge errors
  def merge_child_errors(from, to)
    return if from.errors.empty?
    from.errors.full_messages.each {|msg| to.errors[:base] << "#{from.identifier}: #{msg}"}
  end

end
