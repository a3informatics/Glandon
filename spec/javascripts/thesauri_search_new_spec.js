//= require thesauri_search_new
//= require rspec_helper

var pageSettings;
var pageLength;
  
describe("Thesauri Search", function() {

  it("single I, page length changed", function() {
  	pageSettings = [[5, 10, 15, 20, 50, 100, -1], ["5", "10", "15", "20", "50", "100", "All"]]
  	pageLength = -1;
  	filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

  it("single II, page length not changed", function() {
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100], ["5", "10", "15", "20", "All", "50", "100"]]
  	pageLength = 5;
  	filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(5);
  });

  it("multiple I, page length changed", function() {
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100, -1], ["5", "10", "15", "20", "All", "50", "100", "All"]]
  	pageLength = -1;
  	filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

  it("multiple II, page length not changed", function() {
  	pageSettings = [[5, 10, 15, 20, -1, 50, 100, -1], ["5", "10", "15", "20", "All", "50", "100", "All"]]
  	pageLength = 10;
  	filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(10);
  });

  it("none present", function() {
  	pageSettings = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	pageLength = 100;
  	filterOutAll();
  	var expected = [[5, 10, 15, 20, 50, 100], ["5", "10", "15", "20", "50", "100"]]
  	expect(pageSettings).to.eql(expected);
  	expect(pageLength).to.equal(100);
  });

});