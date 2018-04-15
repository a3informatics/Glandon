class Export

  def terminologies
    collection(Thesaurus.all)
  end

  def biomedical_concepts
    collection(BiomedicalConcept.all)
  end

  def forms
    collection(Form.all)
  end

private

  def collection(item_list)
    item_list = item_list.select { |th| th.owner == IsoRegistrationAuthority.owner.shortName } # Don't export non-owner items
    item_list.each_with_object([]) do |l, results| 
      uri = UriV3.new(fragment: l.id, namespace: l.namespace)
      results << { identifier: l.identifier, label: l.label, semantic_version: l.semantic_version.to_s, version: l.version, 
        url: Rails.application.routes.url_helpers.export_iso_managed_path(uri.to_id) }
      results 
    end
  end

end