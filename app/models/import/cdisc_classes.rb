# Import STFO Classes. Classes for Sponsor Thesaurus
#
# @author Dave Iberson-Hurst
# @since 3.3.0
module Import::CdiscClasses

  class CdiscThesaurus < CdiscTerm

    def self.child_klass
      Import::CdiscClasses::CdiscCl
    end

      def self.child_klass
      Import::STFOClasses::STFOCodeList
    end

    def self.identifier
      "CT"
    end

  end

  class CdiscCodeList < Thesaurus::ManagedConcept  

    def children
      return self.narrower
    end
    
    def self.owner
      CdiscTerm.owner
    end

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_additional_tags(previous, set)
      return if previous.nil?
      missing =  previous.tagged.map{|x| x.uri.to_s} - self.tagged.map{|x| x.uri.to_s}
      missing.each {|x| set << {subject: self.uri, object: Uri.new(uri: x)}}
      add_child_additional_tags(previous, set)
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
      self.tagged = self.tagged | other.tagged
      self.errors.empty?
    end

  private

    # Add additional tags
    def add_child_additional_tags(previous, set)
      self.narrower.each_with_index do |child, index|
        previous_child = previous.narrower.select {|x| x.identifier == child.identifier}
        next if previous_child.empty?
        child.add_additional_tags(previous_child.first, set)
      end
    end

    def tagged
      object.instance_variable_get("@tagged")
    end

  end

  class CdiscCodeListItem < Thesaurus::UnmanagedConcept  

    # Add additional tags
    #
    # @param previous [Thesaurus::UnmanagedConcept] previous item
    # @param set [Array] set of tags objects
    # @return [Void] no return
    def add_additional_tags(previous, set)
      return if previous.nil?
      missing =  previous.tagged.map{|x| x.uri.to_s} - self.tagged.map{|x| x.uri.to_s}
      missing.each {|x| set << {subject: self.uri, object: Uri.new(uri: x)}}
    end

  private

    def tagged
      object.instance_variable_get("@tagged")
    end

  end

end