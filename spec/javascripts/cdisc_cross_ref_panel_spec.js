//= require application
//= require colour
//= require d3_graph
//= require sinon
//= require cdisc_cross_ref_panel

var pageLength = 5;
var pageSettings = [[5,10,15,25,50,100,-1], ["5","10","15","25","50","100","All"]];

describe("CDISC Cross Ref Panel", function() {
	
	beforeEach(function() {
  	html = 
		'  <table id="cr_table" class="table table-striped table-bordered table-condensed">' +
		'    <thead>' +
		'      <tr>' +
		'    	   <th>Parent Identifier</th>' +
	  '  		   <th>Identifier</th>' +
	  '  		   <th>Noation</th>' +
	  '  		   <th>Comments</th>' +
	  '  		   <th></th>' +
		'  	   </tr>' +
		'		 </thead>' +
		'		 <tbody>' +
		'	   </tbody>' +
		'  </table>';
		fixture.set(html);
  	server = sinon.fakeServer.create();
	});

  afterEach(function() { 
    server.restore();
  });

  it("initialises the object", function() {
  	var ccrp = new CdiscCrossRefPanel("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", "from");
  	expect(ccrp.direction).to.eql('from');
  	expect(ccrp.id).to.eql("TH-CDISC_CDISCTerminology");
  	expect(ccrp.namespace).to.equal("http://www.assero.co.uk/MDRThesaurus/CDISC/V48");
  });

 	it("start the process", function() {
  	stub_1 = sinon.stub(CdiscCrossRefPanel.prototype, "details")
  	stub_2 = sinon.stub(window, 'displayAlerts');
  	var ccrp = new CdiscCrossRefPanel("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", "from");
		data = ["http://www.assero.co.uk/MDRThesaurus/CDISC/V48#ITEM_1"]
		server.respondWith("GET", "/thesaurus_concepts/TH-CDISC_CDISCTerminology/cross_reference_start?" + 
			"thesaurus_concept%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV48" + 
			"&thesaurus_concept%5Bdirection%5D=from", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
  	ccrp.start();
  	server.respond();
  	expect(stub_1.calledOnce).to.be.true;
  	expect(stub_1.getCall(0).args[0]).to.equal("http://www.assero.co.uk/MDRThesaurus/CDISC/V48#ITEM_1");
  	stub_1.restore();
  	stub_2.restore();
 	});

 	it("start the process, error", function() {
  	stub_1 = sinon.stub(CdiscCrossRefPanel.prototype, "details")
  	stub_2 = sinon.stub(window, 'displayAlerts');
  	var ccrp = new CdiscCrossRefPanel("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", "from");
		data = ["http://www.assero.co.uk/MDRThesaurus/CDISC/V48#ITEM_1"]
		server.respondWith("GET", "/thesaurus_concepts/TH-CDISC_CDISCTerminology/cross_reference_start", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data) ]);
  	ccrp.start();
  	server.respond();
  	expect(stub_2.calledOnce).to.be.true;
  	expect(stub_2.getCall(0).args[0]).to.equal('<div class="alert alert-danger alert-dismissible" role="alert"><button type="button" ' + 
  		'class="close" data-dismiss="alert"><span>&times;</span></button>Error communicating with the server.</div>');
  	stub_1.restore();
  	stub_2.restore();
 	});

 	it("handle details", function() {
  	var ccrp = new CdiscCrossRefPanel("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", "from");
 		xref = { parentIdentifier: "C44444", identifier: "C44445", notation: "ZZZZ", id: "id", uri: "uri" }
 		data = [ 
 			{ item: { parentIdentifier: "C12345", identifier: "C12346", notation: "XXXX"}, comments: "Comments 1", cross_references: [] },
 			{ item: { parentIdentifier: "C12347", identifier: "C12348", notation: "YYYY"}, comments: "Comments 2", cross_references: [xref] },
 		]
		server.respondWith("GET", "/thesaurus_concepts/ITEM_1/cross_reference_details?" + 
			"thesaurus_concept%5Bnamespace%5D=http%3A%2F%2Fwww.assero.co.uk%2FMDRThesaurus%2FCDISC%2FV48&thesaurus_concept%5Bdirection%5D=from", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ccrp.details("http://www.assero.co.uk/MDRThesaurus/CDISC/V48#ITEM_1");
  	server.respond();
 		expect($("#cr_table tbody tr:nth-child(1) td:nth-child(1)").text()).to.eq("C12345");
 		expect($("#cr_table tbody tr:nth-child(1) td:nth-child(2)").text()).to.eq("C12346");
 		expect($("#cr_table tbody tr:nth-child(1) td:nth-child(3)").text()).to.eq("XXXX");
 		expect($("#cr_table tbody tr:nth-child(1) td:nth-child(4)").text()).to.eq("Comments 1");
 		expect($("#cr_table tbody tr:nth-child(1) td:nth-child(5)").text()).to.eq("");
 		expect($("#cr_table tbody tr:nth-child(2) td:nth-child(1)").text()).to.eq("C12347");
 		expect($("#cr_table tbody tr:nth-child(2) td:nth-child(2)").text()).to.eq("C12348");
 		expect($("#cr_table tbody tr:nth-child(2) td:nth-child(3)").text()).to.eq("YYYY");
 		expect($("#cr_table tbody tr:nth-child(2) td:nth-child(4)").text()).to.eq("Comments 2");
 		expect($("#cr_table tbody tr:nth-child(2) td:nth-child(5)").text()).to.eq("C44445, ZZZZ");
 	});

 	it("handle details, error", function() {
  	stub_1 = sinon.stub(window, 'displayAlerts');
  	var ccrp = new CdiscCrossRefPanel("TH-CDISC_CDISCTerminology", "http://www.assero.co.uk/MDRThesaurus/CDISC/V48", "from");
 		data = [ { item: { parentIdentifier: "C12345", identifier: "C12345", notation: "XXXX"}, comments: "Comments", cross_references: [] } ]
		server.respondWith("GET", "/thesaurus_concepts/xxx/cross_reference_start", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ccrp.details("http://www.assero.co.uk/MDRThesaurus/CDISC/V48#ITEM_1");
  	server.respond();
  	expect(stub_2.calledOnce).to.be.true;
  	expect(stub_2.getCall(0).args[0]).to.equal('<div class="alert alert-danger alert-dismissible" role="alert"><button type="button" ' + 
  		'class="close" data-dismiss="alert"><span>&times;</span></button>Error communicating with the server.</div>');
  	stub_1.restore();
 	});

});