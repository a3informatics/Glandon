require 'rails_helper'

describe UriManagement do
	
	C_ISO_B = "isoB"
  C_ISO_I = "isoI"
  C_ISO_R = "isoR"
  C_ISO_C = "isoC"
  C_ISO_T = "isoT"
  C_CBC = "cbc"
  C_BO = "bo"
  C_BCR = "bcr"
  C_BF = "bf"
  C_BD = "bd"
  C_ISO_25964 = "iso25964"
  C_TH = "th"
  C_ISO_21090 = "iso21090"
  C_MDR_ITEMS = "mdrItems"
  C_MDR_BCTS = "mdrBcts"
  C_MDR_BCS = "mdrBcs"
  C_MDR_F = "mdrForms"
  C_MDR_M = "mdrSDTMM"
  C_MDR_MD = "mdrSDTMMD"
  C_MDR_IG = "mdrSDTMIg"
  C_MDR_IGD = "mdrSDTMIgD"
  C_MDR_UD = "mdrSDTMUD"
  C_MDR_BRIDG = "mdrBridg"
  C_MDR_ISO21090 = "mdrIso21090"
  C_MDR_C = "mdrConcepts"
  C_MDR_TH =  "mdrTh"
  C_RDF = "rdf"
  C_RDFS = "rdfs"
  C_XSD = "xsd"
  C_SKOS = "skos"
  C_OWL = "owl"
  C_MDR_AIG = "mdrADaMIg"
  C_MDR_AIGT = "mdrADaMIgT"
 

  it "provides a list of optinal namespaces" do
    optional_set = 
      { 
        C_ISO_B => "http://www.assero.co.uk/ISO11179Basic" ,
        C_ISO_I => "http://www.assero.co.uk/ISO11179Identification" ,
        C_ISO_R => "http://www.assero.co.uk/ISO11179Registration" , 
        C_ISO_C => "http://www.assero.co.uk/ISO11179Concepts" , 
        C_ISO_T => "http://www.assero.co.uk/ISO11179Types" , 
        C_ISO_25964 => "http://www.assero.co.uk/ISO25964" , 
        C_TH => "http://www.assero.co.uk/Thesaurus" ,
        C_ISO_21090 => "http://www.assero.co.uk/ISO21090" ,
        C_CBC => "http://www.assero.co.uk/CDISCBiomedicalConcept",
        C_BO => "http://www.assero.co.uk/BusinessOperational" ,
        C_BCR => "http://www.assero.co.uk/BusinessCrossReference" ,
        C_BF => "http://www.assero.co.uk/BusinessForm" ,
        C_BD => "http://www.assero.co.uk/BusinessDomain" ,
        C_MDR_ITEMS => "http://www.assero.co.uk/MDRItems" ,
        C_MDR_C => "http://www.assero.co.uk/MDRConcepts" ,
        C_MDR_BRIDG => "http://www.assero.co.uk/MDRBRIDG" ,
        C_MDR_ISO21090 => "http://www.assero.co.uk/MDRISO21090" ,
        C_MDR_BCS => "http://www.assero.co.uk/MDRBCs" ,
        C_MDR_BCTS => "http://www.assero.co.uk/MDRBCTs" ,
        C_MDR_F => "http://www.assero.co.uk/MDRForms" ,
        C_MDR_M => "http://www.assero.co.uk/MDRSdtmM" ,
        C_MDR_MD => "http://www.assero.co.uk/MDRSdtmMd" ,
        C_MDR_IG => "http://www.assero.co.uk/MDRSdtmIg" ,
        C_MDR_IGD => "http://www.assero.co.uk/MDRSdtmIgD" ,
        C_MDR_UD => "http://www.assero.co.uk/MDRSdtmUD" ,
        C_MDR_TH => "http://www.assero.co.uk/MDRThesaurus",
        C_OWL => "http://www.w3.org/2002/07/owl",
        C_MDR_AIG => "http://www.assero.co.uk/MDRAdamIg",
        C_MDR_AIGT => "http://www.assero.co.uk/MDRAdamIgT"
      }
		expect(UriManagement.get()).to eq(optional_set)
	end

  it "provides the required set" do
    required_set = 
    { 
      C_RDF => "http://www.w3.org/1999/02/22-rdf-syntax-ns" ,
      C_RDFS => "http://www.w3.org/2000/01/rdf-schema" ,
      C_XSD => "http://www.w3.org/2001/XMLSchema" ,
      C_SKOS => "http://www.w3.org/2004/02/skos/core" 
    }
    expect(UriManagement.required).to eq(required_set)
  end

  it "allows the prefix to be obtained for a namespace" do
    expect(UriManagement.getPrefix("http://www.assero.co.uk/BusinessDomain")).to eq("bd")
    expect(UriManagement.getPrefix("http://www.assero.co.uk/BusinessCrossReference")).to eq("bcr")
  end

  it "handles the error for namespace that does not exist" do
    expect(UriManagement.getPrefix("http://www.assero.co.uk/")).to eq(nil)
  end

  it "allows the namespace to be obtained for a prefix" do
    expect(UriManagement.getNs("isoC")).to eq("http://www.assero.co.uk/ISO11179Concepts")
  end

  it "handles the error for prefix that does not exist" do
    expect(UriManagement.getNs("sss")).to eq(nil)
  end

  it "build the list of namespaces" do
    result = "PREFIX : <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildPrefix("bo", ["bf", "bd"])).to eq(result)
  end

  it "build the list of namespaces" do
    result = "PREFIX : <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>\n" +
      "PREFIX th: <http://www.assero.co.uk/Thesaurus#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildPrefix("bo", ["bf", "bd", "th"])).to eq(result)
  end

  it "build the list of namespaces with only default" do
    result = "PREFIX : <http://www.assero.co.uk/BusinessOperational#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildPrefix("bo", [])).to eq(result)
  end

  it "build the list of namespaces with no default" do
    result = "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildPrefix("", ["bf", "bd"])).to eq(result)
  end

  it "build the list of namespaces" do
    result = "PREFIX : <http://www.assero.co.uk/ISO11179Types#>\n" +
      "PREFIX bf: <http://www.assero.co.uk/BusinessForm#>\n" +
      "PREFIX bd: <http://www.assero.co.uk/BusinessDomain#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildNs("http://www.assero.co.uk/ISO11179Types", ["bf", "bd"])).to eq(result)
  end

  it "build the list of namespaces with only default" do
    result = "PREFIX : <http://www.assero.co.uk/ISO11179Types#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildNs("http://www.assero.co.uk/ISO11179Types", [])).to eq(result)
  end

  it "build the list of namespaces with no default" do
    result = "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#>\n" +
      "PREFIX isoC: <http://www.assero.co.uk/ISO11179Concepts#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n"
    expect(UriManagement.buildNs("", ["isoI", "isoC"])).to eq(result)
  end

end