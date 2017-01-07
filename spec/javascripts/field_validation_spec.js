//= require field_validation
//= require rspec_helper

describe("Field Validation", function() {
	
	it("checks for a valid identifier, AAA BBB", function() {
		expect(fvIdentifierRegEx.test("AAA BBB")).to.equal(true);
  });

	it("checks for a valid identifier, XEFa", function() {
		expect(fvIdentifierRegEx.test("XEFa")).to.equal(true);
  });

	it("checks for a valid identifier, 1234567890", function() {
		expect(fvIdentifierRegEx.test("1234567890")).to.equal(true);
  });

	it("checks for a valid identifier, the quick brown ...", function() {
		expect(fvIdentifierRegEx.test("the quick brown fox jumps over the lazy dog")).to.equal(true);
  });

	it("checks for a valid identifier, THE QUICK BROWN ...", function() {
		expect(fvIdentifierRegEx.test("THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG")).to.equal(true);
  });
	it("checks for an invalid identifier, ! BBB", function() {
		expect(fvIdentifierRegEx.test("! BBB")).to.equal(false);
  });

	it("checks for an invalid identifier, ? BBB", function() {
		expect(fvIdentifierRegEx.test("? BBB")).to.equal(false);
  });

	it("checks for a valid label, big string", function() {
		expect(fvLabelRegEx.test("the dirty brown fox jumps over the lazy dog. THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>")).to.equal(true);
  });

	it("checks for a invalid label, ±§€@", function() {
		expect(fvLabelRegEx.test("±§€@")).to.equal(false);
  });

	it("checks for a valid question, big string", function() {
		expect(fvQuestionRegEx.test("the dirty brown fox jumps over the lazy dog. THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>")).to.equal(true);
  });

	it("checks for a valid question, \"\"", function() {
		expect(fvQuestionRegEx.test("")).to.equal(true);
  });

	it("checks for a invalid question, ±§€@", function() {
		expect(fvQuestionRegEx.test("±§€@")).to.equal(false);
  });

	it("checks for a valid markdown, big string", function() {
		expect(fvMarkdownRegEx.test("the dirty brown fox jumps over the lazy dog. THE DIRTY BROWN FOX JUMPS OVER THE LAZY DOG. 0123456789. !?,'\"_-/\\()[]~#*=:;&|<>")).to.equal(true);
  });

	it("checks for invalid markdown, €", function() {
		expect(fvMarkdownRegEx.test("€")).to.equal(false);
  });

	it("checks for a valid variable name, A1234567", function() {
		expect(fvSdtmVarNameRegEx.test("A1234567")).to.equal(true);
  });

	it("checks for a valid variable name, EGTEST", function() {
		expect(fvSdtmVarNameRegEx.test("EGTEST")).to.equal(true);
  });

	it("checks for invalid variable name, 1AAAAAAA", function() {
		expect(fvSdtmVarNameRegEx.test("1AAAAAAA")).to.equal(false);
  });

	it("checks for a valid variable label, 0123456789012345678901234567890123456789", function() {
		expect(fvSdtmVarLabelRegEx.test("0123456789012345678901234567890123456789")).to.equal(true);
  });

	it("checks for a valid variable label, this is a a/b", function() {
		expect(fvSdtmVarLabelRegEx.test("this is a a/b")).to.equal(true);
  });

	it("checks for a valid variable label, this is a a\\b", function() {
		expect(fvSdtmVarLabelRegEx.test("this is a a\\b")).to.equal(true);
  });

	it("checks for an invalid variable label, 0123456789012345678901234567890123456789x", function() {
		expect(fvSdtmVarLabelRegEx.test("0123456789012345678901234567890123456789x")).to.equal(false);
  });

	it("checks for an invalid variable label, £ label", function() {
		expect(fvSdtmVarLabelRegEx.test("£ label")).to.equal(false);
  });

	it("checks for a valid domain prefix, AA", function() {
		expect(fvDomainPrefixRegEx.test("AA")).to.equal(true);
  });

	it("checks for invalid domain prefix, A", function() {
		expect(fvDomainPrefixRegEx.test("A")).to.equal(false);
  });

	it("checks for invalid domain prefix, 11", function() {
		expect(fvDomainPrefixRegEx.test("11")).to.equal(false);
  });

	it("checks for invalid domain prefix, aa", function() {
		expect(fvDomainPrefixRegEx.test("aa")).to.equal(false);
  });

	it("checks for invalid domain prefix, AAa", function() {
		expect(fvDomainPrefixRegEx.test("AAa")).to.equal(false);
  });

	it("checks for invalid domain prefix, \"\"", function() {
		expect(fvDomainPrefixRegEx.test("")).to.equal(false);
  });

	it("checks for a valid format, 3", function() {
		expect(fvFormatRegEx.test("3")).to.equal(true);
  });

	it("checks for a valid format, 34", function() {
		expect(fvFormatRegEx.test("34")).to.equal(true);
  });

	it("checks for a valid format, 3.3", function() {
		expect(fvFormatRegEx.test("3.3")).to.equal(true);
  });

	it("checks for an invalid format, .3", function() {
		expect(fvFormatRegEx.test(".3")).to.equal(false);
  });

	it("checks for an invalid format, 3.", function() {
		expect(fvFormatRegEx.test("3.")).to.equal(false);
  });

	it("checks for an invalid format, a.b", function() {
		expect(fvFormatRegEx.test("a.b")).to.equal(false);
  });

	it("checks for a valid mapping, A=B", function() {
		expect(fvSdtmMappingRegEx.test("A=B")).to.equal(true);
  });

	it("checks for a valid mapping, THIS IS A MAPPING", function() {
		expect(fvSdtmMappingRegEx.test("THIS IS A MAPPING")).to.equal(true);
  });

	it("checks for an invalid mapping, THIS IS A MAPPING%", function() {
		expect(fvSdtmMappingRegEx.test("THIS IS A MAPPING%")).to.equal(false);
  });
});