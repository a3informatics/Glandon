const rdfTypesMap = {
  // Managed Item Types
  FORM: {
    rdfType: "http://www.assero.co.uk/BusinessForm#Form",
    name: "Form"
  },
  USERDOMAIN: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#UserDomain",
    name: "Custom Domain" 
  },
  IGDOMAIN: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#IgDomain",
    name: "SDTM IG Domain"
  },
  CLASSDOMAIN: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#ClassDomain",
    name: "SDTM Class Domain"
  },
  MODEL: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#Model",
    name: "SDTM Model"
  },
  BC: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
    name: "Biomedical Concept"
  },
  BCT: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptTemplate",
    name: "Biomedical Concept Template"
  },

  // Thesaurus Types
  TH: {
    rdfType: "http://www.assero.co.uk/Thesaurus#Thesaurus",
    name: "Terminology"
  },
  TH_CL: {
    rdfType: "http://www.assero.co.uk/Thesaurus#ManagedConcept",
    name: "Code List"
  },
  TH_SUBSET: {
    rdfType: "http://www.assero.co.uk/Thesaurus#ManagedConcept#Subset",
    name: "Subset"
  },
  TH_EXT: {
    rdfType: "http://www.assero.co.uk/Thesaurus#ManagedConcept#Extension",
    name: "Extension"
  },
  TH_CLI: {
    rdfType: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",
    name: "Code List Item"
  },

  SI: {
    rdfType: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier",
    name: "Scoped Identifier"
  },
  RS: {
    rdfType: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",
    name: "Registration State"
  },

  // References
  TC_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#TcReference",
    name: "Terminology Reference"
  },
  P_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#PReference",
    name: "Property Reference"
  },
  BC_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#BcReference",
    name: "Biomedical Concept Reference"
  },
  BCT_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#BctReference",
    name: "Biomedical Concept Template Reference"
  },
  T_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#TReference",
    name: "Tabulation Reference"
  },
  C_REF: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#CReference",
    name: "Class Reference"
  },

  // Thesaurus Concept Types
  THC: {
    rdfType: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",
    name: "Code List Item"
  },

  // Form Types
  NORMAL_GROUP: {
    rdfType: "http://www.assero.co.uk/BusinessForm#NormalGroup",
    name: "Normal Group"
  },
  COMMON_GROUP: {
    rdfType: "http://www.assero.co.uk/BusinessForm#CommonGroup",
    name: "Common Group"
  },
  PLACEHOLDER: {
    rdfType: "http://www.assero.co.uk/BusinessForm#Placeholder",
    name: "Placeholder"
  },
  TEXTLABEL: {
    rdfType: "http://www.assero.co.uk/BusinessForm#TextLabel",
    name: "Text Label"
  },
  BC_QUESTION: {
    rdfType: "http://www.assero.co.uk/BusinessForm#BcProperty",
    name: "Biomedical Concept Property"
  },
  QUESTION: {
    rdfType: "http://www.assero.co.uk/BusinessForm#Question",
    name: "Question"
  },
  MAPPING: {
    rdfType: "http://www.assero.co.uk/BusinessForm#Mapping",
    name: "Mapping"
  },
  COMMON_ITEM: {
    rdfType: "http://www.assero.co.uk/BusinessForm#CommonItem",
    name: "Common Item"
  },
  Q_CL: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#TcReference",
    name: "Terminology Reference"
  },
  BC_CL: {
    rdfType: "http://www.assero.co.uk/BusinessOperational#TcReference",
    name: "Terminology Reference"
  },

  // BC Types
  BC_DATATYPE: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype",
    name: "Datatype"
  },
  BC_ITEM: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#Item",
    name: "Item"
  },
  BC_PROP: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
    name: "Property"
  },
  BC_PROP_VALUE: {
    rdfType: "http://www.assero.co.uk/CDISCBiomedicalConcept#PropertyValue",
    name: "Property Value"
  },

  // SDTM
  USERVARIABLE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#UserVariable",
    name: "Custom Variable"
  },
  IGVARIABLE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#IgVariable",
    name: "SDTM IG Variable"
  },
  CLASSVARIABLE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#ClassVariable",
    name: "SDTM Class Variable"
  },
  MODELVARIABLE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#ModelVariable",
    name: "SDTM Model Variable"
  },
  SDTM_IG: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#ImplementationGuide",
    name: "SDTM Implementation Guide"
  },

  SDTM_CLASSIFICATION: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#VariableClassification",
    name: "SDTM Variable Classification"
  },
  SDTM_TYPE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#VariableType",
    name: "SDTM Variable Type"
  },
  SDTM_COMPLIANCE: {
    rdfType: "http://www.assero.co.uk/BusinessDomain#VariableCompliance",
    name: "SDTM Variable Compliance"
  },

  // Concept system
  SYSTEM: {
    rdfType: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
    name: "Concept System"
  },
  TAG: {
    rdfType: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
    name: "Concept System Tag"
  }
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string} Item type as string name
 */
function getRdfName(shortcut) {
  return rdfTypesMap[name].name;
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} shortcut Shortcut key to item in the map
 * @return {string} Item type as rdf type (url)
 */
function getRdfType(shortcut) {
  return rdfTypesMap[name].rdfType;
}

/**
 * Checks if RDF types are a match
 * @param {string} name Type key in the map
 * @param {string} value RDF Type value to compare
 * @return {boolean} match result
 */
function rdfTypesMatch(name, value) {
  return rdfTypesMap[name] === value;
}

export {
  getRdfType,
  getRdfName,
  rdfTypesMatch
 }
