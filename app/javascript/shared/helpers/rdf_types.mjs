const rdfTypesMap = {
  // Managed Item Types
  FORM: "http://www.assero.co.uk/BusinessForm#Form",
  USERDOMAIN: "http://www.assero.co.uk/BusinessDomain#UserDomain",
  IGDOMAIN: "http://www.assero.co.uk/BusinessDomain#IgDomain",
  CLASSDOMAIN: "http://www.assero.co.uk/BusinessDomain#ClassDomain",
  MODEL: "http://www.assero.co.uk/BusinessDomain#Model",
  BC: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance",
  BCT: "http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptTemplate",

  // Thesaurus Types
  TH: "http://www.assero.co.uk/Thesaurus#Thesaurus",
  TH_CL: "http://www.assero.co.uk/Thesaurus#ManagedConcept",
  TH_SUBSET: "http://www.assero.co.uk/Thesaurus#ManagedConcept#Subset",
  TH_EXT: "http://www.assero.co.uk/Thesaurus#ManagedConcept#Extension",
  TH_CLI: "http://www.assero.co.uk/Thesaurus#UnmanagedConcept",

  SI: "http://www.assero.co.uk/ISO11179Identification#ScopedIdentifier",
  RS: "http://www.assero.co.uk/ISO11179Registration#RegistrationState",

  // References
  TREF: "http://www.assero.co.uk/BusinessOperational#TcReference",
  P_REF: "http://www.assero.co.uk/BusinessOperational#PReference",
  BREF: "http://www.assero.co.uk/BusinessOperational#BcReference",
  BCT_REF: "http://www.assero.co.uk/BusinessOperational#BctReference",
  T_REF: "http://www.assero.co.uk/BusinessOperational#TReference",
  REF: "http://www.assero.co.uk/BusinessOperational#CReference",

  // Thesaurus Concept Types
  THC: "http://www.assero.co.uk/ISO25964#ThesaurusConcept",

  // Form Types
  NORMAL_GROUP:"http://www.assero.co.uk/BusinessForm#NormalGroup",
  COMMON_GROUP: "http://www.assero.co.uk/BusinessForm#CommonGroup",
  PLACEHOLDER: "http://www.assero.co.uk/BusinessForm#Placeholder",
  TEXTLABEL: "http://www.assero.co.uk/BusinessForm#TextLabel",
  BQUESTION: "http://www.assero.co.uk/BusinessForm#BcProperty",
  QUESTION: "http://www.assero.co.uk/BusinessForm#Question",
  MAPPING: "http://www.assero.co.uk/BusinessForm#Mapping",
  COMMON_ITEM: "http://www.assero.co.uk/BusinessForm#CommonItem",
  Q_CL: "http://www.assero.co.uk/BusinessOperational#TcReference",
  BCL: "http://www.assero.co.uk/BusinessOperational#TcReference",

  // BC Types
  BDATATYPE:"http://www.assero.co.uk/CDISCBiomedicalConcept#Datatype",
  BITEM:"http://www.assero.co.uk/CDISCBiomedicalConcept#Item",
  BPROP:"http://www.assero.co.uk/CDISCBiomedicalConcept#Property",
  BPROP_VALUE:"http://www.assero.co.uk/CDISCBiomedicalConcept#PropertyValue",

  // SDTM
  USERVARIABLE: "http://www.assero.co.uk/BusinessDomain#UserVariable",
  IGVARIABLE: "http://www.assero.co.uk/BusinessDomain#IgVariable",
  CLASSVARIABLE: "http://www.assero.co.uk/BusinessDomain#ClassVariable",
  MODELVARIABLE: "http://www.assero.co.uk/BusinessDomain#ModelVariable",
  SDTM_IG: "http://www.assero.co.uk/BusinessDomain#ImplementationGuide",

  SDTM_CLASSIFICATION: "http://www.assero.co.uk/BusinessDomain#VariableClassification",
  SDTM_TYPE: "http://www.assero.co.uk/BusinessDomain#VariableType",
  SDTM_COMPLIANCE: "http://www.assero.co.uk/BusinessDomain#VariableCompliance",

  // Concept system
  SYSTEM: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystem",
  TAG: "http://www.assero.co.uk/ISO11179Concepts#ConceptSystemNode",
}

/**
 * Gets the RDF type string of an item const name in argument
 * @param {string} name Type key in the map
 * @return {string} RDF value string from the map
 */
function getRdfType(name) {
  return rdfTypesMap[name];
}

/**
 * Checks if RDF types are a match
 * @param {string} name Type key in the map
 * @param {string} value RDF Type value to compare
 * @return {boolean} match result
 */
function rdfTypeMatch(name, value) {
  return rdfTypesMap[name] === value;
}

export {
  getRdfType,
  rdfTypeMatch
 }
