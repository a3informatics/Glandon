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

      # Find Minimum Set
      #
      # @param [Array] uris array of uris
      # @return [Array] array of objects containg the items
      def find_minimum_set(uris)
        results = []
        query_string = %Q{
          SELECT ?s ?p ?o ?e WHERE
          {
            VALUES ?e { #{uris.map{|x| x.to_ref}.join(" ")} }
            {
              ?e rdf:type ?o . 
              BIND (#{Fuseki::Base::C_RDF_TYPE.to_ref} as ?p)
              BIND (?e as ?s)
            }
            UNION
            {
              ?e ?p ?o .
              FILTER (strstarts(str(?p), "http://www.assero.co.uk/ISO11179"))
              BIND (?e as ?s)
            }
            UNION
            {
              ?e isoT:hasIdentifier ?s .
              ?s ?p ?o .
            }
            UNION
            {
              ?e isoT:hasState ?s .
              ?s ?p ?o
            }
          }
        }
        query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT, :bo, :th])
        by_subject = query_results.by_subject
        query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
          item = IsoManagedV2.from_results_recurse(uri, by_subject)
          ns_uri = item.has_identifier.has_scope
          item.has_identifier.has_scope = IsoNamespace.find(ns_uri)
          ra_uri = item.has_state.by_authority
          item.has_state.by_authority = IsoRegistrationAuthority.find(ra_uri)
          ns_uri = item.has_state.by_authority.ra_namespace
          item.has_state.by_authority.ra_namespace = IsoNamespace.find(ns_uri)
          results << item
        end
        results
      end

      # Fast Forward State. Move the items to the released state if last in version history.
      #  Checks that items are owned and last in history.
      #
      # @param [Array] uris array of uris
      # @return [Boolean] always true
      def fast_forward_state(uris)
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
            VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
            FILTER (NOT EXISTS {?s ^isoT:hasPreviousVersion ?x})
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
      #  Removes any current item settings.
      #
      # @param [Array] uris array of uris
      # @return [Boolean] always true
      def rewind_state(uris)
        sparql = %Q{
          DELETE
          {
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .          
            ?st isoR:effectiveDate ?ed .
            ?st isoR:untilDate ?ud .
          }
          INSERT
          {
            ?st isoR:registrationStatus '#{IsoRegistrationStateV2.draft_state}'^^xsd:string .
            ?st isoR:previousState ?rs .          
            ?st isoR:effectiveDate \"#{String::C_DEFAULT_DATETIME}\"^^xsd:dateTime .
            ?st isoR:untilDate \"#{String::C_DEFAULT_DATETIME}\"^^xsd:dateTime .
          }
          WHERE
          {
            VALUES ?s { #{uris.map{|x| x.to_ref}.join(" ")} }
            ?s isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
            FILTER (NOT EXISTS {?s ^isoT:hasPreviousVersion ?x})
            {
              {
                BIND (EXISTS {?s isoT:hasPreviousVersion/isoT:hasState/isoR:registrationStatus '#{IsoRegistrationStateV2.released_state}'^^xsd:string} as ?f)
              } 
              UNION
              {
                BIND (NOT EXISTS {?s isoT:hasPreviousVersion ?y} as ?f)
              }
            }
            FILTER (?f = true) 
            ?s isoT:hasState ?st .
            ?st isoR:registrationStatus ?rs .
            ?st isoR:previousState ?ps .
            ?st isoR:effectiveDate ?ed .
            ?st isoR:untilDate ?ud .
         }
        }
        Sparql::Update.new.sparql_update(sparql, "", [:isoI, :isoT, :isoR])
        true
      end

    end

    # ----------------
    # Instance Methods
    # ----------------

    # Registration Status Summary
    #
    # @param action [String] the action
    # @return [Hash] the registration summary hash
    def registration_status_summary(action)
      {
        id: self.id,
        identifier: self.scoped_identifier,
        label: self.label,
        semantic_version: self.semantic_version,
        version_label: self.version_label,
        #owner: "To Be Set",
        owner: self.owner_short_name,
        registration_status: self.registration_status,
        rdf_type: self.rdf_type.to_s,
        state_update_allowed: action.to_sym == :fast_forward ? fast_forward? : rewind?
      }
    end

    # Fast Forward? Is Fast Forward permitted?
    #
    # @return [Boolean] true if permitted, false otherwise
    def fast_forward?
      ask_query = %Q{    
        ASK {
          VALUES ?state { #{IsoRegistrationStateV2.previous_states(IsoRegistrationStateV2.released_state).map{|x| "\"#{x.to_s}\""}.join(" ")} }
          #{self.uri.to_ref} isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
          FILTER (EXISTS { #{self.uri.to_ref} isoT:hasState/isoR:registrationStatus ?state })
          FILTER (NOT EXISTS { #{self.uri.to_ref} ^isoT:hasPreviousVersion ?x })
        }
      }
      Sparql::Query.new.query(ask_query, "", [:isoT, :isoR]).ask?
    end

    # Rewind? Is Rewind permitted?
    #
    # @return [Boolean] true if permitted, false otherwise
    def rewind?
      ask_query = %Q{    
        ASK {
          #{self.uri.to_ref} isoT:hasState/isoR:byAuthority #{IsoRegistrationAuthority.owner.uri.to_ref} .
          FILTER (NOT EXISTS {#{self.uri.to_ref} ^isoT:hasPreviousVersion ?x})
          {
            {
              BIND (EXISTS {#{self.uri.to_ref} isoT:hasPreviousVersion/isoT:hasState/isoR:registrationStatus '#{IsoRegistrationStateV2.released_state}'^^xsd:string} as ?f)
            } 
            UNION
            {
              BIND (NOT EXISTS {#{self.uri.to_ref} isoT:hasPreviousVersion ?y} as ?f)
            }
          }
          FILTER (?f = true) 
        }
      }
      Sparql::Query.new.query(ask_query, "", [:isoT, :isoR]).ask?
    end

    # Update Status Permitted? Are we permitted to update the status. Default method always true.
    #
    # @return [Boolean] always returns true
    def update_status_permitted?
      true
    end

    # Update Status Dependent Items. The depedent items that we could update. Default method always return no items.
    #
    # @param params [Hash] the options to create a message with.
    # @option params [String] :with_dependencies boolean flag to use dependencies
    # @return [Array] array of items, default is just self
    def update_status_dependent_items(params)
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