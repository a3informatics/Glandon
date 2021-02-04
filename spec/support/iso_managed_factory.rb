module IsoManagedFactory
  
  def create_iso_managed(identifier, label, klass=nil)
    object = klass.nil? ? IsoManagedV2.new(label: label) : klass.new(label: label)
    ra = IsoRegistrationAuthority.owner
    object.has_identifier = IsoScopedIdentifierV2.from_h(identifier: identifier, version: 1, semantic_version: SemanticVersion.first.to_s, has_scope: ra.ra_namespace)
    object.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: "Incomplete", previous_state: "Incomplete")
    object.last_change_date = Time.now
    object.set_uris(ra)
    object.creation_date = object.last_change_date # Will have been set by set_initial, ensures the same one used.
    object.create_or_update(:create, true)
    object
  end

  def create_iso_managed_thesaurus(identifier, label)
    create_iso_managed(identifier, label, Thesaurus)
  end

end