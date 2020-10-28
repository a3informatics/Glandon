/*** Renderers for shared Strings ***/

/**
 * Returns String representation of a Concept
 * @param {Object} c Concept data object, fields: (label, identifier)
 * @return {string} Concept as a string reference
 */
function conceptRef(c) {
  return `${c.label} (${c.identifier})`;
}

/**
 * Returns String representation of an UnmangedConcept
 * @param {Object} uc UnmanagedConcept data object, fields: (notation || label, identifier)
 * @param {Object} mc ManagedConcept data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} UnmanagedConcept as a string reference
 */
function unmanagedConceptRef(uc, mc) {
  _handleNestedProperties(uc);

  return `${uc.notation || uc.label} ${uc.identifier} <span class="text-xtiny">(${managedConceptRef(mc)})</span>`;
}

/**
 * Returns String representation of a ManagedConcept
 * @param {Object} mc ManagedConcept data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} ManagedConcept as a string reference
 */
function managedConceptRef(mc) {
  _handleNestedProperties(mc);

  return `${mc.notation || mc.label} ${mc.identifier} v${mc.semantic_version}`;
}


/** Private **/


/**
 * Helper, transforms data structure by bringing semantic_version and identifier fields to object's base level from the has_identifier property
 * @param {Object} data item data object
 * @return {Object} transformed object with properties in base level
 */
function _handleNestedProperties(data) {
  if (data.has_identifier) {
    data.semantic_version = data.has_identifier.semantic_version;
    data.identifier = data.has_identifier.identifier;
  }
}

export {
  unmanagedConceptRef,
  managedConceptRef,
  conceptRef
}
