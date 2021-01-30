# Thesaurus Custom Property
#
# @author Dave Iberson-Hurst
# @since 3.4.0
class Thesaurus

  module ThRegistrationStatus

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # Update Status Permitted? Are we permitted to update the status. Default method always true.
    #
    # @return [Boolean] always returns true
    def update_status_permitted?
      (managed_children_states & IsoRegistrationStateV2.previous_states(self.registration_status)).empty?
    end

    # Managed Children States.
    #
    # @return [Array] array of states for the children
    def managed_children_states
      query_string = %Q{
        SELECT ?s WHERE
        {
          #{self.uri.to_ref} th:isTopConceptReference/bo:reference/isoT:hasState/isoR:registrationStatus ?s .
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :bo, :isoT, :isoR])
      query_results.by_object_set([:s]).map{|x| x[:s].to_sym}
    end

  end

end