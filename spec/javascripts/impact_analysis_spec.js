//= require application
//= require sinon
//= require impact_analysis
//= require impact_analysis_graph_panel
//= require iso_managed_list_panel
//= require thesaurus_concept_list_panel
//= require d3_graph
//= require colour
//= require rspec_helper

var pageLength = 5;
var pageSettings = [[5,10,15,25,50,100,-1], ["5","10","15","25","50","100","All"]];

// Tests
describe("Impact Analysis", function() {
	
	var lastClickNode;
	var spy;
	var finished;

  beforeEach(function() {
  	//html = 
  	//'<div class="progress-bar" id="crfPb" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%;"></div>';
  	//html += '<div id="crfHtml"></div>'
  	//fixture.set(html);
  	server = sinon.fakeServer.create();
	});

  afterEach(function() { 
    server.restore();
  })

  function finishedCallback () {
  	finished = true;
  }

  it("initialises the object", function() {
  	var iagp = sinon.stub(window, "ImpactAnalysisGraphPanel");
		var imlp = sinon.stub(window, "IsoManagedListPanel");
		var tclp = sinon.stub(window, "ThesaurusConceptListPanel");
		url = "http://www.exampe.com/get";
  	id = "X";
  	namespace = "http://www.exampe.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
		expect(ia.url).to.equal(url);		  	
		expect(ia.id).to.equal(id);		  	
		expect(ia.namespace).to.equal(namespace);		  	
		expect(ia.maxLevel).to.equal(maxLevel);		  	
		iagp.restore();
		imlp.restore();
		tclp.restore();
  });

 	it("handles the call back", function() {
		mi_h_stub = sinon.stub(IsoManagedListPanel.prototype , "highlight");
		mi_c_stub = sinon.stub(IsoManagedListPanel.prototype , "clear");
		tc_h_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "highlight");
		tc_c_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "clear");
		url = "http://www.exampe.com/get";
  	id = "X";
  	namespace = "http://www.exampe.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
		node = {type: C_THC, key: 14};
		ia.callBack(node);
		expect(mi_c_stub.calledOnce).to.be.true;
		expect(mi_h_stub.notCalled).to.be.true;
		expect(tc_c_stub.notCalled).to.be.true;
		expect(tc_h_stub.calledOnce).to.be.true;
		expect(tc_h_stub.getCall(0).args[0]).to.equal(14);
		mi_h_stub.reset(); // Reset stub call counts
		mi_c_stub.reset();
		tc_h_stub.reset();
		tc_c_stub.reset();
		node = {type: "XXX", key: 102};
		ia.callBack(node);
		expect(mi_c_stub.notCalled).to.be.true;
		expect(mi_h_stub.calledOnce).to.be.true;
		expect(tc_c_stub.calledOnce).to.be.true;
		expect(tc_h_stub.notCalled).to.be.true;
		expect(mi_h_stub.getCall(0).args[0]).to.equal(102);
		mi_h_stub.restore();
		mi_c_stub.restore();
		tc_h_stub.restore();
		tc_c_stub.restore();
 	});

 	it("starts the impact assessment, empty", function() {
 		finished = false;
 		iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	data = [];
  	server.respondWith("GET", "/start?id=X&namespace=http%3A%2F%2Fwww.example.com%2FB", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.start();
  	server.respond();
    expect(iagp_d_stub.notCalled).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
  	expect(finished).to.equal(true); // Callback called
    iagp_d_stub.restore();
  	win_da_stub.restore();  
 	});

 	it("starts the impact assessment, single", function() {
 		ia_c_stub = sinon.stub(ImpactAnalysis.prototype , "child")
  	iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	data = [{item: 1}];
  	server.respondWith("GET", "/start?id=X&namespace=http%3A%2F%2Fwww.example.com%2FB", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.start();
  	server.respond();
    expect(ia_c_stub.calledOnce).to.be.true;
    expect(iagp_d_stub.calledOnce).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
    expect(ia_c_stub.getCall(0).args[0].item).to.equal(1);
    expect(ia_c_stub.getCall(0).args[1]).to.equal(ImpactAnalysis.PARENT_NODE);
    expect(ia_c_stub.getCall(0).args[2]).to.equal(1);
		expect(ia.ajaxCount).to.equal(0);
		ia_c_stub.restore();
  	iagp_d_stub.restore();
  	win_da_stub.restore();  
 	});

 	it("processes a child, I", function() {
 		finished = false;
  	iagp_an_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addNode")
  	iagp_al_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addLink")
  	iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	tc_a_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "add");
  	mi_a_stub = sinon.stub(IsoManagedListPanel.prototype , "add");
		win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	data = {item: {uri: "http://www.example.com/D#FRAGMENT2", type: C_THC}, children: []};
  	result = data.item;
  	result.key = 4
  	iagp_an_stub.onCall(0).returns(result);
  	server.respondWith("GET", "/iso_concept/impact_next?id=FRAGMENT1&namespace=http%3A%2F%2Fwww.example.com%2FC", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.child("http://www.example.com/C#FRAGMENT1", ImpactAnalysis.PARENT_NODE, 1);
  	server.respond();
    expect(ia_c_stub.calledOnce).to.be.true;
    expect(iagp_an_stub.calledOnce).to.be.true;
  	expect(iagp_al_stub.notCalled).to.be.true;
  	expect(iagp_d_stub.calledOnce).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
    expect(iagp_an_stub.getCall(0).args[0].uri).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(iagp_an_stub.getCall(0).args[0].type).to.equal(C_THC);
    expect(mi_a_stub.notCalled).to.be.true;
    expect(tc_a_stub.calledOnce).to.be.true;
    expect(tc_a_stub.getCall(0).args[0]).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(tc_a_stub.getCall(0).args[1]).to.equal(4);
    expect(ia.ajaxCount).to.equal(0);
		expect(finished).to.equal(true);
		iagp_an_stub.restore();
  	iagp_al_stub.restore();
  	iagp_d_stub.restore();
  	tc_a_stub.restore();
  	mi_a_stub.restore();
  	win_da_stub.restore();  
 	});

 	it("processes a child, II", function() {
 		finished = false;
  	iagp_an_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addNode")
  	iagp_al_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addLink")
  	iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	tc_a_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "add");
  	mi_a_stub = sinon.stub(IsoManagedListPanel.prototype , "add");
		win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	data = {item: {uri: "http://www.example.com/D#FRAGMENT2", type: C_THC}, children: []};
  	result = data.item;
  	result.key = 4
  	iagp_an_stub.onCall(0).returns(result);
  	server.respondWith("GET", "/iso_concept/impact_next?id=FRAGMENT1&namespace=http%3A%2F%2Fwww.example.com%2FC", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.child("http://www.example.com/C#FRAGMENT1", 3, 1);
  	server.respond();
    expect(ia_c_stub.calledOnce).to.be.true;
    expect(iagp_an_stub.calledOnce).to.be.true;
  	expect(iagp_al_stub.calledOnce).to.be.true;
  	expect(iagp_d_stub.calledOnce).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
    expect(iagp_an_stub.getCall(0).args[0].uri).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(iagp_an_stub.getCall(0).args[0].type).to.equal(C_THC);
    expect(mi_a_stub.notCalled).to.be.true;
    expect(tc_a_stub.calledOnce).to.be.true;
    expect(tc_a_stub.getCall(0).args[0]).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(tc_a_stub.getCall(0).args[1]).to.equal(4);
    expect(ia.ajaxCount).to.equal(0);
		expect(finished).to.equal(true);
		iagp_an_stub.restore();
  	iagp_al_stub.restore();
  	iagp_d_stub.restore();
  	tc_a_stub.restore();
  	mi_a_stub.restore();
  	win_da_stub.restore();  
 	}); 	

 	it("processes a child, III", function() {
 		finished = false;
  	iagp_an_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addNode")
  	iagp_al_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addLink")
  	iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	tc_a_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "add");
  	mi_a_stub = sinon.stub(IsoManagedListPanel.prototype , "add");
		win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	data = {item: {uri: "http://www.example.com/D#FRAGMENT2", type: "OTHER_TYPE"}, children: []};
  	result = data.item;
  	result.key = 4
  	iagp_an_stub.onCall(0).returns(result);
  	server.respondWith("GET", "/iso_concept/impact_next?id=FRAGMENT1&namespace=http%3A%2F%2Fwww.example.com%2FC", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.child("http://www.example.com/C#FRAGMENT1", 3, 1);
  	server.respond();
    expect(ia_c_stub.calledOnce).to.be.true;
    expect(iagp_an_stub.calledOnce).to.be.true;
  	expect(iagp_al_stub.calledOnce).to.be.true;
  	expect(iagp_d_stub.calledOnce).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
    expect(iagp_an_stub.getCall(0).args[0].uri).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(iagp_an_stub.getCall(0).args[0].type).to.equal("OTHER_TYPE");
    expect(tc_a_stub.notCalled).to.be.true;
    expect(mi_a_stub.calledOnce).to.be.true;
    expect(mi_a_stub.getCall(0).args[0]).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(mi_a_stub.getCall(0).args[1]).to.equal(4);
    expect(ia.ajaxCount).to.equal(0);
		expect(finished).to.equal(true);
		iagp_an_stub.restore();
  	iagp_al_stub.restore();
  	iagp_d_stub.restore();
  	tc_a_stub.restore();
  	mi_a_stub.restore();
  	win_da_stub.restore();  
 	}); 	

 	it("processes a child, IV", function() {
 		finished = false;
  	iagp_an_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addNode")
  	iagp_al_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "addLink")
  	iagp_d_stub = sinon.stub(ImpactAnalysisGraphPanel.prototype , "draw")
  	tc_a_stub = sinon.stub(ThesaurusConceptListPanel.prototype , "add");
  	mi_a_stub = sinon.stub(IsoManagedListPanel.prototype , "add");
		win_da_stub = sinon.stub(window, 'displayAlerts');
  	url = "/start";
  	id = "X";
  	namespace = "http://www.example.com/B";
  	maxLevel = 2;
  	finished = false;
  	var ia = new ImpactAnalysis(url, id, namespace, maxLevel, finishedCallback) 
  	ia.ajaxCount = 21;
  	data = {item: {uri: "http://www.example.com/D#FRAGMENT2", type: "OTHER_TYPE"}, children: []};
  	result = data.item;
  	result.key = 4
  	iagp_an_stub.onCall(0).returns(result);
  	server.respondWith("GET", "/iso_concept/impact_next?id=FRAGMENT1&namespace=http%3A%2F%2Fwww.example.com%2FC", [
  		200, {"Content-Type":"application/json"}, JSON.stringify(data)
		]);
  	ia.child("http://www.example.com/C#FRAGMENT1", 3, 1);
  	server.respond();
    expect(ia_c_stub.calledOnce).to.be.true;
    expect(iagp_an_stub.calledOnce).to.be.true;
  	expect(iagp_al_stub.calledOnce).to.be.true;
  	expect(iagp_d_stub.calledOnce).to.be.true;
  	expect(win_da_stub.notCalled).to.be.true;
    expect(iagp_an_stub.getCall(0).args[0].uri).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(iagp_an_stub.getCall(0).args[0].type).to.equal("OTHER_TYPE");
    expect(tc_a_stub.notCalled).to.be.true;
    expect(mi_a_stub.calledOnce).to.be.true;
    expect(mi_a_stub.getCall(0).args[0]).to.equal("http://www.example.com/D#FRAGMENT2");
    expect(mi_a_stub.getCall(0).args[1]).to.equal(4);
    expect(ia.ajaxCount).to.equal(21);
		expect(finished).to.equal(false);
		iagp_an_stub.restore();
  	iagp_al_stub.restore();
  	iagp_d_stub.restore();
  	tc_a_stub.restore();
  	mi_a_stub.restore();
  	win_da_stub.restore();  
 	}); 	

 	xit('processes a child, recurse', function() {});

});