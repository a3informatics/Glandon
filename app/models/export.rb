class Export

  # Terminologies. Get list of owner sponsor terminologies.
  #
  # @return [Array] An array of entries
  def terminologies
    collection(Thesaurus.all)
  end

  # Biomedical Concepts. Get list of owner sponsor BCs.
  #
  # @return [Array] An array of entries
  def biomedical_concepts
    collection(BiomedicalConcept.all)
  end

  # Forms. Get list of owner sponsor forms.
  #
  # @return [Array] An array of entries
  def forms
    collection(Form.all)
  end

private

  # Build the list
  def collection(item_list)
    repos_owner = IsoRegistrationAuthority.owner
    item_list = item_list.select { |th| th.owner.uri.to_s == repos_owner.uri.to_s } # Don't export non-owner items
    item_list.each_with_object([]) do |l, results| 
      uri = UriV3.new(fragment: l.id, namespace: l.namespace)
      results << { identifier: l.identifier, label: l.label, semantic_version: l.semantic_version.to_s, version: l.version, 
        url: Rails.application.routes.url_helpers.export_iso_managed_path(uri.to_id) }
      results 
    end
  end

end