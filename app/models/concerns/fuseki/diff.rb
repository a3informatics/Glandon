# Fuseki Diff. Difference functions for classes
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module Fuseki
  
  module Diff

    include Fuseki::Properties

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      include Fuseki::Properties
      include Fuseki::Persistence::Property

    end

    # Diff? Are the two objects different
    #
    # @param [Object] other the other object to which this object is being compared
    # @raise [Errors::ApplicationLogicError] raised if the objects are not of the same class
    # @return [Boolean] true if different, false otherwise.
    def diff?(other)
      Errors.application_error(self.class.name, __method__.to_s, "Comparing different classes. #{self.class.name} to #{other.class.name}") if self.class != other.class
      properties = properties_read(:instance)
      properties.each do |name, property|
        variable = Fuseki::Persistence::Naming.new(name).as_symbol
        self_object = self.instance_variable_get(name)
        other_object = other.instance_variable_get(name)
        if self_object.is_a?(Array)
          return true if array_diff?(self_object, other_object)
        elsif self_object.nil? 
          return true if !other_object.nil?
        elsif self_object.respond_to? :diff?
          return true if self_object.diff?(other_object)
        else
          return true if self_object != other_object
        end
      end
      false
    end

    # Diff? Are the two objects different
    #
    # @param [Object] other the other object to which this object is being compared
    # @raise [Errors::ApplicationLogicError] raised if the objects are not of the same class
    # @return [Boolean] true if different, false otherwise.
    def difference(previous, options={})
      options[:ignore] = [:uri, :rdf_type, :uuid] if options[:ignore].blank?
      results = {}
      Errors.application_error(self.class.name, __method__.to_s, "Comparing different classes. #{self.class.name} to #{previous.class.name}") if self.class != previous.class
      properties = properties_read(:instance)
      properties.each do |name, property|
        variable = Fuseki::Persistence::Naming.new(name).as_symbol
        next if options[:ignore].include?(variable)
        self_object = self.instance_variable_get(name)
        previous_object = previous.instance_variable_get(name)
        if self_object.is_a?(Array)
          results[variable] = array_difference(self_object, previous_object, options)
        elsif self_object.nil? 
          a = ""
          status = previous_object.nil? ? :no_change : :deleted
          b = previous_object.nil? ? "" : previous_object
          results[variable] = self.difference_record(:not_present, a, b)
        elsif self_object.respond_to? :difference
          self_object.difference(other_object, options)
        else
          status = self_object == previous_object ? :no_change : :updated
          results[variable] = difference_record(status, self_object, previous_object)
        end
      end
      results
    end

  private

    def array_diff?(a, b)
      return diff_uris?(a, b) if a.first.is_a? Uri
      if a.class.respond_to?(:key_property)
        key_method = a.first.class.key_property
        a.each do |a_obj|
          b_obj = b.select {|x| x.send(key_method) == a_obj.send(key_method)}
          return true if b_obj.empty? 
          return true if a_obj.diff?(b_obj.first)
        end    
      else
        return true if a - b != []
      end
      return false
    end

    def diff_uris?(a, b)
      a_to_s = uris_to_s(a)
      b_to_s = uris_to_s(b)
      return a_to_s - b_to_s != []
    end

    def uris_to_s(objects)
      result = []
      objects.each {|x| result << x.to_s}
      result
    end

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

    def difference_record(status, current, previous)
      {status: status, previous: previous, current: current, difference: Diffy::Diff.new(previous, current).to_s(:html)}
    end

    def difference_uris(current, previous)
      current_to_s = uris_to_s(current)
      previous_to_s = uris_to_s(previous)
      array_difference(current_to_s, previous_to_s, {})
    end

  end

end