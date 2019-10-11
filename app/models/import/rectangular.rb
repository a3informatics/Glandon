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

  # Read all the Excel files
  def read_all_excel(params)
    params[:files].each do |file|
      reader = configuration[:reader_klass].new(file)
      merge_errors(reader, self)
      next if !reader.errors.empty?
      reader.check_and_process_sheet(configuration[:import_type], self.send(configuration[:sheet_name], params))
      merge_errors(reader, self)
      next if !reader.errors.empty?
      merge_parent_set(reader)
    end
  end
    
  # Merge the parent sets. Error if they dont match!
  def merge_parent_set(reader)
    dup_count = 0
    reader.engine.parent_set.each do |k, v| 
      if @parent_set.key?(k)
        next if @parent_set[k].merge(v)
        msg =  "Duplicate identifier #{k} detected during import of #{reader.full_path} and cannot merge as a difference has been detected"
        self.errors.add(:base, msg)
        merge_errors(@parent_set[k], self)
        ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, msg)
        dup_count += 1
      else
        @parent_set[k] = v
      end
    end
    ConsoleLogger.info(C_CLASS_NAME, __method__.to_s, "Duplicate identifier count #{dup_count}.")
  end

  # Process. Process the results structure to convert to objects
  def process(results)
    filtered = []
    tag_set = []
    klass = configuration[:parent_klass]
    child_klass = klass.child_klass
    return results if !managed?(child_klass)
    parent = results[:parent]
    scope = klass.owner.ra_namespace
    results[:managed_children].each_with_index do |child, index| 
      previous_info = child_klass.latest({scope: scope, identifier: child.identifier})
      previous = previous_info.nil? ? nil : child_klass.find_full(previous_info.id) 
      actual = child.replace_if_no_change(previous)
      parent.add(actual, index + 1) # Parent needs ref to child whatever new or previous
      parent.add_tags(actual.tagged)
      next if actual.uri != child.uri # No changes if actual = previous, so skip next
      child.add_additional_tags(previous, tag_set) 
      filtered << child 
    end
    return {parent: parent, managed_children: filtered, tags: tag_set}
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

  # Add the parent item
  def add_parent(params)
    klass = configuration[:parent_klass]
    parent = klass.new
    parent.set_import(identifier: klass.configuration[:identifier], label: params[:label], 
      semantic_version: params[:semantic_version], version_label: params[:version_label], version: params[:version], 
      date: params[:date], ordinal: 1)
    parent.origin = import_files(params)
    return {parent: parent, managed_children: []}
  end

  # Format files used in import
  def import_files(params)
    "Created from files: #{params[:files].map {|x| "'#{File.basename(x)}'"}.join(", ")}"
  end

end