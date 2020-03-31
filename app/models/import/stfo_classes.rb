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
      return false if !NciThesaurusUtility.c_code?(self.identifier)
      return false if subset?
      ref_ct = reference(ct)
      return false if ref_ct.nil?
      return true if self.child_identifiers - ref_ct.child_identifiers == [] # self should be equal or subset of the reference 
      others = self.child_identifiers - ref_ct.child_identifiers
      add_log("Referenced check failed, the item identifiers for code list #{self.identifier} not matching are: #{others.join(", ")}") 
      false
    end

    # Future Referenced?. Is the Code List actually referencing one from a future thesarus. The code list
    #   items must match the items in the referenced ManagedConcept or be a subset thereof.
    #
    # @param [Thesaurus] ct the future reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def future_referenced?(ct)
      return false if !STFOCodeListItem.sponsor_referenced_format?(self.identifier)
      ref_ct = future_reference(ct, STFOCodeListItem.to_referenced(self.identifier))
      return false if ref_ct.nil?
      return true if self.to_referenced_child_identifiers - ref_ct.child_identifiers == [] # self should be equal or subset of the reference 
      others = self.to_referenced_child_identifiers - ref_ct.child_identifiers
      add_log("Referenced check failed, the item identifiers for code list #{self.identifier} not matching are: #{others.join(", ")}") 
      false
    end

    # Extension?. Is the Code List an extension code list?
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not an extension or the extension item.
    def extension?(ct)
      return false if !NciThesaurusUtility.c_code?(self.identifier)
      return false if subset?
      ref_ct = reference(ct)
      if !ref_ct.nil?
        ref_ct.narrower_objects
        others = self.child_identifiers - ref_ct.child_identifiers
        return true if STFOCodeListItem.sponsor_identifier_referenced_or_ncit_set?(others) and others.any?
        add_log("Extension check failed, the item identifiers for code list #{self.identifier} not matching are: #{others.join(", ")}") 
      end
      false
    end

    def to_extension(ct, fixes)
      new_narrower = []
      ref_ct = reference(ct)
      if ref_ct.nil?
        add_error("Failed to find referenced code list for an extension, identifier '#{self.identifier}'.")
      else
        self.extends = ref_ct
        new_narrower = ref_ct.narrower
        self.narrower.each do |child|
          new_child = ref_ct.narrower.find{|x| x.identifier == child.identifier}
          # If new_child is NOT nil then already in the CL being extended, nothing else to do.
          # Otherwise try and find it.
          next if !new_child.nil?
          new_child = sponsor_or_referenced(ct, child, fixes)
          next if new_child.nil?
          new_narrower << new_child 
        end
        self.narrower = new_narrower
      end
      self
    rescue => e
      add_error("Exception in to_extension, #{e}, identifier '#{self.identifier}'.")
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

    def to_subset_of_extension(extensions)
      new_narrower = []
      ext = extensions[self.identifier]
      #self.identifier = Thesaurus::ManagedConcept.new_identifier
      self.identifier = new_identifier(self.label, self.notation)
      old_narrower = self.narrower.dup
      self.narrower = []
      self.update_identifier(self.identifier) # Do early
      old_narrower.each do |child|
        new_child = find_in_cl(ext, child.identifier)
        if new_child.nil?
          add_error("Subset of extension, cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      self.subsets = ext
      self.add_ordering
      self
    rescue => e
      add_error("Exception in to_subset_of_extension, #{e}, identifier '#{self.identifier}'.")
      nil
    end

    def add_ordering
      subset = Thesaurus::Subset.new
      subset.uri = subset.create_uri(self.uri)
      previous = nil
      self.narrower.each do |child| 
        sm = Thesaurus::SubsetMember.new
        sm.item = child
        sm.uri = sm.create_uri(subset.uri)
        previous.nil? ? subset.members = sm : previous.member_next = sm
        previous = sm
      end
      self.is_ordered = subset
      nil
    rescue => e
      add_error("Exception in add_ordering, #{e}, identifier '#{self.identifier}'.")
      nil
    end

    def to_cdisc_subset(ct)
      return nil if !NciThesaurusUtility.c_code?(self.identifier)
      ref_ct = reference(ct) # do early before identifier updated.
      new_narrower = []
      #self.identifier = Thesaurus::ManagedConcept.new_identifier
      self.identifier = new_identifier(self.label, self.notation)
      old_narrower = self.narrower.dup
      self.narrower = []
      self.update_identifier(self.identifier)
      old_narrower.each do |child|
        new_child = find_in_cl(ref_ct, child.identifier)
        if new_child.nil?
          add_error("CDISC Subset, cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      self.subsets = ref_ct
      self.add_ordering
      self
    rescue => e
      add_error("Exception in to_cdisc_subset, #{e}, identifier '#{self.identifier}'.")
      nil
    end

    def to_sponsor_subset(sponsor_ct)
      ref_ct = sponsor_ct.find{|x| x.identifier == self.identifier}
      return nil if ref_ct.nil?
      new_narrower = []
      #self.identifier = Thesaurus::ManagedConcept.new_identifier
      self.identifier = new_identifier(self.label, self.notation)
      old_narrower = self.narrower.dup
      self.narrower = []
      self.update_identifier(self.identifier)
      old_narrower.each do |child|
        new_child = find_in_cl(ref_ct, child.identifier)
        if new_child.nil?
          add_error("Sponsor subset, cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      self.subsets = ref_ct
      self.add_ordering
      self
    rescue => e
      add_error("Exception in to_sponsor_subset, #{e}, identifier '#{self.identifier}'.")
      nil
    end

    def to_existing_subset
      refs = Thesaurus::ManagedConcept.where(identifier: self.identifier)
      return nil if refs.empty?
      ref_ct = Thesaurus::ManagedConcept.find_full(refs.first.uri)
      tcs = Thesaurus::ManagedConcept.where(notation: self.notation)
      tc = tcs.empty? ? nil : tcs.first
      new_narrower = []
      self.identifier = tc.nil? ? Thesaurus::ManagedConcept.new_identifier : tc.identifier
      old_narrower = self.narrower.dup
      self.narrower = []
      self.update_identifier(self.identifier)
      old_narrower.each do |child|
        new_child = find_in_cl(ref_ct, child.identifier)
        if new_child.nil?
          add_error("Sponsor subset, cannot find a code list item, identifier '#{child.identifier}', for a subset '#{self.identifier}'.")
        else
          new_narrower << new_child
        end
      end
      self.narrower = new_narrower
      self.subsets = ref_ct
      self.add_ordering
      self
    rescue => e
      add_error("Exception in to_existing_subset, #{e}, identifier '#{self.identifier}'.")
      nil
    end

    # Sponsor? Is this a sponsor code list
    #
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def sponsor?
      return nil if subset?
      sponsor_parent_identifier? && sponsor_child_identifiers?
    end

    # Hybrid Sponsor? Is this a hybrid sponsor code list
    #
    # @return [Boolean] true if a hybrid sponsor code list, false otherwise.
    def hybrid_sponsor?
      return nil if subset?
      sponsor_parent_identifier? && sponsor_child_or_referenced_identifiers?
    end

    # Future Hybrid Sponsor? Is this a hybrid sponsor code list
    #
    # @return [Boolean] true if a hybrid sponsor code list, false otherwise.
    def future_hybrid_sponsor?
      return nil if subset?
      STFOCodeListItem.sponsor_referenced_format?(self.identifier) && sponsor_child_or_referenced_identifiers?
    end

    def to_hybrid_sponsor(ct, fixes)
      new_narrower = []
      self.narrower.each do |child|
        new_child = sponsor_or_referenced(ct, child, fixes)
        next if new_child.nil?
        new_narrower << new_child 
      end
      self.narrower = new_narrower
      self
    rescue => e
      add_error("Exception in to_hybrid_sponsor, identifier '#{self.identifier}'.")
      self
    end

    def sponsor_or_referenced(ct, child, fixes)
      if STFOCodeListItem.sponsor_referenced_format?(child.identifier)
        item = find_sponsor_referenced(ct, child, fixes)
        return item.nil? ? child : item
      elsif NciThesaurusUtility.c_code?(child.identifier)
        item = find_referenced(ct, child.identifier, child, fixes)
        return item.nil? ? nil : item
      else
        return child
      end
    end

    def find_sponsor_referenced(ct, child, fixes)
      find_referenced(ct,  STFOCodeListItem.to_referenced(child.identifier), child, fixes)
    end

    def find_referenced(ct, identifier, child, fixes)
      result = override(ct, identifier, child, fixes)
      return result if !result.nil?
      result = exact_match(ct, identifier)
      return result if !result.nil?
      options = ct.find_identifier(identifier)
      if options.empty?
        # See if we can find anything in the future
        item = future_reference(ct, identifier)
        if item.nil?
          add_error("Cannot find referenced item '#{identifier}', none found, identifier '#{self.identifier}'.")
          return nil
        else
          add_log ("**** Found future referenced item '#{identifier}', identifier '#{self.identifier}'.")
          return child # We return the imported child item, not the one found
        end
      elsif options.count == 1
        if options.first[:rdf_type] == Thesaurus::UnmanagedConcept.rdf_type.to_s
          result = Thesaurus::UnmanagedConcept.find_children(options.first[:uri])
          add_warning("Fix notation mismatch, fix '#{result.notation}' '#{result.identifier}' versus reqd '#{child.notation}' '#{child.identifier}', identifier '#{self.identifier}'.") if result.notation != child.notation       
          return result 
        else
          add_error("Cannot find referenced item incorrect type, identifier '#{self.identifier}'.")
          return nil
        end
      else
        option = matching_notation(child, options)
        return option if !option.nil?
        uri = fixes.qualify(self.identifier, identifier)
        if !uri.nil?
          result = Thesaurus::UnmanagedConcept.find_children(uri)
          add_warning("Fix notation mismatch, fix '#{result.notation}' '#{result.identifier}' versus reqd '#{child.notation}' '#{child.identifier}', identifier '#{self.identifier}'.") if result.notation != child.notation       
          return result 
        else
          add_error("Cannot find referenced item '#{identifier}', multiple found, identifier '#{self.identifier}'. Found #{ options.map{|x| x[:uri].to_s}.join(", ")} and no fix.")
          return nil
        end
      end
    rescue => e
      add_error("Exception in find_referenced: #{e}, identifier '#{self.identifier}'.")
      nil
    end

    def override(ct, identifier, child, fixes)
      return child if fixes.override?(self.identifier, child.identifier)
    end

    def exact_match(ct, identifier)
      results = ct.find_by_identifiers([self.identifier, identifier])
      return Thesaurus::UnmanagedConcept.find(results[identifier]) if results.key?(identifier)
      add_log ("**** Failed to find exact match '#{identifier}', identifier '#{self.identifier}'.")
      nil
    end

    def matching_notation(child, options)
      results = []
      options.each do |x|
        possibility = Thesaurus::UnmanagedConcept.find_children(x[:uri])
        msg = child.notation == possibility.notation ? "Notation match found" : "Notation not matched"
        msg = "#{msg} '#{child.notation}', '#{possibility.notation}', identifier '#{self.identifier}'"
        add_log(msg)
        results << possibility if child.notation == possibility.notation
      end
      return results.first if results.count == 1
      nil
    end

    def find_in_cl(cl, identifier)
      item = cl.narrower.find{|x| x.identifier == identifier}
      return item if !item.nil?
      item = cl.narrower.find{|x| x.identifier == STFOCodeListItem.to_referenced(identifier)} if STFOCodeListItem.sponsor_referenced_format?(identifier)
      item
    end

    # Sponsor Identifier? Does the identifier match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def sponsor_parent_identifier?
      STFOCodeListItem.sponsor_parent_identifier_format?(self.identifier)
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

    def to_referenced_child_identifiers
      self.narrower.map{|x|  STFOCodeListItem.to_referenced(x.identifier)}
    end

    # Reference. Obtain the Managed Concept from the quoted CT with the matching identifier (if present)
    #
    # @param [Thesaurus] ct the reference thesaurus
    # @return [Thesaurus::ManagedConcept] either nil if not found or the Managed Concept found.
    def reference(ct)
      ref_ct = ct.find_by_identifiers([self.identifier])
      return nil if !ref_ct.key?(self.identifier)
      self.class.find_full(ref_ct[self.identifier])
    end

    def future_reference(ct, identifier)
      items = find_any_referenced(ct, identifier)
      return nil if items.empty?
      self.class.find_full(items.first[:uri])
    end

    def subset_list
      results = []
      save_next(results, self.is_ordered.members)
      results
    end

    def subset_list_equal?(subset)
      other = subset.list_uris.map {|x| x[:uri].to_s}
      this = subset_list.map {|x| x.to_s}
      return other - this == [] && this - other == []
    rescue => e
      add_error("Exception in subset_list_equal?")
    end

  private

    def find_any_referenced(ct, identifier)
      results = {}
      query_string = %Q{
        SELECT ?s ?th ?v WHERE 
        {
          ?s th:identifier "#{identifier}" .
          ?th th:isTopConceptReference/bo:reference/th:narrower ?s .
          ?th isoT:hasIdentifier/isoI:version ?v .
          FILTER (?v > #{ct.version})
        } ORDER BY ?v
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoT, :isoI])
      triples = query_results.by_object_set([:s, :th, :v]).map{|x| {uri: x[:s], version: x[:v]}}
    end

    # Find a new identifier. Match on label and notaiton or generate a new one.
    def new_identifier(label, notation)
      results = Thesaurus::ManagedConcept.where(label: label, notation: notation)
      if results.empty?
        Thesaurus::ManagedConcept.new_identifier
      elsif results.count == 1
        return results.first.identifier
      else
        add_error("Found multiple matching labels/notation for new identifier, identifier #{self.identifier}")
      end
    rescue => e
      add_error("Exception in new_identifier, #{e}. Label: #{label}, identifier: #{identifier}.")
    end

    # Add error
    def add_error(msg)
      puts colourize("#{msg}", "red")
      self.errors.add(:base, msg)
    end

    # Add log
    def add_log(msg)
      puts colourize("#{msg}", "blue")
      ConsoleLogger.info(self.class.name, "add_log", msg)
    end

    # Add warning / annotation
    def add_warning(msg)
      puts colourize("#{msg}", "yellow")
      ConsoleLogger.info(self.class.name, "add_warning", msg)
      self.errors.add(:base, msg)
    end

    def save_next(results, member)
      return if member.nil?
      results << member.item
      save_next(results, member.member_next)
    end

  end

  class STFOCodeListItem < Thesaurus::UnmanagedConcept  

    # Sponsor Identifier Set? Check set of identifiers match the sponsor format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor format, otherwise false.
    def self.sponsor_identifier_set?(set)
      set.each {|x| return false if !sponsor_child_identifier_format?(x)}
      true
    end

    # Sponsor Identifier or Referenced Set? Check set of identifiers match the sponsor or referenced format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor or referenced format, otherwise false.
    def self.sponsor_identifier_or_referenced_set?(set)
      set.each {|x| return false if !sponsor_child_identifier_format?(x) && !sponsor_referenced_format?(x)}
      true
    end

    # Sponsor Identifier, Referenced or NCIt Set? Check set of identifiers match the sponsor or referenced format
    #
    # @return [Boolean] true if the set of identifier matches the sponsor or referenced format, otherwise false.
    def self.sponsor_identifier_referenced_or_ncit_set?(set)
      set.each {|x| return false if !sponsor_child_identifier_format?(x) && !sponsor_referenced_format?(x) && !ncit_format?(x)}
      true
    end

    # Sponsor Identifier Format? Does a string match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def self.sponsor_parent_identifier_format?(ident)
      result = ident =~ /\ASN[0-9]{6}\z/
      !result.nil?
    end

    # Sponsor Identifier Format? Does a string match the sponsor format?
    #
    # @return [Boolean] true if the identifier matches the sponsor format, otherwise false.
    def self.sponsor_child_identifier_format?(ident)
      result = ident =~ /\AS[0-9]{6}\z/
      !result.nil?
    end

    # Sponsor Referenced Format? Does a string match the referenced format?
    #
    # @return [Boolean] true if the identifier matches the referenced format, otherwise false.
    def self.sponsor_referenced_format?(ident)
      ident.start_with?("S") && NciThesaurusUtility.c_code?(ident[1..-1])
    end

    # To Referenced. Takes a Sponsor reference format and converts to the referenced format
    #
    # @return [Boolean] true if the identifier matches the referenced format, otherwise false.
    def self.to_referenced(ident)
      ident.dup[1..-1]
    end

    # NCI Format? Does a string match the NCI format?
    #
    # @return [Boolean] true if the identifier matches the NCI format, otherwise false.
    def self.ncit_format?(ident)
      NciThesaurusUtility.c_code?(ident)
    end

  end

end