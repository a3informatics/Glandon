# ISO Managed Association. Methods to handle associations
#
# @author 
# @since 
class IsoManagedV2
  
  module Registration

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Filter To Owned. Filter array of ids to those owned.
      #
      # @param [Array] ids array of ids
      # @return [Array] array of URIs of the items owned
      def filter_to_owned(ids)
        return [] if ids.empty?
        query_string = %Q{
          SELECT ?s WHERE {
            VALUES ?s { #{ids.map{|x| Uri.new(id: x).to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref}
          }
        }
        query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoR])
        query_results.by_object(:s)
      end

      # Advance to Release State. Move the items to the released state if last in version history
      #
      # @param [Array] ids array of ids
      # @return [Array] array of URIs of the items updated.
      def advance_to_released_state(ids)
        ids = filter_to_owned(ids)
        return [] if ids.empty?
        sparql = %Q{
          DELETE
          {
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .
          }
          INSERT
          {
            ?st isoR:registrationStatus '#{IsoRegistrationStateV2.released_state}'^^xsd:string .
            ?st isoR:previousState ?rs .
          }
          WHERE
          {
            VALUES ?s { #{ids.map{|x| x.to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
            NOT EXISTS {?s ^isoT:hasPreviousVersion ?x} 
            ?s isoT:hasState ?st .
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .
          }
        }
        Sparql::Update.new.sparql_update(sparql, "", [:isoI, :isoT, :isoR])
        ids
      end

      def rewind_to_draft_state(ids)
        ids = filter_to_owned(ids)
        query_string= %Q{
          DELETE
          {
            ?s isoT:hasState/registrationStatus ?rs .
            ?s isoT:hasState/previousState ?ps .          }
          INSERT
          {
            ?s isoT:hasState/registrationStatus '#{IsoRegistrationStateV2.draft_state}'^^xsd:string .
            ?s isoT:hasState/previousState '#{IsoRegistrationStateV2.released_state}'^^xsd:string .          
          }
          WHERE
          {
            VALUES ?s { #{ids.map{|x| x.to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref}" .
            NOT EXISTS {?s ^isoC:previousVersion ?x} 
            {
              {
                ?s isoC:previousVersion/isoT:hasState/registrationStatus '#{IsoRegistrationStateV2.released_state}'^^xsd:string .
              } UNION
              {
                NOT EXISTS {?s isoC:previousVersion ?y} 
              }
            }
            ?s isoT:hasState/registrationStatus ?rs .
            ?s isoT:hasState/previousState ?ps .
          }
        }
        partial_update(query_string, [:isoI, :isoT])
        ids
      end

      def latest_released
      end

      def latest_drafts
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Return the registration status
    #
    # @return [string] The status
    def registration_status
      return "na" if self.has_state.nil?
      return self.has_state.registration_status
    end

    # Checks if item is regsitered
    #
    # @return [Boolean] True if registered, false otherwise
    def registered?
      return false if self.has_state.nil?
      return self.has_state.registered?
    end

    # Get the state after an edit.
    #
    # @return [string] The state.
    def state_on_edit
      return IsoRegistrationState.no_state if self.has_state.nil?
      return self.has_state.state_on_edit
    end

    # Checks if item can be the current item.
    #
    # @return [Boolean] True if can be current, false otherwise.
    def can_be_current?
      return false if self.has_state.nil?
      return self.has_state.can_be_current?
    end

  end

end