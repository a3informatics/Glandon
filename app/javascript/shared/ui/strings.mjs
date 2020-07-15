/*** Renderers for shared Strings ***/

/**
 * Returns String representation of an UnmangedConcept
 * @param {Object} uc UnmanagedConcept data object, fields: (notation || label, identifier)
 * @param {Object} mc ManagedConcept data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} UnmanagedConcept as a string reference
 */
function unmanagedConceptRef(uc, mc) {
  return `${uc.notation || uc.label} ${uc.identifier} <span class="text-xtiny">(${managedConceptRef(mc)})</span>`;
}

/**
 * Returns String representation of a ManagedConcept
 * @param {Object} mc ManagedConcept data object, fields: (notation || label, identifier, semantic_version)
 * @return {string} ManagedConcept as a string reference
 */
function managedConceptRef(mc) {
  return `${mc.notation || mc.label} ${mc.identifier} v${mc.semantic_version}`;
}

export {
  unmanagedConceptRef,
  managedConceptRef
}
