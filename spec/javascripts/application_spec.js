//= require rspec_helper

describe("Application", function() {
	
  beforeEach(function() {
	});

  it("maps rdf types", function() {
  	// Sample
  	expect(typeToString["http://www.assero.co.uk/BusinessForm#Form"]).to.equal("Form");
		expect(typeToString["http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"]).to.equal("Biomedical Concept");
		expect(typeToString["http://www.assero.co.uk/ISO25964#Thesaurus"]).to.equal("Terminology");
		expect(typeToString["http://www.assero.co.uk/BusinessOperational#BctReference"]).to.equal("Biomedical Concept Template Reference");
		expect(typeToString["http://www.assero.co.uk/ISO25964#ThesaurusConcept"]).to.equal("Code List Item");
		expect(typeToString["http://www.assero.co.uk/BusinessForm#TextLabel"]).to.equal("Text Label");
		expect(typeToString["http://www.assero.co.uk/CDISCBiomedicalConcept#Property"]).to.equal("Property");
  	// Error
  	expect(typeToString["http://www.assero.co.uk/BusinessForm#FormXXXX"]).to.equal(undefined);
  });

});