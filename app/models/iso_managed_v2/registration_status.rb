# ISO Managed Association. Methods to handle associations
#
# @author 
# @since 
class IsoManagedV2
  
  module RegistrationStatus

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # # Filter To Owned. Filter array of ids to those owned.
      # #
      # # @param [Array] ids array of ids
      # # @return [Array] array of URIs of the items owned
      # def filter_to_owned(ids)
      #   return [] if ids.empty?
      #   query_string = %Q{
      #     SELECT ?s WHERE {
      #       VALUES ?s { #{ids.map{|x| Uri.new(id: x).to_ref}.join(" ")} }
      #       ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref}
      #     }
      #   }
      #   query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoR])
      #   query_results.by_object(:s)
      # end

      # Fast Forward State. Move the items to the released state if last in version history.
      #  Checks that items are owned and last in history.
      #
      # @param [Array] ids array of ids
      # @return [Boolean] always true
      def fast_forward_state(ids)
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
            VALUES ?s { #{ids.map{|x| Uri.new(id: x).to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
            NOT EXISTS {?s ^isoT:hasPreviousVersion ?x} 
            ?s isoT:hasState ?st .
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .
          }
        }
        Sparql::Update.new.sparql_update(sparql, "", [:isoI, :isoT, :isoR])
        true
      end

      # Rewind State. Move the items to the draft state if last in version history.
      #  Checks that items are owned and last in history and no other versions since last release.
      #
      # @param [Array] ids array of ids
      # @return [Boolean] always true
      def rewind_state(ids)
        sparql = %Q{
          DELETE
          {
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .          
          }
          INSERT
          {
            ?st isoR:registrationStatus '#{IsoRegistrationStateV2.draft_state}'^^xsd:string .
            ?st isoR:previousState '#{IsoRegistrationStateV2.released_state}'^^xsd:string .          
          }
          WHERE
          {
            VALUES ?s { #{ids.map{|x| Uri.new(id: x).to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
            {
              {
                ?s isoT:hasPreviousVersion/isoT:hasState/isoR:registrationStatus '#{IsoRegistrationStateV2.released_state}'^^xsd:string .
              } 
              UNION
              {
                NOT EXISTS {?s ^isoT:hasPreviousVersion ?x} 
              }
            }
            ?s isoT:hasState ?st .
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .
          }
        }
        Sparql::Update.new.sparql_update(sparql, "", [:isoI, :isoT, :isoR])
        true
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Update Status Permitted? Are we permitted to update the status. Default method always true.
    #
    # @return [Boolean] always returns true
    def update_status_permitted?
      true
    end

    # Update Status Related Items. The related items that we could update. Default methid always return no items.
    #
    # @return [Array] array of items, default is empty
    def update_status_related_items(flag, operation)
      []
    end

    # Status Summary. A status summary hash
    #
    # @return [hash] the status hash
    def status_summary
      state = self.has_state.registration_status
      next_state = IsoRegistrationStateV2.next_state(state)
      {
        state: { 
          label: IsoRegistrationStateV2.state_label(state),
          definition: IsoRegistrationStateV2.state_definition(state)
        },
        next_state: {
          label: IsoRegistrationStateV2.state_label(next_state),
          definition: IsoRegistrationStateV2.state_definition(next_state)
        },
        semantic_version: {
          label: self.semantic_version,
          editable: self.latest? && self.has_state.update_release?,
          next_versions: SemanticVersion.from_s(self.previous_release).next_versions
        },
        current: self.current?,
        version_label: self.version_label
      }
    end

    # Update State. Update the status.
    #
    # @params [Hash] params the parameters
    # @option params [String] registration, the new state
    # @return [Void] no return
    def next_state(params)
      state = self.has_state.registration_status
      params[:registration_status] = IsoRegistrationStateV2.next_state(state)
      params[:previous_state] = state
      params[:multiple_edit] = false
      self.has_state.update(params)
      merge_errors(self.has_state, "State")
    end

    # Audit Message Status Update
    #
    # @return [String] the audit message
    def audit_message_status_update
      "#{self.audit_type} owner: #{self.owner_short_name}, identifier: #{self.scoped_identifier}, state was updated from #{self.has_state.previous_state} to #{self.has_state.registration_status}."
    end

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