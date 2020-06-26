class BiomedicalConcept < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#BiomedicalConcept"

  object_property :has_item, cardinality: :many, model_class: "BiomedicalConcept::Item", children: true
  object_property :identified_by, cardinality: :one, model_class: "BiomedicalConcept::Item"

  # Get Properties
  #
  # @return [Array] Array of hashes, one per property.
  def get_properties(references=false)
    results = []
    instance = self.class.find_full(self.id)
    if references
      instance.has_item.each do |item|
        item.has_complex_datatype.each do |cdt|
          cdt.has_property.each do |property|
            if !property.has_coded_value.empty?
              property.has_coded_value.each do |coded_value|
                tc = OperationalReferenceV3::TucReference.find_children(coded_value.reference)
                results << {uri: item.uri.to_s, id: item.id, label: item.label, mandatory:item.mandatory, collect:item.collect, enabled:item.enabled, ordinal:item.ordinal, 
                has_complex_datatype: cdt.label, has_property: property.to_h, coded_value: "#{tc.notation} (#{tc.identifier})" }
              end
            else
              results << {uri: item.uri.to_s, id: item.id, label: item.label, mandatory:item.mandatory, collect:item.collect, enabled:item.enabled, ordinal:item.ordinal, 
                has_complex_datatype: cdt.label, has_property: property.to_h, coded_value: "" } 
            end
          end
        end
      end
    end
    return results
  end

  # Get Unique References
  
  # @param managed_item [Hash] The full properties hash with references
  # @return [Array] Array of unique terminology references (each is a hash)
  # def self.get_unique_references(managed_item)
  #   map = {}
  #   results = []
  #   instance[:has_item].each do |item|
  #         item[:has_complex_datatype].each do |cdt|
  #           cdt[:has_property].each do |prop|
  #             prop[:has_coded_value].each do |coded_value|
  #               uri = Uri.new(uri: coded_value[:reference][:uri]) #URI UC
  #               if !map.has_key?(uri.to_s)
  #                 parent = IsoManagedV2.current_and_latest_parent(uri) #MC
  #                 #if !parent[:uri].blank?
  #                   th = IsoManagedV2.find(parent[:uri].id) #TH
  #                   Thesaurus.find_minimum(edit_params[:parent_id])
  #                   object.current_and_latest_parent.last[:uri].to_id
  #                 #end
  #                 ref[:subject_data][:parent] = th.to_json
  #                 results << ref[:subject_data] 
  #               #tc = OperationalReferenceV3::TucReference.find_children(Uri.new(uri: coded_value[:reference]))
  #               #cv[:reference] = tc.to_h if !tc.nil?
  #               end
  #             end
  #           end
  #         end
  #       end
  #   # managed_item[:children].each do |child|
  #   #   child[:children].each do |ref|
  #   #     uri = UriV2.new({id: ref[:subject_ref][:id], namespace: ref[:subject_ref][:namespace]})
  #   #     if !map.has_key?(uri.to_s)
  #   #       if !ref[:subject_data].blank?
  #   #         parent = IsoManaged.find_managed(ref[:subject_ref][:id], ref[:subject_ref][:namespace])
  #   #         if !parent[:uri].blank?
  #   #           th = IsoManaged.find(parent[:uri].id, parent[:uri].namespace, false)
  #   #         end
  #   #         ref[:subject_data][:parent] = th.to_json
  #   #         results << ref[:subject_data] 
  #   #       end
  #   #       map[uri.to_s] = true
  #   #     end
  #   #   end
  #   # end
  #   return results
  # end

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
