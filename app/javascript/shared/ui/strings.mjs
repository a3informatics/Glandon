/*** Renderers for shared Strings ***/

/**
 * Returns String representation of an UnmangedConcept
 * @param {Object} uc UnmanagedConcept data object, fields: (identifier || notation)
 * @param {Object} mc ManagedConcept data object, fields: (identifier || notation, semantic_version)
 * @return {string} UnmanagedConcept as a string reference
 */
function unmanagedConceptRef(uc, mc) {
  return `${uc.notation || uc.identifier} (Code List: ${managedConceptRef(mc)})`;
}

/**
 * Returns String representation of a ManagedConcept
 * @param {Object} mc ManagedConcept data object, fields: (identifier || notation, semantic_version)
 * @return {string} ManagedConcept as a string reference
 */
function managedConceptRef(mc) {
  return `${mc.notation || mc.identifier} v${mc.semantic_version}`;
}

export {
  unmanagedConceptRef,
  managedConceptRef
}
