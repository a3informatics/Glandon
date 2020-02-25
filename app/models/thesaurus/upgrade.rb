
# Managed Concepts Upgrade
#
# @author Clarisa Romero & Dave Iberson-hurst
# @since 2.35.0
class Thesaurus

  module Upgrade

    def upgrade(th)
      set_type_and_references(th)
      execute
    end

    # Upgraded?
    #
    # @param new_th [Thesaurus] the new thesaurus
    # @return [Boolean] return true if this instance has already been upgraded, false otherwise
    def upgraded?(new_th)
      query_string = %Q{
        SELECT DISTINCT ?a ?x WHERE              
        {               
          {
            BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends)+ #{self.uri.to_ref}} as ?x)
            BIND ("Extension" as ?a)
          }                
          UNION               
          {
            BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends/^th:subsets)+ #{self.uri.to_ref}} as ?x)
            BIND ("Subset of extension" as ?a)
          }                
          UNION               
          {
            BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:subsets)+ #{self.uri.to_ref}} as ?x)
            BIND ("Subset" as ?a)
          }          
          UNION               
          {
            BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference)+ #{self.uri.to_ref}} as ?x)
            BIND ("Code List" as ?a)
          }
          FILTER (?x = true)
        } 
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :isoT, :isoI, :bo])
      query_results.by_object(:x).any?
    end

  private  

    # Set the upgrade type and necessary references
    def set_type_and_references(th)
      @th = th
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

    # Set the upgrade type
    def set_type
      return :extension if self.is_extensible?
      return :sponsor_subset if self.is_subset? && self.subsets.owner == owner
      :reference_subset
    end

    # Set the target TC
    def set_target_tc
      th = set_target_th
      results = th.find_identifier(self.identifier)
      Errors.application_error(self.class.name, __method__.to_s, "Cannot find target code list, identifier 'self.identifier'.") if results.empty?
      Thesaurus::ManagedConcept.find_minimum(results.first[:uri])
    end

    # Set the target Thesaurus
    def set_target_th
      if @type == :sponsor_subset
        @target_th = @th
      else
        @th.reference_objects
        @target_th = @th.reference.reference
      end
    end

    # Proceed? Should the upgrade proceed
    def proceed?
      return true if @type != :reference_subset
      based_on = self.subsets
      latest_uri = Thesaurus::ManagedConcept.latest_uri(identifier: based_on.identifier, scope: based_on.scope)
      return true if latest_uri == based_on.uri
      self.errors.add(:base, "Cannot upgrade. You must first upgrade the referenced code list: #{based_on.identifier}")
      false
    end

  end

end