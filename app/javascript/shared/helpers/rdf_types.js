const rdfTypesMap = {

  // Thesaurus and CL Types
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
    url: '/thesauri/managed_concepts',
    indexUrl: '/thesauri/managed_concepts/set_with_indicators?managed_concept%5Btype%5D=all'
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

  // Managed Item Types
  MC: {
    rdfType: 'http://www.assero.co.uk/BusinessOperational#Collection',
    name: 'Managed Collection',
    param: 'managed_collection',
    url: '/managed_collections'
  },
  ASSESSMENT: {
    rdfType: 'http://www.assero.co.uk/BiomedicalConcept#Assessment',
    name: 'Assessment',
    param: 'assessment',
    url: '/assessments'
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
  FORM: {
    rdfType: 'http://www.assero.co.uk/BusinessForm#Form',
    name: 'Form',
    param: 'form',
    url: '/forms'
  },
  ADAM_IG: {
    rdfType: 'http://www.assero.co.uk/Tabulation#ADaMImplementationGuide',
    name: 'ADaM IG',
    param: 'adam_ig',
    url: '/adam_igs'
  },
  ADAM_DATASET: {
    rdfType: 'http://www.assero.co.uk/Tabulation#ADaMDataset',
    name: 'ADaM IG Dataset',
    param: 'adam_ig_dataset',
    url: '/adam_ig_datasets'
  },
  SDTM_MODEL: {
    rdfType: 'http://www.assero.co.uk/Tabulation#Model',
    name: 'SDTM Model',
    param: 'sdtm_model',
    url: '/sdtm_models'
  },
  SDTM_IG: {
    rdfType: 'http://www.assero.co.uk/Tabulation#SDTMImplementationGuide',
    name: 'SDTM IG',
    param: 'sdtm_ig',
    url: '/sdtm_igs'
  },
  SDTM_DOMAIN: {
    rdfType: 'http://www.assero.co.uk/Tabulation#SdtmDomain',
    name: 'SDTM IG Domain',
    param: 'sdtm_ig_domain',
    url: '/sdtm_ig_domains'
  },
  SDTM_CLASS: {
    rdfType: 'http://www.assero.co.uk/Tabulation#SdtmClass',
    name: 'SDTM Class',
    param: 'sdtm_class',
    url: '/sdtm_classes'
  },
  SDTM_SD: {
    rdfType: 'http://www.assero.co.uk/Tabulation#SdtmSponsorDomain',
    name: 'SDTM Sponsor Domain',
    param: 'sdtm_sponsor_domain',
    url: '/sdtm_sponsor_domains'
  },

  // Form Sub Types
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

  // Study Types
  STUDY: {
    rdfType: 'http://www.assero.co.uk/Protocol#Study',
    name: 'Study',
    param: 'study',
    url: '/studies'
  },
  PROTOCOL: {
    rdfType: 'http://www.assero.co.uk/Protocol#Protocol',
    name: 'Protocol',
    param: 'protocols',
    url: '/protocols'
  },
  PROTOCOL_TEMPLATE: {
    rdfType: 'http://www.assero.co.uk/Protocol#ProtocolTemplate',
    name: 'Protocol Template',
    param: 'protocol_template',
    url: '/protocol_templates'
  },
  TA: {
    rdfType: 'http://www.assero.co.uk/Protocol#TherapeuticArea',
    name: 'Therapeutic Area',
    param: 'therapeutic_area',
    url: '/therapeutic_areas'
  },
  INDICATION: {
    rdfType: 'http://www.assero.co.uk/Protocol#Indication',
    name: 'Indication',
    param: 'indication',
    url: '/indications'
  },
  ENDPOINT: {
    rdfType: 'http://www.assero.co.uk/Protocol#Endpoint',
    name: 'Endpoint',
    param: 'endpoint',
    url: '/endpoints'
  },
  OBJECTIVE: {
    rdfType: 'http://www.assero.co.uk/Protocol#Objective',
    name: 'Objective',
    param: 'objective',
    url: '/objectives'
  },

  UNKNOWN: {
    rdfType: 'unknown',
    name: 'Unknown',
    param: ''
  }

}

/**
 * Gets the RDF object from shortcut
 * @param {string} shortcut Shortcut key to item in the map
 * @return {object} RDF object definition | rdf UNKNOWN type if shortcut not found
 */
function getRdf(shortcut) {
  return rdfTypesMap[shortcut] || rdfTypesMap.UNKNOWN
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string | null} Item type as string name
 */
function getRdfName(shortcut) {
  return getRdf( shortcut ).name
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string} Item type as rdf type (url)
 */
function getRdfType(shortcut) {
  return getRdf( shortcut ).rdfType;
}

/**
 * Checks if RDF types are a match
 * @param {string} shortcut Shortcut key to item in the map
 * @param {string} value RDF Type value to compare
 * @return {boolean} match result
 */
function rdfTypesMatch(shortcut, value) {
  return getRdf( shortcut ).rdfType === value;
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
 * Gets the RDF definition object from the map by matching property value
 * @param {string} value Value to search by
 * @param {string} propertyName RDF Map property name that is being compared to value 
 * @return {object} Item RDF object definition from the map, UNKNOWN rdf type definition if not found 
 */
function getRdfObject(value, propertyName = 'rdfType') {

  const filtered = Object.values( rdfTypesMap )
                         .filter( (d) => d[ propertyName ] === value )

  if ( filtered.length )
    return filtered[0]

  else return rdfTypesMap.UNKNOWN

}

export {
  rdfTypesMap,
  getRdfType,
  getRdfName,
  rdfTypesMatch,
  getRdfNameByType,
  getRdfObject
 }
