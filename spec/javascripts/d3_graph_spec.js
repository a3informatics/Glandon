//= require colour
//= require d3_graph
//= require rspec_helper

describe("D3 Graph", function() {
	
	var lastClickNode;
	var lastDblClickNode;
	
  function click (node) {
  	lastClickNode = node;
 	}

	function dblClick (node) {
  	lastDblClickNode = node;
  }
  
  beforeEach(function() {
  	fixture.set('<div id="d3"></div>');
  	d3Div = document.getElementById("d3");
  	var graph = { "nodes": [], "links": []};
		graph.nodes.push({"index": 0, "name": "node1", "key": 1, "rdf_type": "http://www.example.com/type1"});
		graph.nodes.push({"index": 1, "name": "node2", "key": 2, "rdf_type": "http://www.example.com/type2"});
		graph.nodes.push({"index": 2, "name": "node3", "key": 3, "rdf_type": "http://www.example.com/type3"});
		graph.nodes.push({"index": 3, "name": "node4", "key": 4, "rdf_type": "http://www.example.com/type4"});
		graph.nodes.push({"index": 4, "name": "node5", "key": 5, "rdf_type": "http://www.example.com/type5"});
		graph.nodes.push({"index": 5, "name": "node6", "key": 6, "rdf_type": "http://www.example.com/type6"});
		graph.nodes.push({"index": 6, "name": "node7", "key": 7, "rdf_type": "http://www.example.com/type7"});
		graph.nodes.push({"index": 7, "name": "node8", "key": 8, "rdf_type": "http://www.example.com/type8"});
		graph.nodes.push({"index": 8, "name": "node9", "key": 9, "rdf_type": "http://www.example.com/type9"});
		graph.nodes.push({"index": 9, "name": "node10", "key": 10, "rdf_type": "http://www.example.com/type10"});
		graph.links.push({"source": 0, "target": 1});
		graph.links.push({"source": 0, "target": 2});
		graph.links.push({"source": 0, "target": 3});
		graph.links.push({"source": 0, "target": 4});
		graph.links.push({"source": 0, "target": 5});
		graph.links.push({"source": 5, "target": 6});
		graph.links.push({"source": 5, "target": 7});
		graph.links.push({"source": 8, "target": 6});
		graph.links.push({"source": 8, "target": 7});
		graph.links.push({"source": 4, "target": 5});
		d3gInit(colours, 50)
		d3gDraw(graph, click, dblClick);
	});

  it("initialises the tree", function() {
  	var x = 1;
		var selection = d3.selectAll("circle");
		var d3Nodes = selection[0];
		expect(d3Nodes[0].__data__.key).to.equal(1);
		expect(d3Nodes[0].__data__.name).to.equal("node1");
		expect(d3Nodes[0].__data__.rdf_type).to.equal("http://www.example.com/type1");
		expect(d3Nodes[1].__data__.key).to.equal(2);
		expect(d3Nodes[1].__data__.name).to.equal("node2");
		expect(d3Nodes[1].__data__.rdf_type).to.equal("http://www.example.com/type2");
		expect(d3Nodes[2].__data__.key).to.equal(3);
		expect(d3Nodes[2].__data__.name).to.equal("node3");
		expect(d3Nodes[2].__data__.rdf_type).to.equal("http://www.example.com/type3");
		expect(d3Nodes[3].__data__.key).to.equal(4);
		expect(d3Nodes[3].__data__.name).to.equal("node4");
		expect(d3Nodes[3].__data__.rdf_type).to.equal("http://www.example.com/type4");
		expect(d3Nodes[4].__data__.key).to.equal(5);
		expect(d3Nodes[4].__data__.name).to.equal("node5");
		expect(d3Nodes[4].__data__.rdf_type).to.equal("http://www.example.com/type5");
		expect(d3Nodes[5].__data__.key).to.equal(6);
		expect(d3Nodes[5].__data__.name).to.equal("node6");
		expect(d3Nodes[5].__data__.rdf_type).to.equal("http://www.example.com/type6");
		expect(d3Nodes[6].__data__.key).to.equal(7);
		expect(d3Nodes[6].__data__.name).to.equal("node7");
		expect(d3Nodes[6].__data__.rdf_type).to.equal("http://www.example.com/type7");
		expect(d3Nodes[7].__data__.key).to.equal(8);
		expect(d3Nodes[7].__data__.name).to.equal("node8");
		expect(d3Nodes[7].__data__.rdf_type).to.equal("http://www.example.com/type8");
		expect(d3Nodes[8].__data__.key).to.equal(9);
		expect(d3Nodes[8].__data__.name).to.equal("node9");
		expect(d3Nodes[8].__data__.rdf_type).to.equal("http://www.example.com/type9");
		expect(d3Nodes[9].__data__.key).to.equal(10);
		expect(d3Nodes[9].__data__.name).to.equal("node10");
		expect(d3Nodes[9].__data__.rdf_type).to.equal("http://www.example.com/type10");
  });

 	it("handles click event", function() {
 		var gRef = d3gFindGRef(2);
		simulateClick(gRef);
		expect(lastClickNode.rdf_type).to.equal("http://www.example.com/type2");		
 	});

 	// Double click not handled using this mechanism anymore.
 	//it("handles double click event", function() {
 	//	var gRef = d3gFindGRef(3);
	//	simulateDblClick(gRef);
	//	expect(lastDblClickNode.rdf_type).to.equal("http://www.example.com/type3");		
 	//});

 	it("allows a node to be marked by reference", function() {
 		var gRef = d3gFindGRef(2);
		d3gMarkNode(gRef);
		expect(gRef.style.fill).to.equal("gray");
  });

 	it("allows a node to be cleared reference", function() {
 		var gRef = d3gFindGRef(4);
		d3gMarkNode(gRef);
		expect(gRef.style.fill).to.equal("gray");
		d3gClearNode (gRef);
		expect(gRef.style.fill).to.equal("black");
  });

 	it("allows a node reference to be obtained by key", function() {
 		var gRef = d3gFindGRef(2);
		expect(gRef.__data__.key).to.equal(2); 		
  	expect(gRef.__data__.rdf_type).to.equal("http://www.example.com/type2");
	});

});