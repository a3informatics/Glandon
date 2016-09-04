$(document).ready(function() {
  
  var C_DOMAIN = "http://www.assero.co.uk/BusinessDomain#UserDomain";
  var C_VARIABLE = "http://www.assero.co.uk/BusinessDomain#UserVariable";

  var domainDefinition;
  var html;
  var d3Div;

  var domainPrefixElement = document.getElementById("domainPrefix");
  var domainLabelElement = document.getElementById("domainLabel");
  var domainNotesElement = document.getElementById("domainNotes");
  var variableNameElement = document.getElementById("variableName");
  var variableLabelElement = document.getElementById("variableLabel");
  var variableUsedElement = document.getElementById("variableUsed");
  var variableNonStandardElement = document.getElementById("variableNonStandard");
  var variableFormatElement = document.getElementById("variableFormat");
  var variableNotesElement = document.getElementById("variableNotes");
  var variableCommentElement = document.getElementById("variableComment");
  var variableDatatypeElement = document.getElementById("variableDatatype");
  var variableComplianceElement = document.getElementById("variableCompliance");
  var variableClassificationElement = document.getElementById("variableClassification");
  var genericMarkdownElement = document.getElementById("genericMarkdown");

  var nextKeyId;
  var currentNode;
  var currentGRef;
  var rootNode;
  var editIdentifierFlag;               
  var markdownElement;
  var markdownType;
  var domainPrefix;

  // Set up the form validation
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
        "Domain Prefix": {required: true, domainPrefix: true },
        "Domain Label": {required: true, label: true },
        "Domain Note": {required: false, markdown: true},
        "Variable Name": {required: true, variableName: true },
        "Variable Label": {required: true, label: true },
        "Variable Format": {required: true, label: true },
        "Variable Note": {required: false, markdown: true},
        "Variable Comment": {required: false, markdown: true}
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
      if (currentNode.type == C_DOMAIN) {
        saveDomain(currentNode)
      } else if (currentNode.type == C_VARIABLE) {
        saveVariable(currentNode)
      }
      clearNode(currentNode, currentGRef);
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
      data: JSON.stringify(data),
      dataType: 'json',
      contentType: 'application/json',
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

  $('#domainAddVariable').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select the domain node.");
      displayAlerts(html);
    } else {
      var node = addVariable();
      displayNode(node);
      displayTree(node.key);  
    }
  });

  /*
  * Functions to handle the group actions
  */
  $('#variableUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a variable node.");
      displayAlerts(html);
    } else {
      $('#main_form').valid();
      saveVariable(currentNode)
      displayTree(currentNode.key);
    }
  });

  $('#variableDelete').click(function() {
    var node = deleteNode(currentNode);
    displayNode(node);
    displayTree(node.key);
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

  $( "#variableComment" ).focus(function() {
    hideBCSelection();
    showCi();
    markdownType = C_VARIABLE;
    markdownElement = variableCommentElement;
    var text = markdownElement.value;
    getMarkdown(genericMarkdownElement, text);
  });

  $( "#variableNotes" ).focus(function() {
    hideBCSelection();
    showCi();
    markdownType = C_VARIABLE;
    markdownElement = variableNotesElement;
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
    domainNotesElement.value = node.data.notes;
    if (editIdentifierFlag) {
      domainPrefixElement.disabled = false;
    } else {
      domainPrefixElement.disabled = true;
    }
  }

  function displayVariable(node) {
    variableNameElement.value = node.data.name;
    variableLabelElement.value = node.data.label;
    variableUsedElement.checked = node.data.used;
    variableNonStandardElement.checked = node.data.non_standard;
    variableFormatElement.value = node.data.format;
    variableNotesElement.value = node.data.notes;
    variableCommentElement.value = node.data.comment;
    variableDatatype.value = toUri(node.data.datatype.namespace, node.data.datatype.id);
    variableCompliance.value = toUri(node.data.compliance.namespace, node.data.compliance.id);
    variableClassification.value = toUri(node.data.classification.namespace, node.data.classification.id);
    variableNonStandardElement.disabled = true;
  }

  /**
   * Functions to save info.
   */
  function saveDomain(node) {
    if (editIdentifierFlag) {
      node.data.prefix = domainPrefixElement.value;
    }
    node.data.label = domainLabelElement.value;
    node.data.notes = domainNotesElement.value;
    node.name = node.data.label;
  }

  function saveVariable(node) {
    node.data.name = variableNameElement.value;
    node.data.label = variableLabelElement.value;
    node.data.used = variableUsedElement.checked;
    node.data.non_standard = variableNonStandardElement.checked;
    node.data.format = variableFormatElement.value;
    node.data.notes = variableNotesElement.value;
    node.data.comment = variableCommentElement.value;
    node.data.datatype.namespace = getNamespace(variableDatatypeElement.value);
    node.data.datatype.id = getId(variableDatatypeElement.value);
    node.data.compliance.namespace = getNamespace(variableComplianceElement.value);
    node.data.compliance.id = getId(variableComplianceElement.value);
    node.data.classification.namespace = getNamespace(variableClassificationElement.value);
    node.data.classification.id = getId(variableClassificationElement.value);
    node.name = node.data.name;
    node.enabled = node.data.used;
  }

  /*
  * Variable generic functions
  */
  function addVariable() {
    var sourceNode;
    var d3Node;
    var label;
    label = "Non Standard";
    sourceNode = newVariable(label)
    d3Node = addD3Node(currentNode, sourceNode.name, C_VARIABLE, sourceNode, true);     
    addSourceNode(currentNode.data, sourceNode, true)
    return d3Node;
  }

  function newVariable(label) {
    return {
        type: C_VARIABLE,
        id: "",
        namespace: "",
        label: label,
        ordinal: "",
        name: "--XXXXXX",
        notes: "",
        format: "",
        non_standard: true,
        comment: "",
        length: 0,
        used: true,
        key_ordinal: 0,
        datatype: { type: "", id: "", namespace: "", label: ""},
        compliance: { type: "", id: "", namespace: "", label: ""},
        classification: { type: "", id: "", namespace: "", label: ""},
        variable_ref: {} };
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
    domainPrefix = managedItem.prefix
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
    node.enabled = data.used;
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