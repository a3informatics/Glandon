//= require d3_tree
//= require rspec_helper

describe("D3 Tree", function() {
	
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
		rootData = {type: "data_root"};
		rootNode = {name: "root", enabled: true, key: 1, data: rootData, children: []};
		child1Data = {type: "data_child_1"};
		child1Node = {name: "child1", enabled: true, key: 2, data: child1Data};
		rootNode.children.push(child1Node);
		child2Data = {type: "data_child_2"};
		child2Node = {name: "child2", enabled: true, key: 3, data: child2Data};
		rootNode.children.push(child2Node);
		child3Data = {type: "data_child_3"};
		child3Node = {name: "child3", enabled: true, key: 4, data: child3Data};
		rootNode.children.push(child3Node);
		d3TreeNormal(d3Div, rootNode, click, dblClick);
	});

  it("initialises the tree", function() {
		var selection = d3.selectAll("g.node");
		var d3Nodes = selection[0];
		expect(d3Nodes[0].__data__.key).to.equal(1);
		expect(d3Nodes[0].__data__.data.type).to.equal("data_root");
		expect(d3Nodes[1].__data__.key).to.equal(2);
		expect(d3Nodes[1].__data__.data.type).to.equal("data_child_1");
		expect(d3Nodes[2].__data__.key).to.equal(3);
		expect(d3Nodes[2].__data__.data.type).to.equal("data_child_2");
		expect(d3Nodes[3].__data__.key).to.equal(4);
		expect(d3Nodes[3].__data__.data.type).to.equal("data_child_3");
  });

 	it("handles click event", function() {
 		var gRef = d3FindGRef(2);
		simulateClick(gRef);
		expect(lastClickNode.data.type).to.equal("data_child_1");		
 	});

 	it("handles double click event", function() {
 		var gRef = d3FindGRef(3);
		simulateDblClick(gRef);
		expect(lastDblClickNode.data.type).to.equal("data_child_2");		
 	});

 	it("allows a node to be marked by reference", function() {
 		var gRef = d3FindGRef(2);
		d3MarkNode(gRef);
		expect(selectedNodeTest(getFill(gRef))).to.equal(true);
  });

 	it("allows a node reference to be obtained by key", function() {
 		var gRef = d3FindGRef(2);
		expect(gRef.__data__.key).to.equal(2); 		
  	expect(gRef.__data__.data.type).to.equal("data_child_1");
	});

 	it("allows a node reference to be obtained by name", function() {
 		var gRef = d3FindGRefByName("child3");
		expect(gRef.__data__.key).to.equal(4); 		
  	expect(gRef.__data__.data.type).to.equal("data_child_3");
  });

 	it("allows the data from a node to be obtained by reference", function() {
 		var data = d3FindData(4);
		expect(data.data.type).to.equal("data_child_3"); 		
  });

 	it("allows the data from a node to be obtained by key", function() {
 		var gRef = d3FindGRefByName("child3");
		var data = d3GetData(gRef);
		expect(data.key).to.equal(4); 		
  });

 	it("allows a node to be restored", function() {
 		var gRef = d3FindGRef(2);
		var data = d3GetData(gRef);
		data.enabled = false;
		d3RestoreNode(gRef);
		expect(disabledNodeTest(getFill(gRef))).to.equal(true);
		data.enabled = true;
		d3RestoreNode(gRef);
		expect(enabledNodeTest(getFill(gRef))).to.equal(true);
  });

 	it("sets the node colour", function() {
 		node = {};
 		node.expand = true;
 		expect(d3NodeColour(node)).to.equal("skyblue");
 		node.expand = false;
 		expect(d3NodeColour(node)).to.equal("white");
 		node.enabled = true;
 		expect(d3NodeColour(node)).to.equal("mediumseagreen");
 		node.is_common = true;
 		expect(d3NodeColour(node)).to.equal("silver");
 		node.is_common = false;
 		expect(d3NodeColour(node)).to.equal("mediumseagreen");
 		node.enabled = false;
 		expect(d3NodeColour(node)).to.equal("orangered");
  });

 	it("sets the text colour", function() {
 		node = {};
 		expect(d3TextColour(node)).to.equal("black");
 		node.is_common = false;
 		expect(d3TextColour(node)).to.equal("black");
 		node.is_common = true;
 		expect(d3TextColour(node)).to.equal("silver");
  });

 	xit("adjusts the height", function() {
 		//expect(true).to.equal(false);
  	//pending();
  });

});