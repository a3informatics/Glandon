//= require d3_tree
//= require d3_editor
//= require rspec_helper

describe("D3 Editor", function() {

  var lastClickPreNode;
	var lastClickPostNode;
	var lastDblClickNode;
	var lastValidateNode;
	var validateTrueFalse = true;

  function clickPre (node) {
  	lastClickPreNode = node;
 	}

	function clickPost (node) {
  	lastClickPostNode = node;
 	}

	function dblClick (node) {
  	lastDblClickNode = node;
  }
  
  function validateCallBack (node) {
  	lastValidateNode = node;
  	return validateTrueFalse;
  }

  function testTree() {
  	d3eInit("d3", clickPre, clickPost, dblClick, validateCallBack);
  	var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	var data4 = {name: "level-1-data-4"};
  	var node4 = d3eAddNode(root_node, "child-4", "level-1-type", false, data4, true);
  	d3eAddData(root_node, data4, true);
  	var data5 = {name: "level-2-data-5"};
  	var node5 = d3eAddNode(node1, "child-5", "level-2-type", false, data5, true);
  	d3eAddData(node1, data5, true);
  	var data6 = {name: "level-2-data-6"};
  	var node6 = d3eAddNode(node1, "child-6", "level-2-type", false, data6, true);
  	d3eAddData(node1, data6, true);
  	return root_node;
  }

  beforeEach(function() {
  	fixture.set('<div id="d3" style="height: 300px; width: 300px"></div>');
  	//d3Div = document.getElementById("d3");
	});

  it("initialises the editor", function() {
  	d3eInit("d3", clickPre, clickPost, dblClick, validateCallBack);
  	expect(d3eNextKeyId).to.equal(1);
  	expect(d3eCurrentGRef).to.equal(null);
  	expect(d3eCurrentNode).to.equal(null);
  	expect(d3eRootNode).to.equal(null);
  	expect(d3eClickCallBackPre).to.equal(clickPre);
  	expect(d3eClickCallBackPost).to.equal(clickPost);
  	expect(d3eDblClickCallBackPost).to.equal(dblClick);
  	expect(d3eValidateCallBack).to.equal(validateCallBack);
  });

	it("determines if current set", function() {
		var rootNode = testTree();
		expect(d3eCurrentSet()).to.equal(false);
		var rootGRef = d3FindGRef(rootNode.key);
		d3eDisplayTree(rootNode.key);
		expect(d3eCurrentSet()).to.equal(true);
  });  
	
	it("gets the current node", function() {
		var rootNode = testTree();
		var rootGRef = d3FindGRef(rootNode.key);
		d3eDisplayTree(rootNode.key);
		expect(d3eGetCurrent()).to.equal(rootNode);
  });
  
	
	it("handles a click on a node", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var gRef = d3FindGRef(3);
		var nodeData = d3FindData(3);
		simulateClick(gRef);
		expect(lastClickPostNode.name).to.equal("child-2");
		expect(d3eCurrentNode).to.equal(nodeData);
		expect(d3eCurrentGRef).to.not.be.null;
		expect(selectedNodeTest(getFill(gRef))).to.equal(true);
		var prevGRef = gRef;
		var gRef = d3FindGRef(4);
		var nodeData = d3FindData(4);
		simulateClick(gRef);
		expect(lastClickPreNode.name).to.equal("child-2");
		expect(lastClickPostNode.name).to.equal("child-3");
		expect(d3eCurrentNode).to.equal(nodeData);
		expect(d3eCurrentGRef).to.not.be.null;
		expect(disabledNodeTest(getFill(prevGRef))).to.equal(true);
		expect(selectedNodeTest(getFill(prevGRef))).to.equal(false);
		expect(selectedNodeTest(getFill(gRef))).to.equal(true);
  });
  
  it("handles a click on a node, validation passes and fails", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var gRef = d3FindGRef(4);
		validateTrueFalse = true;
  	simulateClick(gRef);
		expect(lastValidateNode.name).to.equal("root");
		// Validation passes
		validateTrueFalse = true;
  	gRef = d3FindGRef(3);
		simulateClick(gRef);
		expect(lastValidateNode.name).to.equal("child-3");
		expect(lastClickPreNode.name).to.equal("child-3");
		expect(lastClickPostNode.name).to.equal("child-2");
		// Validation fails
		lastValidateNode = null;
		lastClickPreNode = null;
		lastClickPostNode = null;
		validateTrueFalse = false;
  	gRef = d3FindGRef(4);
		simulateClick(gRef);
		expect(lastValidateNode.name).to.equal("child-2");
		expect(lastClickPreNode).to.be.null;
		expect(lastClickPostNode).to.be.null;
		validateTrueFalse = true; // Set back to true for all other tests
  });
	    
	it("handles a double click on a node", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var gRef = d3FindGRefByName("child-1");
		var fill = getFill(gRef)
		simulateDblClick(gRef);
		expect(lastDblClickNode.name).to.equal("child-1");
		var hiddenGRef = d3FindGRefByName("child-1"); // Have to refresh reference, new tree after double click
		expect(selectedNodeTest(getFill(hiddenGRef))).to.equal(true);		
		var otherGRef = d3FindGRefByName("child-2");  
		simulateClick(otherGRef);
		expect(selectedNodeTest(getFill(otherGRef))).to.equal(true);		
		expect(hiddenNodeTest(getFill(hiddenGRef))).to.equal(true);		
		simulateDblClick(hiddenGRef);
		var hiddenGRef = d3FindGRefByName("child-1"); // Have to refresh reference, new tree after double click
		expect(hiddenNodeTest(getFill(hiddenGRef))).to.equal(false);		
  });
  
	
	it("expand / hide a node", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var node = d3FindData(2);
		expect(node.name).to.equal("child-1")
		d3eExpandHide(node);
		expect(node.children.length).to.equal(0);
		expect(node.expand).to.equal(true);
		d3eExpandHide(node);
		expect(node.children.length).to.equal(2);
		expect(node.expand).to.equal(false);
		node = d3FindData(6);
		d3eExpandHide(node);
		expect(node.hasOwnProperty('children')).to.equal(false);
		expect(node.expand).to.equal(false);
  });
  
	it("forces a the child nodes to be hidden", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var node = d3FindData(2);
		expect(node.expand).to.equal(false);
		d3eForceHide(node);
		expect(node.expand).to.equal(true);
  });
  
	
	it("forces the child nodes to be expanded", function() {
		var rootNode = testTree();
		d3eDisplayTree(rootNode.key);
		var node = d3FindData(2);
		expect(node.expand).to.equal(false);
		d3eForceHide(node);
		expect(node.children.length).to.equal(0);
		expect(node.expand).to.equal(true);
		d3eForceExpand(node);
		expect(node.children.length).to.equal(2);
		expect(node.expand).to.equal(false);
  });
  
	
	it("display the tree with focus being given to a specified node", function() {
		var rootNode = testTree();
		var rootGRef = d3FindGRef(rootNode.key);
		d3eDisplayTree(rootNode.key);
		expect(d3eCurrentNode).to.equal(rootNode);
		expect(d3eCurrentGRef).to.not.be.null;
		expect(selectedNodeTest(getFill(d3eCurrentGRef))).to.equal(true);
  });
  
	
	it("deletes a node", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	d3eDeleteNode(node1);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-2");
		var data4 = {name: "level-1-data-4"};
  	var node4 = d3eAddNode(root_node, "child-4", "level-1-type", false, data4, true);
  	d3eAddData(root_node, data4, true);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-2");
  	expect(root_node.save[2].data.name).to.equal("level-1-data-4");
  	d3eDeleteNode(node3);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-2");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-4");
  	d3eDeleteNode(node4);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-2");
  });
  
	
	it("moves a node up, prevents going past start", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	d3eMoveNodeUp(node3);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-1");
  	expect(root_node.save[2].data.name).to.equal("level-1-data-2");
  });
  
	it("moves a node up", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	d3eMoveNodeUp(node1);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-1");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[2].data.name).to.equal("level-1-data-2");
  });
  
	it("moves a node down, prevents going past end", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	d3eMoveNodeDown(node2);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-1");
  	expect(root_node.save[2].data.name).to.equal("level-1-data-2");
  });

  it("moves a node down", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
  	d3eMoveNodeDown(node1);
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3");
  	expect(root_node.save[1].data.name).to.equal("level-1-data-2");
  	expect(root_node.save[2].data.name).to.equal("level-1-data-1");
  });
  
  it("get the last key used", function() {
  	var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	expect(d3eLastKey()).to.equal(3);
  	var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	expect(d3eLastKey()).to.equal(4);
  });
  
	it("determines if a node has children", function() {
		var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	hasChildren = d3eHasChildren(root_node);
  	expect(hasChildren).to.equal(true);
  	hasChildren = d3eHasChildren(node2);
  	expect(hasChildren).to.equal(false);
  });
	
	it("add data to a node plus builds data hierarchy", function() {
  	var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true);
		d3eAddData(root_node, data1, true);
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true);
  	d3eAddData(root_node, data2, true);
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false);
  	d3eAddData(root_node, data3, false);
		expect(root_node.data.children[0].name).to.equal("level-1-data-3");
  	expect(root_node.data.children[1].name).to.equal("level-1-data-1");
  	expect(root_node.data.children[2].name).to.equal("level-1-data-2");
	});
		
	it("adds a node, first child", function() {
  	var data = {name: "root-data"};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data"};
  	node = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true)
		expect(node.name).to.equal("child-1");
		expect(node.type).to.equal("level-1-type");
		expect(node.enabled).to.equal(false);
		expect(node.is_common).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.key).to.equal(2);
		expect(node.parent.name).to.equal("root");
		expect(node.data).to.equal(data1);
		expect(node.expand).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.save.length).to.equal(0);
		expect(node.children.length).to.equal(0);
		expect(root_node.save.length).to.equal(1);
		expect(root_node.children.length).to.equal(1);
		expect(d3eNextKeyId).to.equal(3);
	});
	
	it("adds a node, first child, data has common", function() {
  	var data = {name: "root-data"};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data", is_common: true};
  	node = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true)
		expect(node.name).to.equal("child-1");
		expect(node.type).to.equal("level-1-type");
		expect(node.enabled).to.equal(false);
		expect(node.is_common).to.equal(true);
		expect(node.index).to.equal(0);
		expect(node.key).to.equal(2);
		expect(node.parent.name).to.equal("root");
		expect(node.data).to.equal(data1);
		expect(node.expand).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.save.length).to.equal(0);
		expect(node.children.length).to.equal(0);
		expect(root_node.save.length).to.equal(1);
		expect(root_node.children.length).to.equal(1);
		expect(d3eNextKeyId).to.equal(3);
	});

	it("adds a node, first child, parent has common", function() {
  	var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data"};
  	node = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true)
		expect(node.name).to.equal("child-1");
		expect(node.type).to.equal("level-1-type");
		expect(node.enabled).to.equal(false);
		expect(node.is_common).to.equal(true);
		expect(node.index).to.equal(0);
		expect(node.key).to.equal(2);
		expect(node.parent.name).to.equal("root");
		expect(node.data).to.equal(data1);
		expect(node.expand).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.save.length).to.equal(0);
		expect(node.children.length).to.equal(0);
		expect(root_node.save.length).to.equal(1);
		expect(root_node.children.length).to.equal(1);
		expect(d3eNextKeyId).to.equal(3);
	});

	it("adds a node, adds at end and then at front plus creates parent save", function() {
  	var data = {name: "root-data", is_common: true};
  	var root_node = d3eRoot("root", "x-type", data);
		var data1 = {name: "level-1-data-1"};
  	var node1 = d3eAddNode(root_node, "child-1", "level-1-type", false, data1, true)
		var data2 = {name: "level-1-data-2"};
  	var node2 = d3eAddNode(root_node, "child-2", "level-1-type", false, data2, true)
  	expect(root_node.save[0].data.name).to.equal("level-1-data-1")
  	expect(root_node.save[1].data.name).to.equal("level-1-data-2")
		var data3 = {name: "level-1-data-3"};
  	var node3 = d3eAddNode(root_node, "child-3", "level-1-type", false, data3, false)
  	expect(root_node.save[0].data.name).to.equal("level-1-data-3")
  	expect(root_node.save[1].data.name).to.equal("level-1-data-1")
  	expect(root_node.save[2].data.name).to.equal("level-1-data-2")
  	expect(root_node.children[0].data.name).to.equal("level-1-data-3")
  	expect(root_node.children[1].data.name).to.equal("level-1-data-1")
  	expect(root_node.children[2].data.name).to.equal("level-1-data-2")
		expect(d3eNextKeyId).to.equal(5);
	});

	it("can create the root node", function() {
		var data = {name: "data_node"}
  	var node = d3eRoot("root", "x-type", data);
		expect(node.name).to.equal("root");
		expect(node.type).to.equal("x-type");
		expect(node.enabled).to.equal(true);
		expect(node.is_common).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.key).to.equal(1);
		expect(node.parent).to.equal(null);
		expect(node.data).to.equal(data);
		expect(node.expand).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.save.length).to.equal(0);
		expect(node.children.length).to.equal(0);
  });

  it("creates an empty node", function() {
    var node = d3eEmptyNode();
		expect(node.name).to.equal("");
		expect(node.type).to.equal("");
		expect(node.enabled).to.equal(true);
		expect(node.is_common).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.key).to.equal(0);
		expect(node.parent).to.equal(null);
		expect(node.data).to.equal(null);
		expect(node.expand).to.equal(false);
		expect(node.index).to.equal(0);
		expect(node.save.length).to.equal(0);
		expect(node.children.length).to.equal(0);
  });

  it("sets the parent of the child nodes", function() {
    var index = 2;
		var node = {};
		node.id = "R";
		node.label = "Root"
		node.save = [];
		for (var i=0; i<4; i++) {
			node.save.push({id: "R." + i, label: "node_" + index});
			index++; 
			var child = node.save[i];
			child.save = [];
			for (var j=0; j<4; j++) {
				child.save.push({id: "R." + i + "." + j, label: "node_" + i});
				index++;
			}
		}
		d3eSetParent(node);
		for (var i=0; i<4; i++) {
			var child = node.save[i];
			expect(child.parent.id).to.equal("R")
			for (var j=0; j<4; j++) {
				expect(child.save[0].parent.id).to.equal("R." + i);
			}
		}
  });

  it("sets the ordinal", function() {
    node = {};
		node.label = "test";
		node.children = [];
		node.ordinal = 0;
		for (var i=0; i<4; i++) {
			node.children.push({id: i, label: "node_" + i}) 
		}
		d3eSetOrdinal(node);
		for (var i=0; i<4; i++) {
			expect(node.children[i].ordinal).to.equal(i + 1);
		}
  });

  it("does not set the ordinal when there are no children", function() {
    node = {};
		node.label = "test";
		node.children = [];
		d3eSetOrdinal(node);
		expect(node.label).to.equal("test");
		expect(node.children.length).to.equal(0);
  });

});