# Import STFO Classes. Classes for Sponsor Thesaurus
#
# @author Dave Iberson-Hurst
# @since 2.26.0
module Import::STFOClasses

  class STFOThesaurus < Thesaurus
  
    @@owner_ra = nil

    # Owner
    #
    # @return [IsoRegistrationAuthority] the owner
    def self.owner
      return @@owner_ra if !@@owner_ra.nil?
      @@owner_ra = IsoRegistrationAuthority.owner
      @@owner_ra.freeze
    end

    def self.child_klass
      Import::STFOClasses::STFOCodeList
    end

  end

  class STFOCodeList < Thesaurus::ManagedConcept  

    def children
      return self.narrower
    end
  
    def self.owner
      STFOThesaurus.owner
    end

    # Referenced?. Is the Code List actually referencing one from the quoted thesarus. The code list
    #   items must match the items in the referenced ManagedConcept or be a subset thereof.
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def referenced?(ct)
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = reference(ct)
      return nil if ref_ct.nil?
      return ref_ct if self.child_identifiers - ref_ct.child_identifiers == [] # self should be equal or subset of the reference 
      others = self.child_identifiers - ref_ct.child_identifiers
      add_log("Referenced check failed, the item identifiers for code list #{self.identifier} not matching are: #{others.join(", ")}") 
      nil
    end

    # Extension?. Is the Code List an extension code list?
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not an extension or the extension item.
    def extension?(ct)
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = reference(ct)
      if !ref_ct.nil?
        ref_ct.narrower_objects
        others = self.child_identifiers - ref_ct.child_identifiers
        return self if STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(others) and others.any?
        add_log("Extension check failed, the item identifiers for code list #{self.identifier} not matching are: #{others.join(", ")}") 
      end
      nil
    end

    def to_extension(ct)
      new_narrower = []
      ref_ct = reference(ct)
      if ref_ct.nil?
        add_error("Failed to find referenced code list for an extension, identifier '#{self.identifier}'.")
      elsif !ref_ct.extensible
        add_error("Extending non-extensible code list, identifier '#{self.identifier}'.")
      else
        self.extends = ref_ct
        new_marrower = ref_ct.narrower
        self.narrower.each do |child|
          if NciThesaurusUtility.c_code?(child.identifier)
            new_child = ref_ct.narrower.find{|x| x.identifier == child.identifier}
            if new_child.nil?
              options = ct.find_identifier(child.identifier)
              if options.empty?
                add_error("Cannot find #{child.identifier} in code list extension, identifier '#{self.identifier}'.")
              elsif options.count == 1
                new_narrower << Thesaurus::UnmanagedConcept.find(options.first)
              else
                add_error("Cannot find unique #{child.identifier} in code list extension, identifier '#{self.identifier}'.")
              end
            end
          else
            new_narrower << child
          end
        end
        self.narrower = new_narrower
      end
      self
    rescue => e
byebug
      add_error("Exception in to_extension, identifier '#{self.identifier}'.")
      self
    end

    # Subset? Is the entry a subset code list?
    #
    # @return [Boolean] true if a subset, false otherwise
    def subset?
      self.preferred_term.label.upcase.split(/[^[[:word:]]]+/).include? "SUBSET"
    end

    # Subset of Extension? Is the entry a subset of an extension code list?
    #
    # @return [Boolean] true if a subset, false otherwise
    def subset_of_extension?(extensions)
      subset? && extensions.key?(self.identifier)
    end

    def to_cdisc_subset(ct)
      new_narrower = []
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = reference(ct)
      self.identifier = Thesaurus::ManagedConcept.new_identifier
      self.has_identifier.identifier = self.identifier
      self.narrower.each do |child|
        new_child = ref_ct.narrower.find{|x| x.identifier == child.identifier}
        if new_child.nil?
          add_error("Cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      # @todo set up ordering
      self
    rescue => e
      add_error("Exception in to_cdisc_subset, identifier '#{self.identifier}'.")
      nil
    end

    def to_sponsor_subset(sponsor_ct)
      new_narrower = []
      ref_ct = sponsor_ct.find{|x| x.identifier == self.identifier}
      return nil if ref_ct.nil?
      self.identifier = Thesaurus::ManagedConcept.new_identifier
      self.has_identifier.identifier = self.identifier
      self.narrower.each do |child|
        new_child = ref_ct.narrower.find{|x| x.identifier == child.identifier}
        if new_child.nil?
          add_error("Cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      # @todo set up ordering
      self
    rescue => e
      add_error("Exception in to_sponsor_subset, identifier '#{self.identifier}'.")
      nil
    end

    def to_hybrid_sponsor(ct)
      self
    end

    # Sponsor? Is this a sponsor code list
    #
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def sponsor?
      sponsor_identifier? && sponsor_child_identifiers?
    end

    # Hybrid Sponsor? Is this a hybrid sponsor code list
    #
    # @return [Boolean] true if a hybrid sponsor code list, false otherwise.
    def hybrid_sponsor?
      sponsor_identifier? && sponsor_child_or_referenced_identifiers?
    end

    # Sponsor Identifier? Does the identifier match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def sponsor_identifier?
      result = self.identifier =~ /\ASN[0-9]{6}\z/
      !result.nil?
    end

    # Sponsor Child Identifiers? Are the child identifiers all sponsor identifiers?
    #
    # @return [Boolean] true if all identifiers match the sponsor format, otherwise false.
    def sponsor_child_identifiers?
      STFOCodeListItem.sponsor_identifier_set?(self.narrower.map {|x| x.identifier})
    end

    # Sponsor Child or Referenced Identifiers? Are the child identifiers all sponsor or referenced identifiers?
    #
    # @return [Boolean] true if all identifiers match the sponsor or referenced format, otherwise false.
    def sponsor_child_or_referenced_identifiers?
      STFOCodeListItem.sponsor_identifier_or_referenced_set?(self.narrower.map {|x| x.identifier})
    end

    # Child Identifiers. Get the child identifiers into an array
    #
    # @return [Array] array of the identifiers
    def child_identifiers
      self.narrower.map{|x| x.identifier}
    end

    # Reference. Obtain the Managed Concept from the quoted CT with the matching identifier (if present)
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def reference(ct)
      ref_ct = ct.find_by_identifiers([self.identifier])
      return nil if !ref_ct.key?(self.identifier)
      cl = self.class.find_with_properties(ref_ct[self.identifier])
      cl.narrower_objects
      cl
    end

  private

    # Add error
    def add_error(msg)
      puts colourize("#{msg}", "red")
      self.errors.add(:base, msg)
    end

    # Add error
    def add_log(msg)
      puts colourize("#{msg}", "blue")
      ConsoleLogger.info(self.class.name, "add_log", msg)
    end

  end

  class STFOCodeListItem < Thesaurus::UnmanagedConcept  

    # Sponsor Identifier Set? Check set of identifiers match the sponsor format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor format, otherwise false.
    def self.sponsor_identifier_set?(set)
      set.each {|x| return false if !sponsor_identifier_format?(x)}
      true
    end

    # Sponsor Identifier or Referenced Set? Check set of identifiers match the sponsor or referenced format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor or referenced format, otherwise false.
    def self.sponsor_identifier_or_referenced_set?(set)
      set.each {|x| return false if !sponsor_identifier_format?(x) && !sponsor_referenced_format?(x)}
      true
    end

    # Sponsor Identifier, Referenced or NCIt Set? Check set of identifiers match the sponsor or referenced format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor or referenced format, otherwise false.
    def self.sponsor_identifier_referenced_or_ncit_set?(set)
      set.each {|x| return false if !sponsor_identifier_format?(x) && !sponsor_referenced_format?(x) && !ncit_format?(x)}
      true
    end

    # Sponsor Identifier? Does the identifier match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def sponsor_identifier?
      self.class.sponsor_identifier_format?(self.identifier)
    end

    # Sponsor Identifier Format? Does a string match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def self.sponsor_identifier_format?(ident)
      result = ident =~ /\AS[0-9]{6}\z/
      !result.nil?
    end

    # Sponsor Referenced Format? Does a string match the referenced format?
    #
    # @return [Boolean] true if the identifier matches the referenced format, otherwise false.
    def self.sponsor_referenced_format?(ident)
      ident.start_with?("S") && NciThesaurusUtility.c_code?(ident[1..-1])
      #result = ident =~ /\ASC[0-9]{3..6}\z/
      #!result.nil?
    end

    # NCI Format? Does a string match the NCI format?
    #
    # @return [Boolean] true if the identifier matches the NCI format, otherwise false.
    def self.ncit_format?(ident)
      NciThesaurusUtility.c_code?(ident)
    end

  end

end