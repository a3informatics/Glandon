# Thesaurus Extend. Extension methods for existing Thesaurus classes used in imports
#
# @author Dave Iberson-Hurst
# @since 3.3.0
module Import::ThesaurusExtend

  class ::Thesaurus

    def add_context_tags(set)
      tagged.each {|x| set << {subject: self.uri, object: x.uri, context: [self.uri]}}
    end

    def tagged
      return [] unless instance_variable_defined?(instance_variable_name)
      self.instance_variable_get(instance_variable_name)
    rescue => e
      byebug
    end

  private

    def instance_variable_name
      "@tagged"
    end

  end


  class ::Thesaurus::ManagedConcept  

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_context_tags(actual, set, context)
      tagged.each {|x| set << {subject: actual.uri, object: x.uri, context: [context]}}
      add_child_context_tags(actual, set, [actual.uri, context])
    end

    def tagged
      return [] unless instance_variable_defined?(instance_variable_name)
      self.instance_variable_get(instance_variable_name)
    rescue => e
      byebug
    end

  private

    def instance_variable_name
      "@tagged"
    end

    # Add additional tags
    def add_child_context_tags(actual, set, contexts)
      if self.uri == actual.uri
        self.narrower.each do |child|
          child.add_context_tags(child, set, contexts)
        end
      else
        self.narrower.each do |child|
          actual_child = actual.narrower.select {|x| x.identifier == child.identifier}
          next if actual_child.empty?
          child.add_context_tags(actual_child.first, set, contexts)
        end
      end
    end

  end

  class ::Thesaurus::UnmanagedConcept  

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_context_tags(subject, set, contexts)
      tagged.each {|x| set << {subject: subject.uri, object: x.uri, context: contexts}}
    rescue => e
      byebug
    end

    def tagged
      return [] unless instance_variable_defined?(instance_variable_name)
      self.instance_variable_get(instance_variable_name)
    rescue => e
      byebug
    end

    def rank
      instance_variable_get("@rank")
    end

    def rank=(value)
      instance_variable_set("@rank", value)
    end

    def tagged=(value)
      instance_variable_set(instance_variable_name, value)
    end

  private

    def instance_variable_name
      "@tagged"
    end

  end

end