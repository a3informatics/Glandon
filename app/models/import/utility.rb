# Import Rectangular. Base set of methods for a rectangular structure
#
# @author Dave Iberson-Hurst
# @since 2.26.0
module Import::Utility

  # Read all the Excel files
  def read_all_sources(params)
    readers = []
    params[:import_type] = configuration[:import_type]
    params[:format] = self.send(configuration[:format], params)
    params[:files].each do |file|
      reader = configuration[:reader_klass].new(file)
      merge_errors(reader, self)
      next if !reader.errors.empty?
      reader.execute(params)
      merge_errors(reader, self)
      readers << reader
    end
    readers
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
    parent.set_import(identifier: params[:identifier], label: params[:label], 
      semantic_version: params[:semantic_version], version_label: params[:version_label], version: params[:version], 
      date: params[:date], ordinal: 1)
    parent.origin = import_files(params)
    parent.add_tags_no_save(@tags)
    return {parent: parent, managed_children: []}
  end

  # Format files used in import
  def import_files(params)
    "Created from files: #{params[:files].map {|x| "'#{File.basename(x)}'"}.join(", ")}"
  end

end