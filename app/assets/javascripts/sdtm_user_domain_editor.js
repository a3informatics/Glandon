$(document).ready(function() {
  
  var C_DOMAIN = "http://www.assero.co.uk/BusinessDomain#UserDomain";
  var C_VARIABLE = "http://www.assero.co.uk/BusinessDomain#UserVariable";

  var domainDefinition;
  var html;
  var d3Div;

  var domainPrefixElement = document.getElementById("domainPrefix");
  var domainLabelElement = document.getElementById("domainLabel");
  var domainNoteElement = document.getElementById("domainNotes");
  var variableLabelElement = document.getElementById("variableLabel");
  var variableCompletionElement = document.getElementById("variableCompletion");
  var variableNoteElement = document.getElementById("variableNote");
  var variableRepeatingElement = document.getElementById("variableRepeating");
  var variableOptionalElement = document.getElementById("variableOptional");
  var genericMarkdownElement = document.getElementById("genericMarkdown");

  var nextKeyId;
  var currentNode;
  var currentGRef;
  var rootNode;
  var editIdentifierFlag;               
  var markdownElement;
  var markdownType;

  // Set up the form validation
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
        "Domain Prefix": {required: true, identifier: true },
        "Domain Label": {required: true, label: true },
        "Domain Note": {required: false, markdown: true},
        "Domain Comment": {required: false, markdown: true},
        "Variable Label": {required: true, label: true },
        "Variable Note": {required: false, markdown: true}
    },
    submitHandler: function(form) {
      domainSave();
      return false;
    },
    invalidHandler: function(event, validator) {
      var html = alertWarning("The form is not valid. Please correct the errors.");
      displayAlerts(html);
    }
  });

  // Get elements from the form.
  d3Div = document.getElementById("d3");
  
  // Init any data
  initData();

  // Draw the initial tree and select the form.
  setRoot();

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {    
    if (currentGRef != null) {
      clearNode(currentNode, currentGRef);
      if (currentNode.type == C_DOMAIN) {
        saveDomain(currentNode)
      } else if (currentNode.type == C_VARIABLE) {
        saveVariable(currentNode)
      }
    }
    displayNode(node)
    markNode1(this);
    currentGRef = this;
    currentNode = node;
  }  

  /**
   * Function to handle double click on the D3 tree.
   * Expand/delete the node clicked.
   */
  function dblClick(node) {
    if (node.expand) {
      node.children = node.save;
      node.expand = false;
      displayTree(node.key);
    } else if (node.hasOwnProperty('children')) {
      node.children = [];
      node.expand = true;
      displayTree(node.key); 
    }
  } 

  /* 
  * Function to handle the form save click.
  */
  function domainSave() {
    var uri;
    var method;
    var data;
    var action;
    var domain;
    action = domainDefinition.operation.action;
    domain = domainDefinition.managed_item;   
    if (action === "CREATE") {
      url = "/sdtm_user_domains";
      method = 'POST';
      data = { "data": domainDefinition };  
    } else {
      url = "/sdtm_user_domains/" + domain['id'];
      method = 'PUT';
      data = { "namespace": domain['namespace'], "data": domainDefinition };  
    }
    $.ajax({
      url: url,
      type: method,
      data: data,
      success: function(result){
        var html = alertSuccess("Domain has been saved.");
        displayAlerts(html);
        
        // Indicate now edit. Stops identifier being modified. Probably
        // a better way to do this, existing function.
        editIdentifierFlag = false;
        formIdentifierElement.disabled = true;

        // Save the URI of the saved form.
        var managedItem = result.data.managed_item;
        domainDefinition.operation.action = "UPDATE";
        domainDefinition.managed_item.id = managedItem.id;
        domainDefinition.managed_item.namespace = managedItem.namespace;
      },
      error: function(xhr, status, error){
        handleAjaxError (xhr, status, error);
      }
    }); 
  }

  /*
   * Functions to handle the form actions.
   */
  $('#domainUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select the domain node.");
      displayAlerts(html);
    } else {
      $('#main_form').valid();
        saveDomain(currentNode);
        displayTree(currentNode.key);
    }
  });

  /*$('#domainAddGroup').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select the domain node.");
      displayAlerts(html);
    } else {
      var node = addGroup();
      displayNode(node);
      displayTree(node.key);  
    }
  });

  /*
  * Functions to handle the group actions
  */
  /*$('#variableUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      $('#main_form').valid();
      saveGroup(currentNode)
      displayTree(currentNode.key);
    }
  });
  
  $('#variableAddGroup').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      var node = addGroup();
      displayNode(node);
      displayTree(node.key);  
    }
  });

  $('#variableDelete').click(function() {
    if (hasChildren(currentNode)) {
      var html = alertWarning("You need to delete the child nodes.");
      displayAlerts(html);
    } else {
      var node = deleteNode(currentNode);
      displayNode(node);
      displayTree(node.key);
    }     
  });

  $('#variableAddCommon').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else if (hasCommon(currentNode)) {
      var html = alertWarning("Group already has a common node.");
      displayAlerts(html);
    } else {
      var node = addCommon();
      displayNode(node);
      displayTree(node.key);
    }
  }); 

  $('#variableAddBc').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else if (bcCurrent ==  null) {
      var html = alertWarning("You need to select a Biomedical Concept.");
      displayAlerts(html);
    } else {
      addBc();
    }
  }); 

  $('#variableUp').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index != 0) {
        moveNodeUp(currentNode);
        displayNode(currentNode);
        displayTree(currentNode.key);
      } else {
        var html = alertWarning("You cannot move the node up.");
        displayAlerts(html);
      }
    }
  }); 

  $('#variableDown').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index < parentNode.save.length) {
        moveNodeDown(currentNode);
        displayNode(currentNode);
        displayTree(currentNode.key);
      } else {
        var html = alertWarning("You cannot move the node down.");
        displayAlerts(html);
      }
    }
  }); 

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      var html = alertWarning("You need to select a completion instruction field.");
      displayAlerts(html);
    } else {
      var text = markdownElement.value;
      getMarkdown(genericMarkdownElement, text);  
    }
  });

  $('#markdown_hide').click(function() {
    hideCi();
    if (markdownType == C_DOMAIN) {
      showBCSelection();
    } else if (markdownType == C_QUESTION) {
      showNotepad();    
    }
    markdownElement = null;
    markdownType = "";
  });

  /*
  * Completion and notes focus functions
  */
  $( "#domainNotes" ).focus(function() {
    showCi();
    markdownType = C_DOMAIN;
    markdownElement = domainNoteElement;
    var text = markdownElement.value;
    getMarkdown(genericMarkdownElement, text);
  });

  /*$( "#variableCompletion" ).focus(function() {
    hideBCSelection();
    showCi();
    markdownType = C_DOMAIN;
    markdownElement = groupCompletionElement;
    var text = markdownElement.value;
    getMarkdown(genericMarkdownElement, text);
  });

  $( "#variableNote" ).focus(function() {
    hideBCSelection();
    showCi();
    markdownType = C_DOMAIN;
    markdownElement = groupNoteElement;
    var text = markdownElement.value;
    getMarkdown(genericMarkdownElement, text);
  });

  /* ****************
  * Utility Functions
  */
  function selectDomain() {
    clearSelect();
    $("#domainInfo").removeClass('hidden');
  }

  function selectVariable() {
    clearSelect();
    $("#variableInfo").removeClass('hidden');
  }
  
  function showCi() {
    $("#markdown_panel").removeClass('hidden');
  }

  function hideCi() {
    $("#markdown_panel").addClass('hidden');
  }

  function clearSelect() {
    $("#domainInfo").addClass('hidden');
    $("#variableInfo").addClass('hidden');
    $("#markdown_panel").addClass('hidden');
  }

  /**
   * Functions to display the various panels. 
   */
  function displayDomain(node) {
    domainPrefixElement.value = node.data.prefix;
    domainLabelElement.value = node.data.label;
    //domainNoteElement.value = node.data.note;
    if (editIdentifierFlag) {
      domainPrefixElement.disabled = false;
    } else {
      domainPrefixElement.disabled = true;
    }
  }

  function displayVariable(node) {
    variableLabelElement.value = node.data.label;
    variableCompletionElement.value = node.data.completion;
    variableNoteElement.value = node.data.note;
    //variableRepeatingElement.checked = node.data.repeating;
    //variableOptionalElement.checked = node.data.optional;
  }

  /**
   * Functions to save info.
   */
  function saveDomain(node) {
    if (editIdentifierFlag) {
      node.data.prefix = domainPrefixElement.value;
    }
    node.data.label = domainLabelElement.value;
    //node.data.note = domainNoteElement.value;
    node.name = node.data.label;
  }

  function saveVariable(node) {
    node.data.label = variableLabelElement.value;
    node.data.note = variableNoteElement.value;
    node.name = node.data.name;
    //node.data.repeating = groupRepeatingElement.checked;
    //node.data.optional = groupOptionalElement.checked;
  }

  /*
  * Variable generic functions
  */
  function addVariable() {
    var sourceNode;
    var d3Node;
    var label;
    label = "Group";
    sourceNode = newFormGroup(label)
    d3Node = addD3Node(currentNode, label, C_DOMAIN, sourceNode, true);     
    addSourceNode(currentNode.data, sourceNode, true)
    return d3Node;
  }

  function newVariable(label) {
    return { 
      id: "", namespace: "", type: C_DOMAIN, label: label, ordinal: 0, optional: false, repeating: false, 
      note: "", completion: "", biomedical_concept_reference: {}, children: [] };
  }

  function addSourceNode(parent, node, end) {
    if (end) {
      parent.children.push(node);
    } else {
      parent.children.unshift(node);
    }
    //node.ordinal = parent.children.length;
    for (i=0; i<parent.children.length; i++) {
      temp = parent.children[i];
      temp.ordinal = i + 1;
    }
  }

  /**
   *  Function to draw the tree
   */
  function displayTree(nodeKey) {
    treeNormal(d3Div, rootNode, click, dblClick);
    var gRef = findNode(nodeKey);
    currentGRef = gRef;
    currentNode = gRef.__data__;
    markNode1(currentGRef);    
  }
  
  function notImplementedYet() {
    var html = alertWarning("Function not implemented yet.");
    displayAlerts(html);
  }

  function initData () { 
    // Get the JSON structure. Set the namespace of the thesauri.
    html = $("#domainJson").html();
    domainDefinition = $.parseJSON(html);
    // Rest of data
    markdownElement = null;
    markdownType = "";
    currentNode = null;
    currentGRef = null;
    var managedItem = domainDefinition.managed_item;
    rootNode = d3Root(managedItem.label, managedItem)
    nextKeyId = rootNode.key + 1;
    for (i=0; i<managedItem.children.length; i++) {
      child = managedItem.children[i];
      setD3(child, rootNode);
    }
    var operation = domainDefinition.operation;
    editIdentifierFlag = operation.identifier_edit == true;
  }

  function setRoot() {
    displayTree(1);
    selectDomain();
    displayDomain(currentNode);
  }

  function setParent(node) {
    var i;
    var child;
    if (node.hasOwnProperty('save')) {
      for (i=0; i<node.save.length; i++) {
        child = node.save[i];
        child.parent = node;
        child.index = i;
        setParent(child);
      }
    }
  }

  function setOrdinal(node) {
    var i;
    var child;
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        child.ordinal = i+1;
      }
    }
  }

  function setD3(sourceNode, d3Node) {
    var newNode;
    var i;
    var child;
    if (sourceNode.type === C_DOMAIN ) {
      newNode = addD3Node(d3Node, sourceNode.label, sourceNode.type, sourceNode, true);
      if (sourceNode.hasOwnProperty('children')) {
        for (i=0; i<sourceNode.children.length; i++) {
          child = sourceNode.children[i];
          setD3(child, newNode);
        }
      }
    } else if (sourceNode.type === C_VARIABLE) {
      newNode = addD3Node(d3Node, sourceNode.name, sourceNode.type, sourceNode, true);
    }
  }

  function addD3Node(parent, name, type, data, end) {
    var node = {};
    var temp;
    node.name = name;
    node.type = type;
    node.key = nextKeyId;
    node.parent = parent;
    node.data = data;
    node.expand = false;
    node.children = [];
    node.save = node.children;
    if (!parent.hasOwnProperty('save')) {
      parent.save = [];
      parent.children = [];
    }
    if (end) {
      node.index = parent.save.length;
      parent.save.push(node);
    } else {
      parent.save.unshift(node);
      for (i=0; i<parent.save.length; i++) {
        temp = parent.save[i];
        temp.index = i;
      }
    }
    parent.children = parent.save;
    nextKeyId += 1;
    return node;
  }

  function d3Root(name, data) {
    var node = {};
    node.name = name;
    node.type = C_DOMAIN;
    node.key = 1;
    node.parent = null;
    node.data = data;
    node.expand = false;
    node.index = 0;
    node.children = [];
    node.save = node.children;
    return node;
  }

  function hasChildren(node) {
    var result = true;
    if (node.hasOwnProperty('save')) {
      if (currentNode.save.length == 0) {
        result = false;
      }
    } else {
      result = false;
    }
    return result;
  }

  function deleteNode(node) {
    var parentNode = node.parent
    var sourceParentNode = parentNode.data;
    var sourceNode = node.data;
    var parentIndex = node.index
    parentNode.save.splice(parentIndex, 1);
    sourceParentNode.children.splice(parentIndex, 1);
    if (parentNode.save.length == 0) {
      delete parentNode.children;
      delete parentNode.save;
      sourceParentNode.children = [];
    }
    setParent(parentNode);
    setOrdinal(sourceParentNode);
    return parentNode;
  }

  function moveNodeUp(node) {
    var parentNode = node.parent
    var parentIndex = node.index
    var sourceParentNode = parentNode.data;
    var sourceNode = node.data;
    if (parentIndex != 0 && parentNode.save.length > 1) {
      var tempNode1 = parentNode.save[parentIndex - 1];
      var tempNode2 = parentNode.save[parentIndex];
      parentNode.save[parentIndex - 1] = tempNode2;
      parentNode.save[parentIndex] = tempNode1;
      tempNode1.index = parentIndex;
      tempNode2.index = parentIndex - 1;
      tempNode1 = sourceParentNode.children[parentIndex - 1];
      tempNode2 = sourceParentNode.children[parentIndex];
      sourceParentNode.children[parentIndex - 1] = tempNode2;
      sourceParentNode.children[parentIndex] = tempNode1;
      tempNode1.index = parentIndex;
      tempNode2.index = parentIndex - 1;
      setOrdinal(sourceParentNode);
    }
  }

  function moveNodeDown(node) {
    var parentNode = node.parent
    var parentIndex = node.index
    var sourceParentNode = parentNode.data;
    var sourceNode = node.data;
    if (parentIndex != (parentNode.save.length - 1) && parentNode.save.length > 1) {
      var tempNode1 = parentNode.save[parentIndex + 1];
      var tempNode2 = parentNode.save[parentIndex];
      parentNode.save[parentIndex + 1] = tempNode2;
      parentNode.save[parentIndex] = tempNode1;
      tempNode1.index = parentIndex;
      tempNode2.index = parentIndex + 1;
      tempNode1 = sourceParentNode.children[parentIndex + 1];
      tempNode2 = sourceParentNode.children[parentIndex];
      sourceParentNode.children[parentIndex + 1] = tempNode2;
      sourceParentNode.children[parentIndex] = tempNode1;
      tempNode1.index = parentIndex;
      tempNode2.index = parentIndex + 1;
      setOrdinal(sourceParentNode);
    }
  }

  function displayNode(node) {
    if (node.type ==  C_DOMAIN ) {
      selectDomain();
      displayDomain(node);
    } else if (node.type == C_VARIABLE) {
      selectVariable();
      displayVariable(node);
    } 
  }

});