# Import Rectangular. Import a rectangular excel structure
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::Rectangular < Import

  C_CLASS_NAME = self.name
  
  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :identifier the identifier
  # @option params [String] :semantic_version the semantic version
  # @option params [String] :version_label the version label
  # @option params [String] :version the version
  # @option params [String] :date the date of issue
  # @option params [Array] :files
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    @parent_set = {}
    @classifications = {}
    read_all_excel(params)
    results = add_parent(params)
    add_managed_children(results) if managed?(configuration[:parent_klass].child_klass)
    objects = self.errors.empty? ? process(results) : {parent: self, children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  def configuration
    self.class.configuration
  end

private

  def read_all_excel(params)
    params[:files].each do |file|
      reader = configuration[:reader_klass].new(file)
      reader.check_and_process_sheet(configuration[:import_type], self.send(configuration[:sheet_name], params))
      merge_errors(reader, self)
      merge_parent_set(reader)
      #merge_classification_set(reader)
    end
  end
    
  def merge_parent_set(reader)
    reader.engine.parent_set.each do |k, v| 
      if @parent_set.key?(k) 
        self.errors.add(:base, "Duplicate identifier #{k} detected during import of #{reader.full_path} and a difference has been detected.") if @parent_set[k].diff?(v) 
      else
        @parent_set[k] = v
      end
    end
  end

  #def merge_classification_set(reader)
  #  reader.engine.classifications.each {|k, v| @classifications[k] = v if !@classifications.key?(k)}
  #end

  # Process. Process the results structre to convert to objects
  def process(results)
    klass = configuration[:parent_klass]
    child_klass = klass.child_klass
    return results if !managed?(child_klass)
    parent = results[:parent]
    results[:managed_children].each_with_index do |child, index| 
      previous_info = child_klass.latest({scope: klass.owner, identifier: child.identifier})
      if !previous_info.nil?
        previous = child_klass.find(previous_info.id) 
        child = child.replace_if_no_change(previous)
      end
      parent.add(child, index + 1)
    end
    return results
  end

  # Check no errors in the objects structure.
  def object_errors?(objects)
    return true if objects[:parent].errors.any?
    objects[:managed_children].each {|c| return true if c.errors.any?}
    return false
  end

  # Is the klass a managed item
  def managed?(klass)
    klass.ancestors.include?(IsoManagedV2)
  end

  # Add the children that are managed items in their own right
  def add_managed_children(results)
    ordinal = 1
    parent = results[:parent]
    @parent_set.each do |key, item| 
      results[:managed_children] << add_managed_child(item, parent, ordinal)
      ordinal += 1
    end
  end

  # Add a single managed child
  def add_managed_child(dataset, parent, ordinal)
    dataset.set_import(identifier: dataset.identifier, label: parent.label, 
      semantic_version: parent.semantic_version, version_label: parent.version_label, 
      version: parent.version, date: parent.creation_date.to_s, ordinal: ordinal)
    return dataset
  end        

  # Add the children that are not managed items
  #def add_children(results)
  #  @parent_set.each {|key, item| results[:managed_children] << item}
  #end

  def add_parent(params)
    klass = configuration[:parent_klass]
    parent = klass.new
    parent.set_import(identifier: klass.configuration[:identifier], label: params[:label], 
      semantic_version: params[:semantic_version], version_label: params[:version_label], version: params[:version], 
      date: params[:date], ordinal: 1)
    return {parent: parent, managed_children: []}
  end
  
end