//= require application
//= require colour
//= require d3_graph
//= require sinon
//= require impact_analysis_graph_panel

describe("Impact Analysis Graph Panel", function() {
	
	var lastClickNode;
	
  function clickCallBack (node) {
  	lastClickNode = node;
 	}

	beforeEach(function() {
  	fixture.set('<div id="d3"></div>');
	});

  it("initialises the object", function() {
  	var iagp = new ImpactAnalysisGraphPanel(clickCallBack);
  	expect(iagp.graph.nodes).to.eql([]);
  	expect(iagp.graph.links).to.eql([]);
  	expect(iagp.currentNode).to.equal(null);
  	expect(iagp.currentGRef).to.equal(null);
  	expect(iagp.nextKey).to.equal(1);
  	expect(iagp.map).to.eql({});
  });

 	it("add node", function() {
  	var iagp = new ImpactAnalysisGraphPanel(clickCallBack);
  	var node1 = {"label": "NODE 1", "rdf_type": C_FORM, "namespace": "http://www.example.com/", "id": "a"};
  	expect(node1.rdf_type).to.equal(C_FORM);		
  	var graphNode1 = iagp.addNode(node1);
  	expect(node1.type).to.equal(C_FORM);		
  	expect(graphNode1.type).to.equal(C_FORM);		
		expect(graphNode1.rdf_type).to.equal(C_FORM);		
		expect(graphNode1.index).to.equal(0);		
		expect(graphNode1.key).to.equal(1);		
		expect(graphNode1.label).to.equal("NODE 1");		
 	});

 	it("add nodes", function() {
  	var graph = new ImpactAnalysisGraphPanel(clickCallBack);
  	node1 = {"label": "NODE 1", "rdf_type": C_FORM, namespace: "http://www.example.com/", id: "a"};
  	node2 = {"label": "NODE 2", "rdf_type": C_BC, namespace: "http://www.example.com/", id: "b"};
  	graphNode1 = graph.addNode(node1);
  	graphNode2 = graph.addNode(node2);
		expect(graphNode1.type).to.equal(C_FORM);		
		expect(graphNode1.rdf_type).to.equal(C_FORM);		
		expect(graphNode1.index).to.equal(0);		
		expect(graphNode1.key).to.equal(1);		
		expect(graphNode1.label).to.equal("NODE 1");		
		expect(graphNode2.type).to.equal(C_BC);		
		expect(graphNode2.rdf_type).to.equal(C_BC);		
		expect(graphNode2.index).to.equal(1);		
		expect(graphNode2.key).to.equal(2);		
		expect(graphNode2.label).to.equal("NODE 2");		
  	expect(graph.graph.nodes.length).to.equal(2);		
  	graphNode3 = graph.addNode(node2);
  	expect(graph.graph.nodes.length).to.equal(2);		
		expect(graphNode3.label).to.equal("NODE 2");		
 	});

 	it("add link", function() {
  	var graph = new ImpactAnalysisGraphPanel(clickCallBack);
  	node1 = {"label": "NODE 1", "rdf_type": C_FORM};
  	node2 = {"label": "NODE 2", "rdf_type": C_BC};
  	graphNode1 = graph.addNode(node1);
		graphNode1 = graph.addNode(node1);
		result = graph.addLink(graphNode1.index, graphNode2.index);
		expect(result).to.equal(true);		
 	});

 	it("draws the graph", function() {
 		var graph = new ImpactAnalysisGraphPanel(clickCallBack);
  	stub = sinon.stub(window , "d3gDraw");
  	graph.draw();
  	expect(stub.calledOnce).to.be.true;
  	expect(stub.getCall(0).args[0].nodes).to.eql([]);
  	expect(stub.getCall(0).args[0].links).to.eql([]);
  	// Don't compare args for the functions being passed.
  	stub.restore();
 	});

 	it("handles a node click", function() {
 		var ref = {ref: 41}
 		var graph = new ImpactAnalysisGraphPanel(clickCallBack);
  	stub_cn = sinon.stub(window , "d3gClearNode");
  	stub_mn = sinon.stub(window , "d3gMarkNode");
  	stub_fg = sinon.stub(window , "d3gFindGRef");
  	stub_fg.onCall(0).returns(null);
  	stub_fg.onCall(1).returns(ref);
  	stub_fg.onCall(2).returns(ref);
  	node = { key: 353 };

  	graph.nodeClick(node);
  	expect(stub_cn.notCalled).to.be.true;
  	expect(stub_mn.notCalled).to.be.true;
  	expect(stub_fg.calledOnce).to.be.true;
  	expect(stub_fg.getCall(0).args[0]).to.equal(353);

  	graph.nodeClick(node);
  	//expect(stub_cn.calledOnce).to.be.true;
  	expect(stub_mn.calledOnce).to.be.true;
  	expect(graph.currentNode.key).to.equal(353);
  	expect(lastClickNode.key).to.equal(353);

  	graph.nodeClick(node);
  	expect(stub_cn.calledOnce).to.be.true;
  	expect(stub_mn.calledTwice).to.be.true; // Second call now
  	expect(graph.currentNode.key).to.equal(353);
  	expect(lastClickNode.key).to.equal(353);

  	stub_cn.restore();
  	stub_mn.restore();
  	stub_fg.restore();
 	});

});