# Import Rectangular. Import a rectangular structure
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Import::Rectangular < Import

  C_CLASS_NAME = self.name
  
  # Import. Import the rectangular structure
  #
  # @param [Hash] params a parameter hash
  # @option params [String] :filename the full path of the file to be read
  # @option params [Background] :job the background job
  # @return [Void] no return value
  def import(params)
    reader = self.reader_klass.new(params[:filename])
    results = reader.read(params)
    objects = reader.errors.empty? ? process(results) : {parent: reader, children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  #handle_asynchronously :import unless Rails.env.test?

private

  # Process. Process the results structre to convert to objects
  def process(json)
    results = {parent: nil, children: []}
    parent = self.parent_klass.build(json[:parent][:instance])
    results[:parent] = parent 
    if parent_klass.child_klass.is_a? IsoManaged
      json[:children].each do |child|
        child = self.parent_klass.child_klass.build(child[:instance])
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

end