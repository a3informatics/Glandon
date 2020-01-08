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

    # Referenced?. Is the Code List actually referencing one from the quotedf thesarus. The code list
    #   items must match the items in the referenced ManagedConcept or be a subset thereof.
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def referenced?(ct)
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = reference(ct)
      return nil if ref_ct.nil?
      return ref_ct if self.child_identifiers - ref_ct.child_identifiers == [] # self should be equal or subset of the reference 
      return nil
    end

    def extension?
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = ct.find_by_identifiers(self.identifier)
      ref_ct.narrower_objects
      others = self.child_identifiers - ref_ct.child_identifiers

    end

    # Subset? Is the entry a subset code list?
    #
    # @return [Boolean] true if a subset, false otherwise
    def subset?
      self.preferred_term.label.upcase.include? "SUBSET"
    end

    def to_subset(ct)
      new_narrower = []
      if NciThesaurusUtility.c_code?(self.identifier)
        ref_ct = reference(ct)
        self.identifier = Thesaurus::ManagedConcept.new_identifier
        self.has_identifier.identifier = self.identifier
        self.narrower.each do |child|
          new_child = ref_ct.narrower.find{|x| x.identifier == child.identifier}
          if new_child.nil?
            self.errors.add(:base, "Cannot find a code list item for a subset, identifier '#{child.identifier}'.")
          else
            new_narrower << new_child
          end
        end
      else
        self.errors.add(:base, "Subset for a non-CDISC code list detected, identifier '#{self.identifier}'.")
      end
      self
    end

    # Sponsor? Is this a sponsor code list
    #
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def sponsor?
      sponsor_identifier? && sponsor_child_identifiers?
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
      self.narrower.each {|x| return false if !x.sponsor_identifier?}
      true
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

  end

  class STFOCodeListItem < Thesaurus::UnmanagedConcept  

    # Sponsor Identifier? Does the identifier match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def sponsor_identifier?
      result = identifier =~ /\AS[0-9]{6}\z/
      !result.nil?
    end

  end

end