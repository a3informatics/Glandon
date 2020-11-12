# Managed Concepts Upgrade
#
# @author Clarisa Romero & Dave Iberson-hurst
# @since 2.35.0
class Thesaurus

  module Upgrade

    # Upgrade. Upgrade the instance
    #
    # @param th [Thesaurus] the new thesaurus to which the upgraded item belongs
    # @return [Thesaurus::ManagedConcept] the new item or nil if errors.
    def upgrade(th)
      return nil if !interested?
      set_type_and_references(th)
      new_item = execute
      th.replace_child(self, new_item) if !new_item.nil?
      new_item
    end

    # Upgraded?
    #
    # @param th [Thesaurus] the new thesaurus
    # @return [Boolean] return true if this instance has already been upgraded, false otherwise
    def upgraded?(th)
      return true if !interested?
      set_type_and_references(th)
      query_body = ""
      if @type == :extension
        query_body = %Q{
          BIND (EXISTS {#{@target_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends)+ #{self.uri.to_ref}} as ?x)
          BIND ("Extension" as ?a)
        }                
      elsif @type == :sponsor_subset
        query_body = %Q{
          BIND (EXISTS {#{@target_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends/^th:subsets)+ #{self.uri.to_ref}} as ?x)
          BIND ("Subset Of" as ?a)
        }          
      elsif @type == :reference_subset
        query_body = %Q{
          BIND (EXISTS {#{@target_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:subsets)+ #{self.uri.to_ref}} as ?x)
          BIND ("Subset" as ?a)
        }          
      else
        return true
      end
      query_string = %Q{
        SELECT DISTINCT ?a ?x WHERE { #{query_body} FILTER (?x = true) }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :isoT, :isoI, :bo])
      query_results.by_object(:x).any?
    end

  private  

    # Set the upgrade type and necessary references
    def set_type_and_references(th)
      @th = th
      @old_tc = set_source_tc(self.extension?)
      @type = set_type
      @new_tc = set_target_tc   
    end

    # Execute the upgrade
    def execute
      return nil if !proceed?
      return upgrade_extension(@new_tc) if @type == :extension
      return upgrade_subset(@new_tc) if @type == :sponsor_subset || :reference_subset
      Errors.application_error(self.class.name, __method__.to_s, "Only Subsets or Extensions can be upgraded.")
    end

    # Decide if we are interested in upgrading
    def interested?
      self.extension? || self.subset?
    end

    # Set the upgrade type
    def set_type
      return :extension if self.extension?
      return :sponsor_subset if self.subset? && @old_tc.owned?
      return :reference_subset if self.subset?
      :other
    end

    # Set the target TC
    def set_target_tc
      th = set_target_th
      results = th.find_identifier(@old_tc.identifier)
      Errors.application_error(self.class.name, __method__.to_s, "Cannot find target code list, identifier '#{self.identifier}'.") if results.empty?
      Thesaurus::ManagedConcept.find_minimum(results.first[:uri])
    end

    # Set source TC
    def set_source_tc(extension)
      uri = extension ? self.extends_links : self.subsets_links
      Thesaurus::ManagedConcept.find_with_properties(uri)
    end

    # Set the target Thesaurus
    def set_target_th
      if @type == :sponsor_subset
        @target_th = @th
      else
        @target_th = Thesaurus.find_minimum(@th.reference_objects.reference)
      end
      @target_th
    end

    # Proceed? Should the upgrade proceed
    def proceed?
      return true if @type != :sponsor_subset
      based_on = Thesaurus::ManagedConcept.find_with_properties(self.subsets)
      latest_uri = Thesaurus::ManagedConcept.latest_uri(identifier: based_on.identifier, scope: based_on.scope)
      return true if latest_uri != based_on.uri
      self.errors.add(:base, "Cannot upgrade. You must first upgrade the referenced code list: #{based_on.identifier}")
      false
    end

  end

end