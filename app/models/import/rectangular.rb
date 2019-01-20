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
    managed?(configuration[:parent_klass].child_klass) ? add_managed_children(results) : add_children(results)
    objects = self.errors.empty? ? process(results) : {parent: self, children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  #handle_asynchronously :import unless Rails.env.test?

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
      merge_classification_set(reader)
    end
  end
    
  def merge_parent_set(reader)
    reader.engine.parent_set.each {|k, v| @parent_set.key?(k) ? self.errors.add(:base, "Duplicate identifier #{k} detected during import.") : @parent_set[k] = v}
  end

  def merge_classification_set(reader)
    reader.engine.classifications.each {|k, v| @classifications[k] = v if !@classifications.key?(k)}
  end

  # Process. Process the results structre to convert to objects
  def process(json)
    results = {parent: nil, children: []}
    parent = configuration[:parent_klass].build(json[:parent][:instance])
    results[:parent] = parent 
    if managed?(configuration[:parent_klass].child_klass)
      json[:children].each do |child|
        child = configuration[:parent_klass].child_klass.build(child[:instance])
        results[:children] << child
        results[:parent].add_child(child)
      end
      # @todo need to add the other collections in the future in line below
      parent.collections = {datatype: TabularStandard::Datatype.new, compliance: TabularStandard::Compliance.new} 
      results[:children].each {|child| child.update_variables(parent.collections)}
    end
    return results
  end

  # Check no errors in the objects structure.
  def object_errors?(objects)
    return true if objects[:parent].errors.any?
    objects[:children].each {|c| return true if c.errors.any?}
    return false
  end

  # Is the klass a managed item
  def managed?(klass)
    klass.ancestors.include?(IsoManaged)
  end

  # a
  def add_managed_children(results)
    ordinal = 1
    parent = results[:parent][:instance]
    @parent_set.each do |key, item| 
      results[:children] << {order: ordinal, instance: add_managed_child(item, parent, ordinal)}
      ordinal += 1
    end
    results[:classifications] = @classifications
  end

  # Build the associated datasets
  def add_managed_child(dataset, parent, ordinal)
    instance = dataset.import_operation(identifier: dataset.identifier, label: parent[:managed_item][:label], 
      semantic_version: parent[:operation][:new_semantic_version], version_label: parent[:managed_item][:scoped_identifier][:version_label], 
      version: parent[:operation][:new_version], date: parent[:managed_item][:creation_date], ordinal: ordinal)
    instance[:managed_item][:children] = []
    dataset.children.each {|v| instance[:managed_item][:children] << v.to_hash}
    return instance
  end        

  def add_children(results)
    parent = results[:parent][:instance]
    @parent_set.each {|key, item| parent[:managed_item][:children] << item.to_hash}
  end

  def add_parent(params)
    klass = configuration[:parent_klass]
    parent = klass.new
    instance = parent.import_operation(identifier: klass.configuration[:identifier], label: params[:label], 
      semantic_version: params[:semantic_version], version_label: params[:version_label], version: params[:version], 
      date: params[:date], ordinal: 1)
    return {parent: {:order => 1, :instance => instance}, children: [], classifications: {}}
  end
  
end