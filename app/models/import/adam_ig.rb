# Adam IG Importer
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::AdamIg < Import

  include Import::Utility
  
  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    {
      description: "Import of ADaM Implementation Guide",
      parent_klass: ::AdamIg,
      reader_klass: Excel,
      import_type: :cdisc_adam_ig,
      format: :format,
      version_label: :semantic_version,
      label: "ADaM Implementation Guide"
    }
  end

  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :semantic_version the semantic version
  # @option params [String] :version_label the version label
  # @option params [String] :version the version
  # @option params [String] :date the date of issue
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @tags = []
    @parent_set = {}
    params[:identifier] = ::AdamIg.identifier
    results = read_and_process(params) if self.errors.empty?
    objects = self.errors.empty? ? process_results(results) : {parent: self, managed_children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  # Format. Returns the key for the sheet info
  # 
  # @return [Symbol] the key
  def format(params)
    return :main
  end
  
private 

  # Read and process the sources
  def read_and_process(params)
    readers = read_all_sources(params)
    @parent_set = readers.first.engine.parent_set
    results = add_parent(params)
    add_managed_children(results)
    results[:tags] = []
    results
  end

  # Process Results. Process the results structure to convert to objects
  def process_results(results)
    parent = results[:parent]

    # Check for differences. If no change then use previous version.
    filtered = []
    results[:managed_children].each_with_index do |child, index| 
      previous_info = AdamIgDataset.latest({scope: child.scope, identifier: child.scoped_identifier})
      previous = previous_info.nil? ? nil : AdamIgDataset.find_full(previous_info.id) 
      actual = child.replace_if_no_change(previous)
      parent.add_no_save(actual, index + 1) # Parent needs ref to child whatever new or previous
      next if actual.uri != child.uri # No changes if actual = previous, so skip next
      filtered << child 
    end
    {parent: parent, managed_children: filtered, tags: []}
  end

end