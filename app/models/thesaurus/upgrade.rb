
class Thesaurus

  module Upgrade

    def upgrade(th)
      init(th, self)
      execute
    end

    # Upgraded?
    #
    # @param new_th [Thesaurus] the new thesaurus
    # @return [Boolean] return true if this instance has already been upgraded, false otherwise
    def upgraded?(new_th)
      query_string = %Q{
        SELECT DISTINCT (count(?a) AS ?count)
        WHERE 
        { 
            SELECT DISTINCT ?a ?x WHERE              
            {               
              {
              BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends)+ #{self.uri.to_ref}  . }  
                as ?x)
              BIND ("Extension" as ?a)
              }                
              UNION               
              {
              BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:extends/^th:subsets)+ #{self.uri.to_ref}  .}    as ?x)
              BIND ("Subset of extension" as ?a)
              }                
              UNION               
              {
              BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference/^th:subsets)+ #{self.uri.to_ref}  .} as ?x)
              BIND ("Subset" as ?a)
              }          
              UNION               
              {
              BIND (EXISTS {#{new_th.uri.to_ref} (th:isTopConceptReference/bo:reference)+ #{self.uri.to_ref}  .} as ?x)
              BIND ("Code List" as ?a)
              }
            FILTER (?x = true)
          } 
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :isoT, :isoI, :bo])
      count = query_results.by_object(:count)
      return count[0] == "0" ? false : true
    end

    # Upgrade?
    #
    # @param source_id [Thesaurus::ManagedConcept] source id
    # @param new_th [Thesaurus::ManagedConcept] new_th
    # @return [Hash] 
    def upgrade?(source_id, new_th)
      results = {upgrade: false, errors: ""}
      if self.upgraded?(new_th)
        results[:errors] = "Item already upgraded"
      elsif !self.subset_of.nil?
        if subset_of.to_id == source_id
          results[:upgrade] = true
        else
          sponsor_tc = Thesaurus::ManagedConcept.find_full(self.subset_of)
          latest_uri = Thesaurus::ManagedConcept.latest_uri(identifier: sponsor_tc.identifier, scope: sponsor_tc.scope)
          if latest_uri == sponsor_tc.uri
            results[:errors] = "Cannot upgrade. You must first upgrade Code List: #{sponsor_tc.identifier}"
          else
            results[:upgrade] = true
          end 
        end
      else
        if !self.extension_of.nil?
          if extension_of.to_id == source_id 
            results[:upgrade] = true
          end
        end
      end
      results
    end

  private  

    def init(th, tc)
      @th = th
      @tc = tc
      @type = set_type
      @new_tc = set_target_tc   
    end

    def execute
      return upgrade_extension(@new_tc) if @type == :extension
      return upgrade_subset(@new_tc) if @type == :sponsor_subset || :ref_subset
      Errors.application_error(self.class.name, __method__.to_s, "Only Subsets or Extensions can be upgraded.")
    end

    def set_type
      return :extensible if @tc.is_extensible?
      return :sponsor_subset @tc.is_subset? and @tc.subsets.owner == owner
      :ref_subset
    end

    def set_target_tc
      th = set_target_th
      results = th.find_identifier(@tc.identifier)
      Errors.application_error(self.class.name, __method__.to_s, "Only Subsets or Extensions can be upgraded.") if results.empty?
      Thesaurus::ManagedConcept(results.first[:uri])
    end

    def set_target_th
      if @type == :sponsor_subset
        @target_th = @th
      else
        @th.reference_objects
        @target_th = @th.reference.reference
      end
    end

    def proceed?
      return true if @type != :ref_subset
      # Check upgraded.
    end

  end

end