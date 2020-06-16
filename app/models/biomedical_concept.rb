class BiomedicalConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept"

  object_property :has_item, cardinality: :many, model_class: "BiomedicalConcept::Item", children: true
  object_property :identified_by, cardinality: :one, model_class: "BiomedicalConcept::Item"

  # # Upgrade an item
  # #
  # # @raise [UpdateError or CreateError] if object not updated/created.
  # # @return [Object] The BC created. Includes errors if failed.
  # def upgrade
  #   term_map = Hash.new
  #   thesauri = Thesaurus.unique
  #   thesauri.each do |item|
  #     params = {:identifier => item[:identifier], :scope_id => item[:owner_id]}
  #     history = Thesaurus.history(params)
  #     update_uri = nil?
  #     history.each do |item|
  #       update_uri = item.uri if item.current?
  #     end
  #     if update_uri.nil?
  #       history.each do |item|
  #         term_map[item.uri.to_s] = {:update => !item.current?, :namespace => update_uri.namespace}
  #       end
  #     end
  #   end
  #   ConsoleLogger::log(C_CLASS_NAME,"upgrade","term_map=" + term_map.to_json.to_s)
    
  #   proceed = true
  #   operational_hash = self.to_operation
  #   ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON=#{operational_hash}")
  #   mi = operational_hash[:managed_item]
  #   mi[:children].each do |child|
  #     child[:tc_refs].each do |term_ref|
  #       if term_map[term_ref[:namespace]][:update]
  #         id = term_ref[:subject_ref][:id]
  #         ns_old = term_ref[:subject_ref][:namespace]
  #         ns_new = term_map[term_ref[:subject_ref][:namespace]][:namespace]
  #         old_cli = ThesaurusConcept.find(id, ns_old)
  #         new_cli = ThesaurusConcept.find(id, ns_new)
  #         ConsoleLogger::log(C_CLASS_NAME,"upgrade","Old CLI=" + old_cli.to_json.to_s)
  #         ConsoleLogger::log(C_CLASS_NAME,"upgrade","New CLI=" + new_cli.to_json.to_s)
  #         if ThesaurusConcept.diff?(old_cli, new_cli)
  #           proceed = false
  #         end
  #       end
  #     end
  #   end
    
  #   ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON=#{operational_hash}")
  #   if proceed
  #     mi[:children].each do |child|
  #       child[:tc_refs].each do |term_ref|
  #         if term_map[term_ref[:namespace]][:update]
  #           term_ref[:subject_ref][:uri_ns] = term_map[term_ref[:subject_ref][:namespace]][:namespace]
  #         end
  #       end
  #     end
  #     ConsoleLogger::log(C_CLASS_NAME,"upgrade","JSON=#{operational_hash}")
  #     if operational_hash[:operation][:action] == "CREATE"
  #       BiomedicalConcept.create(operational_hash)
  #     else
  #       BiomedicalConcept.update(operational_hash)
  #     end
  #   end
  # end

  # # Get Properties
  # #
  # # @param references [Boolean] True to fill in terminology references, ignore otherwise.
  # # @return [Hash] Full managed item has including array of child properties.
  # def get_properties(references=false)
  #   managed_item = super()
  #   if references
  #     managed_item[:children].each do |child|
  #       child[:children].each do |ref|
  #         tc = Thesaurus::UnmanagedConcept.find_children(Uri.new(namespace: ref[:subject_ref][:namespace], fragment:ref[:subject_ref][:id]))
  #         ref[:subject_data] = tc.to_json if !tc.nil?
  #       end
  #     end
  #   end
  #   return managed_item
  # end

  # # Get Unique References
  # #
  # # @param managed_item [Hash] The full propeties hash with references
  # # @return [Array] Array of unique terminology references (each is a hash)
  # def self.get_unique_references(managed_item)
  #   map = {}
  #   results = []
  #   managed_item[:children].each do |child|
  #     child[:children].each do |ref|
  #       uri = UriV2.new({id: ref[:subject_ref][:id], namespace: ref[:subject_ref][:namespace]})
  #       if !map.has_key?(uri.to_s)
  #         if !ref[:subject_data].blank?
  #           parent = IsoManaged.find_managed(ref[:subject_ref][:id], ref[:subject_ref][:namespace])
  #           if !parent[:uri].blank?
  #             th = IsoManaged.find(parent[:uri].id, parent[:uri].namespace, false)
  #           end
  #           ref[:subject_data][:parent] = th.to_json
  #           results << ref[:subject_data] 
  #         end
  #         map[uri.to_s] = true
  #       end
  #     end
  #   end
  #   return results
  # end

  # # Domains: Find all domains the BC is linked with
  # #
  # # @return [Array] array of URis of the linked domains
  # def domains
  #   results = []
  #   query = UriManagement.buildNs(namespace, ["isoI", "isoC", "bd", "bo"]) +
  #     "SELECT ?a WHERE \n" +
  #     "{ \n" +
  #     "  ?a rdf:type #{SdtmUserDomain::C_RDF_TYPE_URI.to_ref} . \n" +
  #     "  ?a bd:hasBiomedicalConcept ?or . \n" +
  #     "  ?or bo:hasBiomedicalConcept #{self.uri.to_ref} . \n" +
  #     "}"
  #   response = CRUD.query(query)
  #   xmlDoc = Nokogiri::XML(response.body)
  #   xmlDoc.remove_namespaces!
  #   xmlDoc.xpath("//result").each {|node| results << UriV3.new(uri: ModelUtility.getValue('a', true, node))}
  #   return results
  # end

end
