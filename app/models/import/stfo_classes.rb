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

    def sponsor?
      sponsor_cl_identifer(self) && sponsor_cli_identifers?(self)
    end

    def extension?
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = ct.find_by_identifiers(self.identifier)
      ref_ct.narrower_objects
      others = ref_ct.child_identifiers - self.child_identifiers

    end

    def subset?
      self.preferred_term.upcase.end_with? "SUBSET"
    end

    def sponsor?
      self.sponsor_identifer? && self.sponsor_child_identifers?
    end

    def sponsor_identifier?
      self.identifier =~ /\ASN[0-9]{6}\z/
    end

    def sponsor_child_identifiers?
      self.narrower{|x| return false if !x.owned_identifier?}
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

    def sponsor_identifier?
      identifier =~ /\AS[0-9]{6}\z/
    end

  end

end