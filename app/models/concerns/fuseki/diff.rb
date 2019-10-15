# Fuseki Diff. Difference functions for classes
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Diff

    include Fuseki::Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      include Fuseki::Resource

    end

    # Diff? Are the two objects different
    #
    # @param [Object] other the other object to which this object is being compared
    # @param [Hash] options the options to use for the diff operation
    # @option options [Array] :ignore An array of properties to be ignored
    # @raise [Errors::ApplicationLogicError] raised if the objects are not compatible classes
    # @return [Boolean] true if different, false otherwise.
    def diff?(other, options={})
      return true if other.nil?
      options[:ignore] = [] if options[:ignore].blank?
      Errors.application_error(self.class.name, __method__.to_s, "Comparing different classes. #{self.class.name} to #{other.class.name}") if incomptible_klass?(other)
      @properties.each do |property|
        name = property.name
        next if options[:ignore].include?(name)
        self_object = self.instance_variable_get(property.instance_name)
        other_object = other.instance_variable_get(property.instance_name)
        if self_object.is_a?(Array)
          return true if array_diff?(self_object, other_object, options)
        elsif self_object.nil? 
          return diff(name, self_object, other_object) if !other_object.nil?
        elsif self_object.respond_to? :diff?
          return diff(name, self_object, other_object) if self_object.diff?(other_object)
        else
          return diff(name, self_object, other_object) if self_object != other_object
        end
      end
      false
    end

    # Difference. How are the two objects different
    #
    # @param [Object] other the other object to which this object is being compared
    # @param [Hash] options the options to use for the diff operation
    # @option options [Array] :ignore An array of properties to be ignored
    # @raise [Errors::ApplicationLogicError] raised if the objects are not compatible classes
    # @return [Hash] the results hash
    def difference(other, options={})
      options[:ignore] = [] if options[:ignore].blank?
      results = {}
      Errors.application_error(self.class.name, __method__.to_s, "Comparing different classes. #{self.class.name} to #{other.class.name}") if !other.nil? && incomptible_klass?(other)
      @properties.each do |property|
        name = property.name
        next if options[:ignore].include?(name)
        self_object = self.instance_variable_get(property.instance_name)
        if other.nil?
          results[name] = difference_record_baseline(:created, self_object)          
        else
          other_object = other.instance_variable_get(property.instance_name)
          if self_object.is_a?(Array)
            results[name] = array_difference(self_object, other_object, options)
          elsif self_object.nil? 
            a = ""
            status = other_object.nil? ? :no_change : :deleted
            b = other_object.nil? ? "" : other_object
            results[name] = difference_record(:not_present, a, b)
          elsif self_object.respond_to? :difference
            results[name] = self_object.difference(other_object, options)
          else
            status = self_object == other_object ? :no_change : :updated
            results[name] = difference_record(status, self_object, other_object)
          end
        end
      end
      results
    end

    def difference_baseline(options={})
      options[:ignore] = [] if options[:ignore].blank?
      results = {}
      @properties.each do |property|
        name = property.name
        next if options[:ignore].include?(variable)
        self_object = self.instance_variable_get(name)
        if self_object.is_a?(Array)
          results[name] = array_difference_baseline(self_object, options)
        elsif self_object.nil? 
          results[name] = difference_record_baseline(:not_present, nil)
        elsif self_object.respond_to? :difference_baseline
          results[name] = self_object.difference_baseline(options)
        else
          results[name] = difference_record_baseline(:created, self_object)
        end
      end
      results
    end


  private

    def diff(name, self_object, other_object)
puts "\nDiff: #{name}: \nSELF:  #{self_object}\nOTHER: #{other_object}\n\n" if name.is_a? Symbol
      true
    end

    # Check we have comptible classes.
    def incomptible_klass?(other)
      !self.class.ancestors.include?(other.class)
    end

    # Array diff?
    def array_diff?(a, b, options)
      return diff("Array diff count", a.count, b.count) if a.count != b.count
      return diff_uris?(a, b) if a.first.is_a? Uri
      if a.first.class.respond_to?(:key_property)
        key_method = a.first.class.key_property
        a.each do |a_obj|
          b_obj = b.select {|x| x.send(key_method) == a_obj.send(key_method)}
          return true if b_obj.empty?
          return diff("Array key", a_obj, b_obj) if a_obj.diff?(b_obj.first, options)
        end    
      elsif a.first.respond_to?(:diff?)
        a.each_with_index do |a_obj, index|
          match_by_uri = b.select {|x| x.uri == a_obj.uri}
          b_obj = match_by_uri.empty? ? b[index] : match_by_uri.first
          return diff("Array diff", a_obj, b_obj) if a_obj.diff?(b_obj, options)
        end    
      else
        a.each_with_index do |a_obj, index|
          b_obj = b[index]
          return diff("Array else", a_obj, b_obj) if a_obj != b_obj
        end    
      end
      return false
    end

    # URI Array Diff? 
    def diff_uris?(a, b)
      a_to_s = uris_to_s(a)
      b_to_s = uris_to_s(b)
      return a_to_s - b_to_s != [] || b_to_s - a_to_s != []
    end

    # URIs to String
    def uris_to_s(objects)
      result = []
      objects.each {|x| result << x.to_s}
      result
    end

    # Array difference
    def array_difference(current, previous, options)
      return difference_uris(current, previous) if current.first.is_a? Uri
      results = []
      if current.class.respond_to?(:key_property)
        key_method = current.first.class.key_property
        current.each do |current_obj|
          previous_obj = previous.select {|x| x.send(key_method) == current_obj.send(key_method)}
          results << current_obj.difference(previous_obj.first)
        end    
      else
        current.each_with_index do |current_obj, index|
          previous_obj = previous[index]
          if current_obj.respond_to?(:difference)
            results << current_obj.difference(previous_obj, options)
          else
            status = current_obj == previous_obj ? :no_change : :updated
            results << difference_record(status, current_obj, previous_obj)
          end
        end    
      end
      results
    end

    # Array difference
    def array_difference_baseline(current, options)
      results = []
      current.each_with_index do |current_obj, index|
        if current_obj.respond_to?(:difference)
          results << current_obj.difference_baseline(options)
        else
          results << difference_record_baseline(:no_change, current_obj)
        end
      end    
      results
    end

    # Difference Record
    def difference_record(status, current, previous)
      {status: status, previous: previous, current: current, difference: Diffy::Diff.new(previous, current).to_s(:html)}
    end

    def difference_record_baseline(status, current)
      value = current.nil? ? "" : current
      {status: status, previous: "", current: value, difference: ""} #Diffy::Diff.new("", current).to_s(:html)}
    end

    # Difference URIs
    def difference_uris(current, previous)
      current_to_s = uris_to_s(current)
      previous_to_s = uris_to_s(previous)
      array_difference(current_to_s, previous_to_s, {})
    end

  end

end