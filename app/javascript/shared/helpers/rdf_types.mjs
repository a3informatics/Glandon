const rdfTypesMap = {
  // Managed Item Types
  FORM: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#Form',
    name: 'Form',
    param: 'form',
    url: '/forms'
  },
  USERDOMAIN: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#UserDomain',
    name: 'Custom Domain' 
  },
  IGDOMAIN: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#IgDomain',
    name: 'SDTM IG Domain'
  },
  CLASSDOMAIN: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#ClassDomain',
    name: 'SDTM Class Domain'
  },
  MODEL: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#Model',
    name: 'SDTM Model'
  },
  BC: {
    rdfType: 'http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptInstance',
    name: 'Biomedical Concept',
    param: 'biomedical_concept_instance',
    url: '/biomedical_concept_instances'
  },
  BCT: {
    rdfType: 'http://www.assero.co.uk/BiomedicalConcept#BiomedicalConceptTemplate',
    name: 'Biomedical Concept Template',
    param: 'biomedical_concept_template',
    url: '/biomedical_concept_templates'
  },

  // Thesaurus Types
  TH: {
    rdfType: 'http://www.assero.co.uk/Thesaurus#Thesaurus',
    name: 'Terminology',
    param: 'thesauri',
    url: '/thesauri'
  },
  TH_CL: {
    rdfType: 'http://www.assero.co.uk/Thesaurus#ManagedConcept',
    name: 'Code List',
    param: 'managed_concept',
    url: '/thesauri/managed_concepts'
  },
  TH_SUBSET: {
    rdfType: 'http://www.assero.co.uk/Thesaurus#ManagedConcept#Subset',
    name: 'Subset',
    param: 'managed_concept',
    url: '/thesauri/managed_concepts'
  },
  TH_EXT: {
    rdfType: 'http://www.assero.co.uk/Thesaurus#ManagedConcept#Extension',
    name: 'Extension',
    param: 'managed_concept',
    url: '/thesauri/managed_concepts'
  },
  TH_CLI: {
    rdfType: 'http://www.assero.co.uk/Thesaurus#UnmanagedConcept',
    name: 'Code List Item',
    param: 'unmanaged_concept',
    url: '/thesauri/unmanaged_concepts'
  },

  SI: {
    rdfType: 'http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier',
    name: 'Scoped Identifier'
  },
  RS: {
    rdfType: 'http://www.assero.co.uk/ISO11179Registration#RegistrationState',
    name: 'Registration State'
  },

  // References
  P_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#PReference',
    name: 'Property Reference'
  },
  BC_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#BcReference',
    name: 'Biomedical Concept Reference'
  },
  BCT_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#BctReference',
    name: 'Biomedical Concept Template Reference'
  },
  T_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#TReference',
    name: 'Tabulation Reference'
  },
  C_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#CReference',
    name: 'Class Reference'
  },

  // Form Types
  NORMAL_GROUP: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#NormalGroup',
    name: 'Normal Group',
    param: 'normal_group',
    url: '/forms/groups/normal_groups'
  },
  COMMON_GROUP: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#CommonGroup',
    name: 'Common Group',
    param: 'common_group',
    url: '/forms/groups/common_groups'
  },
  BC_GROUP: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#BcGroup',
    name: 'Biomedical Concept',
    param: 'bc_group',
    url: '/forms/groups/bc_groups'
  },
  PLACEHOLDER: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#Placeholder',
    name: 'Placeholder',
    param: 'placeholder',
    url: '/forms/items/placeholders'
  },
  TEXTLABEL: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#TextLabel',
    name: 'Text Label',
    param: 'text_label',
    url: '/forms/items/text_labels'
  },
  BC_PROPERTY: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#BcProperty',
    name: 'Biomedical Concept Property',
    param: 'bc_property',
    url: '/forms/items/bc_properties'
  },
  QUESTION: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#Question',
    name: 'Question',
    param: 'question',
    url: '/forms/items/questions'
  },
  MAPPING: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#Mapping',
    name: 'Mapping',
    param: 'mapping',
    url: '/forms/items/mappings'
  },
  COMMON_ITEM: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#CommonItem',
    name: 'Common Item',
    param: 'common',
    url: '/forms/items/commons'
  },
  TC_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#TcReference',
    name: 'Code List Reference',
    param: 'tc_reference'
  },
  TUC_REF: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#TucReference',
    name: 'Code List Item Reference',
    param: 'tuc_reference',
    url: '/operational_reference_v3/tuc_references'
  },

  // BC Types
  BC_DATATYPE: {
    rdfType: 'http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype',
    name: 'Datatype'
  },
  BC_ITEM: {
    rdfType: 'http://www.assero.co.uk/CDISCBiomedicalConcept#Item',
    name: 'Item'
  },
  BC_PROP: {
    rdfType: 'http://www.assero.co.uk/CDISCBiomedicalConcept#Property',
    name: 'Property'
  },
  BC_PROP_VALUE: {
    rdfType: 'http://www.assero.co.uk/CDISCBiomedicalConcept#PropertyValue',
    name: 'Property Value'
  },

  // SDTM
  USERVARIABLE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#UserVariable',
    name: 'Custom Variable'
  },
  IGVARIABLE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#IgVariable',
    name: 'SDTM IG Variable'
  },
  CLASSVARIABLE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#ClassVariable',
    name: 'SDTM Class Variable'
  },
  MODELVARIABLE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#ModelVariable',
    name: 'SDTM Model Variable'
  },
  SDTM_IG: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#ImplementationGuide',
    name: 'SDTM Implementation Guide'
  },

  SDTM_CLASSIFICATION: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#VariableClassification',
    name: 'SDTM Variable Classification'
  },
  SDTM_TYPE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#VariableType',
    name: 'SDTM Variable Type'
  },
  SDTM_COMPLIANCE: {
    rdfType: 'http://www.assero.co.uk/BusinessDomain#VariableCompliance',
    name: 'SDTM Variable Compliance'
  },

  // Concept system
  SYSTEM: {
    rdfType: 'http://www.assero.co.uk/ISO11179Concepts#ConceptSystem',
    name: 'Concept System'
  },
  TAG: {
    rdfType: 'http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode',
    name: 'Concept System Tag'
  }
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string} Item type as string name
 */
function getRdfName(shortcut) {
  return rdfTypesMap[shortcut].name;
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string} Item type as rdf type (url)
 */
function getRdfType(shortcut) {
  return rdfTypesMap[shortcut].rdfType;
}

/**
 * Checks if RDF types are a match
 * @param {string} shortcut Shortcut key to item in the map
 * @param {string} value RDF Type value to compare
 * @return {boolean} match result
 */
function rdfTypesMatch(shortcut, value) {
  return rdfTypesMap[shortcut].rdfType === value;
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} rdfType Full RdfType string to search by
 * @return {string} Item rdf name as string
 */
function getRdfNameByType(rdfType) {
  return getRdfObject( rdfType ).name;
}

/**
 * Gets the RDF definition object from the map by rdfType
 * @param {string} rdfType Full RdfType string to search by
 * @return {string} Item RDF object definition from the map
 */
function getRdfObject(rdfType) {

  const filtered = Object.values( rdfTypesMap )
                         .filter( (d) => d.rdfType === rdfType )

  if ( filtered.length )
    return filtered[0];

  throw new Error(`Rdf type '${ rdfType }' not found.`)

}

export {
  rdfTypesMap,
  getRdfType,
  getRdfName,
  rdfTypesMatch,
  getRdfNameByType,
  getRdfObject
 }
