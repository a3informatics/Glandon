class Import::Rectangular < Import

  C_CLASS_NAME = self.name
  
  def import(params)
    reader = self.reader_klass.new(params[:filename])
    results = reader.read(params)
    objects = reader.errors.empty? ? process(params, results) : {parent: reader, children: []}
    object_errors?(objects) ? save_error_file(objects) : save_load_file(objects) 
    # @todo we need to unlock the import.
    params[:job].end("Complete")   
  rescue => e
    msg = "An exception was detected during the import processes."
    save_exception(e, msg)
    params[:job].exception(msg, e)
  end 
  handle_asynchronously :import unless Rails.env.test?

  def process(params, json)
    results = {parent: nil, children: []}
    parent = self.parent_klass.build(json[:parent][:instance])
    results[:parent] = parent 
    json[:children].each do |child|
      child = self.parent_klass.child_klass.build(child[:instance])
      results[:children] << child
      results[:parent].add_child(child)
    end
    parent.collections = {datatype: TabularStandard::Datatype.new, compliance: TabularStandard::Compliance.new}
    results[:children].each do |child|
      child.update_variables(parent.collections)
    end
    return results
  end

private

  def object_errors?(objects)
    return true if objects[:parent].errors.any?
    objects[:children].each {|c| return true if c.errors.any?}
    return false
  end

end