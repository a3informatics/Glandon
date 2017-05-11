//= require application
//= require colour
//= require d3_graph
//= require impact_graph_panel
//= require rspec_helper

describe("Impact Graph Panel", function() {
	
	var lastClickNode;
	var spy;

  function click (node) {
  	lastClickNode = node;
 	}

	beforeEach(function() {
  	fixture.set('<div id="d3"></div>');
	});

  it("initialises the object", function() {
  	var graph = new ImpactGraphPanel(click);
  });

 	it("add node", function() {
  	var graph = new ImpactGraphPanel(click);
  	node1 = {"label": "NODE 1", "rdf_type": C_FORM};
  	graphNode1 = graph.addNode(node1);
		expect(graphNode1.type).to.equal(C_FORM);		
		expect(graphNode1.rdf_type).to.equal(C_FORM);		
		expect(graphNode1.index).to.equal(0);		
		expect(graphNode1.key).to.equal(1);		
		expect(graphNode1.label).to.equal("NODE 1");		
 	});

 	it("add nodes", function() {
  	var graph = new ImpactGraphPanel(click);
  	node1 = {"label": "NODE 1", "rdf_type": C_FORM};
  	node2 = {"label": "NODE 2", "rdf_type": C_BC};
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
 	});

 	it("add link", function() {
  	var graph = new ImpactGraphPanel(click);
  	node1 = {"label": "NODE 1", "rdf_type": C_FORM};
  	node2 = {"label": "NODE 2", "rdf_type": C_BC};
  	graphNode1 = graph.addNode(node1);
		graphNode1 = graph.addNode(node1);
		result = graph.addLink(graphNode1.index, graphNode2.index);
		expect(result).to.equal(true);		
 	});

});