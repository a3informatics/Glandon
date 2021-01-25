module IsoManagedFactory
  
  def create_iso_managed(identifier, label)
    object = new(label: label)
    ra = IsoRegistrationAuthority.owner
    object.has_identifier = IsoScopedIdentifierV2.from_h(identifier: identifier, version: 1, semantic_version: SemanticVersion.first.to_s, has_scope: ra.ra_namespace)
    object.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: "Incomplete", previous_state: "Incomplete")
    object.last_change_date = Time.now
    set_uris(ra)
    object.creation_date = object.last_change_date # Will have been set by set_initial, ensures the same one used.
    object.create_or_update(:create, true)
    object
  end

end