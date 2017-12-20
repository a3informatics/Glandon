module ConceptDifference

  C_CLASS_NAME = "ConceptDifference"

  # Diff? Are two objects different
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Boolean] True if different, false otherwise.
  def self.diff?(previous, current, options={})
    options[:ignore] = [] if options[:ignore].blank?
    return true if previous.nil?
    return true if current.nil?
    check_classes(previous, current, __method__.to_s)
    result = diff?(previous.reference, current.reference) if current.respond_to? :reference
    return true if result
    current_set = property_set(current)
    previous_set = property_set(previous)
    current_set.each { |k, v| return true if !property_equal?(k, previous_set[k][:value], v[:value], options) }
    return false
  end

  # Diff With Children? Are two objects and their children different.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Boolean] True if different, false otherwise.
  def self.diff_with_children?(previous, current, identifier, options={})
    options[:ignore] = [] if options[:ignore].blank?
    diff?(previous, current, options)
    current.children.each do |c_child|
      p_child = previous.children.find { |x| x.instance_variable_get("@#{identifier}") == c_child.instance_variable_get("@#{identifier}") }
      return true if p_child.nil?
      return true if diff?(p_child, c_child, options)
    end
    return false
  end

  # Difference between two objects.
  #
  # @previous [Object] The previous object being compared
  # @current [Object] The current object being compared
  # @return [Hash] The differenc hash
  def self.difference(previous, current, options={})
    options[:ignore] = [] if options[:ignore].blank?
    check_classes(previous, current, __method__.to_s)
    results = {}
    status = :no_change
    if previous.nil? && current.nil?
      status = :not_present
    elsif previous.nil?
      property_difference(previous, current, results, options)
      status = :created
    elsif current.nil?
      property_difference(previous, current, results, options)
      status = :deleted
    else
      status = :updated if property_difference(previous, current, results, options)
    end
    return {status: status, results: results}
  end

  # Difference With Children. The difference between two objects and thir respective children objects.
  #
  # @param [Object] previous the previous object being compared
  # @param [Object] current the current object being compared
  # @param [String] identifier the property ised to identify an object
  # @return [Hash] The differenc hash
  def self.difference_with_children(previous, current, identifier, options={})
    options[:ignore] = [] if options[:ignore].blank?
    results = difference(previous, current, options)
    children = {}
    if previous.nil? && current.nil?
      children = {}
    elsif previous.nil?
      current.children.each { |child| difference_record(children, :created, child) }
    elsif current.nil?
      previous.children.each { |child| difference_record(children, :deleted, child) }
    else
      current_index = Hash[current.children.map{|x| [x.instance_variable_get("@#{identifier}"), x]}]
      previous_index = Hash[previous.children.map{|x| [x.instance_variable_get("@#{identifier}"), x]}]
      current.children.each do |child|
        id = child.instance_variable_get("@#{identifier}")
        diff = self.diff?(previous_index[id], child, options) 
        if diff && previous_index[id].nil? 
          status = :created
        elsif diff
          status = :updated
        else
          status = :no_change
        end
        difference_record(children, status, child)
      end
      deleted = current_index.reject { |k, _| previous_index.include? k }
      deleted.each { |k, v| difference_record(children, :deleted, v) }
    end
    results[:children] = children
    return results
  end

private

  def self.property_equal?(name, previous, current, options)
    return true if options[:ignore].include? name
    return current == previous
  end

  def self.property_difference(previous, current, results, options)
    changes = false
    changes = property_difference(previous.reference, current.reference, results, options) if current.respond_to? :reference
    previous_set = property_set(previous)
    current_set = property_set(current)
    current_set.each do |k, v|
      status = :no_change
      status = :updated if !property_equal?(k, previous_set[k][:value], v[:value], options)
      property_record(results, v[:label].to_sym, status, previous_set[k][:value], v[:value])
      changes = true if status != :no_change
    end
    return changes
  end

  def self.property_record(results, key, status, previous, current)
    results[key] = {status: status, previous: previous, current: current, difference: Diffy::Diff.new(previous, current).to_s(:html)}
  end

  def self.property_set(object)
    set = []
    set += object.additional_properties if object.respond_to? :additional_properties
    set += property_set_values(object, object.properties)
    set += property_set_values(object, object.extension_properties)
    return set.map { |u| [u[:instance_variable], u] }.to_h
  end
  
  def self.property_set_values(object, properties)
    return properties.each { |p| p[:value] = object.instance_variable_get("@#{p[:instance_variable]}")}
  end
  
  def self.difference_record(results, status, object)
    record = { status: status }
    difference_record_properties(record, object.reference) if object.respond_to? :reference 
    difference_record_properties(record, object) 
    results[object.uri.to_s] = record
  end

  def self.difference_record_properties(record, object)
    set = property_set(object)
    set.each { |k, v| record[v[:instance_variable].to_sym] = v[:value] }
  end

  def self.check_classes(previous, current, method)
    return if previous.class.name == current.class.name
    raise Exceptions::ApplicationLogicError.new(message: "Mismatch of class in #{method} within #{C_CLASS_NAME} object.") 
  end
  
end
