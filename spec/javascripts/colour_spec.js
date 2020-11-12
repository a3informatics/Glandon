//= require rspec_helper
//= require colour

describe("Colour", function() {
	
  beforeEach(function() {
	});

  it("maps rdf types to colours", function() {
  	// Sample
  	expect(colours["http://www.assero.co.uk/BusinessForm#Form"]).to.equal("gold");
		expect(colours["http://www.assero.co.uk/CDISCBiomedicalConcept#BiomedicalConceptInstance"]).to.equal("crimson");
		expect(colours["http://www.assero.co.uk/ISO25964#Thesaurus"]).to.equal("green");
		expect(colours["http://www.assero.co.uk/BusinessOperational#BctReference"]).to.equal("whitesmoke");
		expect(colours["http://www.assero.co.uk/ISO25964#ThesaurusConcept"]).to.equal("green");
		expect(colours["http://www.assero.co.uk/BusinessForm#TextLabel"]).to.equal("gold");
		expect(colours["http://www.assero.co.uk/CDISCBiomedicalConcept#Property"]).to.equal("crimson");
  	// Error
  	expect(colours["http://www.assero.co.uk/BusinessForm#FormXXXX"]).to.equal(undefined);
  });

});