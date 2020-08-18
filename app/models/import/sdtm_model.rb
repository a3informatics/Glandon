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
    add_managed_children(results)
    results[:tags] = []
    results
  end

  # Process Results. Process the results structure to convert to objects
  def process_results(results)

    # Build the model variables. Make sure no duplicates
    model_vars = {}
    results[:managed_children].each_with_index do |child, index| 
      child.children.each do |var|
        next if model_vars.key?(var.name)
        model_vars[var.name] = var
      end
    end
    results[:parent].includes_variable = model_vars.map{|k,v| v}

    # Build the class variables based on the model variables. For the required classes include the basic set.
    classes  =["SDTM MODEL EVENTS", "SDTM MODEL FINDINGS", "SDTM MODEL INTERVENTIONS"]
    all = results[:managed_children].delete_at(results[:managed_children].find_index {|x| x.scoped_identifier == "SDTM MODEL ALL"})
    results[:managed_children].each_with_index do |child, index| 
      class_vars = []
      model_vars = classes.include?(child.scoped_identifier) ? all.includes_column + child.includes_column : child.includes_column
      model_vars.each_with_index do |model_var, index|
        variable = SdtmClass::Variable.new(label: model_var.label, based_on_variable: model_var.uri, ordinal: index+1)
        variable.uri = variable.create_uri(child.uri)
        class_vars << variable
      end
      child.includes_column = class_vars
    end

    # Check for differences. If no change then use previous version.
    filtered = []
    parent = results[:parent]
    results[:managed_children].each_with_index do |child, index| 
      previous_info = SdtmClass.latest({scope: child.scope, identifier: child.scoped_identifier})
      previous = previous_info.nil? ? nil : SdtmClass.find_full(previous_info.id) 
      actual = child.replace_if_no_change(previous)
      parent.add_no_save(actual, index + 1) # Parent needs ref to child whatever new or previous
      next if actual.uri != child.uri # No changes if actual = previous, so skip next
      filtered << child 
    end
    {parent: parent, managed_children: filtered, tags: []}
  end

end