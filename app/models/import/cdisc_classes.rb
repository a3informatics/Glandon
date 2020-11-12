# Import STFO Classes. Classes for Sponsor Thesaurus
#
# @author Dave Iberson-Hurst
# @since 3.3.0
module Import::CdiscClasses

  class CdiscThesaurus < ::CdiscTerm

    def self.child_klass
      Import::CdiscClasses::CdiscCodeList
    end

    def add_context_tags(set)
      tagged.each {|x| set << {subject: self.uri, object: x.uri, context: [self.uri]}}
    end

  private

    def tagged
      self.instance_variable_get("@tagged")
    end

  end

  class CdiscCodeList < Thesaurus::ManagedConcept  

    def children
      return self.narrower
    end
    
    def self.owner
      ::CdiscTerm.owner
    end

  end

  class Thesaurus::ManagedConcept  

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_context_tags(actual, set, context)
      tagged.each {|x| set << {subject: actual.uri, object: x.uri, context: [context]}}
      add_child_context_tags(actual, set, [actual.uri, context])
    end

    # Merge. Merge two concepts. Concepts must be the same with common children being the same.
    #
    # @result [Boolean] returns true if the concepts merged.
    def merge(other)
      self.errors.clear
      return false if diff_self?(other)
      self_ids = self.narrower.map{|x| x.identifier}
      other_ids = other.narrower.map{|x| x.identifier}
      common_ids = self_ids & other_ids
      missing_ids = other_ids - self_ids
      common_ids.each do |identifier|
        this_child = self.narrower.find{|x| x.identifier == identifier}
        other_child = other.narrower.find{|x| x.identifier == identifier}
        next if children_are_the_same?(this_child, other_child)
        uri = Uri.new(uri: "http://www.temp.com/") # Temporary nasty
        this_child.uri = uri
        other_child.uri = uri
        record = this_child.difference_record(this_child.simple_to_h, other_child.simple_to_h)
        msg = "When merging #{self.identifier} a difference was detected in child #{identifier}\n#{record.map {|k, v| "#{k}: #{v[:previous]} -> #{v[:current]}" if v[:status] != :no_change}.compact.join("\n")}"
        errors.add(:base, msg)
        ConsoleLogger.info(self.class.name, __method__.to_s, msg)
      end
      missing_ids.each do |identifier|
        other_child = other.narrower.find{|x| x.identifier == identifier}
        self.narrower << other_child
      end
      self.instance_variable_set("@tagged", self.tagged | other.tagged)
      self.errors.empty?
    end

    # Are children are the same
    def children_are_the_same?(this_child, other_child)
      result = this_child.diff?(other_child, {ignore: []})
      return false if result
      this_child.instance_variable_set("@tagged", this_child.tagged | other_child.tagged)
      return true
    end

    def tagged
      return [] unless instance_variable_defined?("@tagged")
      self.instance_variable_get("@tagged")
    end

  private

    def get_missing(previous)
      missing = previous.nil? ? self.tagged.map{|x| x.uri.to_s} : self.tagged.map{|x| x.uri.to_s} - previous.tagged.map{|x| x.uri.to_s}
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
          child.add_context_tags(actual_child.first, set, contexts)
        end
      end
    end

  end

  class CdiscCodeListItem < Thesaurus::UnmanagedConcept  
  end

  class Thesaurus::UnmanagedConcept  

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_context_tags(subject, set, contexts)
      tagged.each {|x| set << {subject: subject.uri, object: x.uri, context: contexts}}
    end

    def tagged
      return [] unless instance_variable_defined?("@tagged")
      self.instance_variable_get("@tagged")
    end

  end

end