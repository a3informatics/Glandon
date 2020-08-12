# SDTM Model Importer
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class Import::SdtmModel < Import

  include Import::Utility
  
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
    params[:identifier] = ::SdtmModel.identifier
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

  # Configuration. Sets the parameters for the import
  # 
  # @return [Hash] the configuration hash
  def configuration
    {
      description: "Import of CDISC SDTM Model",
      parent_klass: ::SdtmModel,
      reader_klass: Excel,
      import_type: :cdisc_sdtm_model,
      format: :format,
      version_label: :semantic_version,
      label: "CDISC SDTM Model"
    }
  end

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
byebug
    add_managed_children(results)
    results[:tags] = []
    results
  end

  # Process Results. Process the results structure to convert to objects
  def process_results(results)
    # klass = configuration[:parent_klass]
    # child_klass = klass.child_klass
    # return results if !managed?(child_klass)
    # parent = results[:parent]
    # scope = klass.owner.ra_namespace
    # results[:managed_children].each_with_index do |child, index| 
    #   previous_info = child_klass.latest({scope: scope, identifier: child.identifier})
    #   previous = previous_info.nil? ? nil : child_klass.find_full(previous_info.id) 
    #   actual = child.replace_if_no_change(previous)
    #   parent.add(actual, index + 1) # Parent needs ref to child whatever new or previous
    #   next if actual.uri != child.uri # No changes if actual = previous, so skip next
    #   child.add_additional_tags(previous, tag_set) 
    #   filtered << child 
    # end
    # return {parent: parent, managed_children: filtered, tags: tag_set}
    results
  end

end