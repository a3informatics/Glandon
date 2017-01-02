var domainDefinition;
var rootNode;
var markdownElement;
var markdownType;
var newCount;
var previousSave;

$(document).ready(function() {
  
  // Set up the form validation
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
        "Domain Prefix": {required: true, domainPrefix: true },
        "Domain Label": {required: true, label: true },
        "Domain Note": {required: false, markdown: true},
        "Variable Name": {required: true, variableName: true },
        "Variable Label": {required: true, variableLabel: true },
        "Variable Format": {required: true, label: true },
        "Variable Note": {required: false, markdown: true},
        "Variable Comment": {required: false, markdown: true}
    },
    submitHandler: function(form) {
      saveNode();
      saveRest();
      return false;
    },
    invalidHandler: function(event, validator) {
      displayWarning("The form is not valid. Please correct the errors.");
    }
  });

  // Init any data
  initData();
  displayNode(rootNode);

  /*
  * General Panel Actions
  */
  $('#close').click(function() {
    saveNode();
    saveRest();
    window.location.href = $('#close_path').val();
  });

  /*
  * Functions for testing. 
  */
  $('#click_node_name').click(function() {
    var nodeName = $('#click_node_name_text').val();
    var node = d3FindGRefByName(nodeName);
    if (node !== null) {
      simulateClick(node);
    }
  });

  $('#click_node_key').click(function() {
    var nodeKey = parseInt($('#click_node_key_text').val());
    var node = d3FindGRef(nodeKey);
    if (node !== null) {
      simulateClick(node);
    }
  });

  $('#clear_current_node').click(function() {
    currentGRef = null;
    currentNode = null;
  });

  /*
   * Functions to handle the form actions.
   */
  $('#domainUpdate').click(function() {
    if (currentGRef == null) {
      displayWarning("You need to select the domain node.");
    } else {
      $('#main_form').valid();
      saveDomain(currentNode);
      displayNode(currentNode);
    }
  });

  $('#domainAddVariable').click(function() {
    if (currentGRef == null) {
      displayWarning("You need to select the domain node.");
    } else {
      var node = addVariable();
      displayNode(node);
      displayNode(node);  
    }
  });

  /*
  * Functions to handle the group actions
  */
  $('#variableUpdate').click(function() {
    if (currentGRef == null) {
      displayWarning("You need to select a variable node.");
          } else {
      $('#main_form').valid();
      saveVariable(currentNode)
      displayNode(currentNode);
    }
  });

  $('#variableDelete').click(function() {
    var node = d3eDeleteNode(currentNode);
    displayNode(node);
    displayNode(node);
  });

  $('#variableUp').click(function() {
    if (currentNode == null) {
      displayWarning("You need to select a group node.");
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index != 0) {
        d3eMoveNodeUp(currentNode);
        displayNode(currentNode);
      } else {
        displayWarning("You cannot move the node up.");
      }
    }
  }); 

  $('#variableDown').click(function() {
    if (currentNode == null) {
      displayWarning("You need to select a group node.");
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index < parentNode.save.length) {
        de3MoveNodeDown(currentNode);
        displayNode(currentNode);
      } else {
        displayWarning("You cannot move the node down.");
      }
    }
  }); 

  /*
  * Functions to handle completion instruction preview
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      displayWarning("You need to select a completion instruction field.");
    } else {
      var text = markdownElement.value;
      getMarkdown(document.getElementById("genericCompletion"), text, markdownCallback);      }
  });

  $('#markdown_hide').click(function() {
    hideCi();
    if (markdownType == C_USERDOMAIN) {
      //showBCSelection();
    } else if (markdownType == C_QUESTION) {
      //showNotepad();    
    }
    markdownElement = null;
    markdownType = "";
  });

  /*
  * Completion and notes focus functions
  */
  $( "#domainNotes" ).focus(function() {
    showCi();
    handleFocus(C_USERDOMAIN, this);
  });

  $( "#variableComment" ).focus(function() {
    showCi();
    handleFocus(C_USERVARIABLE, this);
  });

  $( "#variableNotes" ).focus(function() {
    showCi();
    handleFocus(C_USERVARIABLE, this);
  });

});

/* 
* Function to handle the form save click.
*/
function saveRest() {
  var uri;
  var method;
  var data;
  var currentSave = JSON.stringify(domainDefinition);
  if (currentSave !== previousSave) {
    addSpinner();
    method = 'PUT';
    domain = domainDefinition.managed_item;
    url = "/sdtm_user_domains/" + domain['id'];
    data = { "sdtm_user_domain": { "namespace": domain['namespace'] }, "data": domainDefinition };  
    $.ajax({
      url: url,
      type: method,
      data: JSON.stringify(data),
      dataType: 'json',
      contentType: 'application/json',
      success: function(result){
        removeSpinner();
      },
      error: function(xhr, status, error){
        handleAjaxError (xhr, status, error);
        removeSpinner();
      }
    });
    previousSave = currentSave; 
  }
}

function handleFocus(type, element) {
  showCi();
  markdownType = type;
  markdownElement = element;
  element.innerHTML = "";
  getMarkdown(element, element.value, markdownCallback);
}

function markdownCallback(element, text) {
  element.innerHTML = text;
}


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
  
function removeSpinner() {
  $("#saving > span").removeClass('glyphicon-spin');
}

function addSpinner() {
  $("#saving > span").addClass('glyphicon-spin');
}

// Function for page unload. Nothing to do
function pageUnloadAction() {
  saveNode();
  saveRest();
}

/**
 * Functions to display the various panels. 
 */
function displayDomain(node) {
  $("#domainPrefix").val(node.data.prefix);
  $("#domainLabel").val(node.data.label);
  $("#domainNotes").val(node.data.notes);
  $("#domainPrefix").prop( "disabled", true );
}

function displayVariable(node) {
  $("#variableName").val(node.data.name);
  $("#variableLabel").val(node.data.label);
  $("#variableUsed").prop('checked', node.data.used);
  $("#variableNonStandard").prop('checked', node.data.non_standard);
  $("#variableFormat").val(node.data.format);
  $("#variableNotes").val(node.data.notes);
  $("#variableComment").val(node.data.comment);
  $("#variableDatatype").val(toUri(node.data.datatype.namespace, node.data.datatype.id));
  $("#variableCompliance").val(toUri(node.data.compliance.namespace, node.data.compliance.id));
  $("#variableClassification").val(toUri(node.data.classification.namespace, node.data.classification.id));
  $("#variableNonStandard").prop('disabled', true);
  if (node.data.non_standard) {
    $("#variableDelete").prop('disabled', false);
    $("#variableUp").prop('disabled', false);
    $("#variableDown").prop('disabled', false);
  } else {
    $("#variableDelete").prop('disabled', true);
    $("#variableUp").prop('disabled', true);
    $("#variableDown").prop('disabled', true);
  }
}

/**
 * Functions to save info.
 */
function saveDomain(node) {
  node.data.label = $("#domainLabel").val();
  node.data.notes = $("#domainNotes").val();
  node.name = node.data.label;
}

function saveVariable(node) {
  node.data.name = $("#variableName").val();
  node.data.label = $("#variableLabel").val();
  node.data.used = $("#variableUsed").is(":checked");
  node.data.non_standard = $("#variableNonStandard").is(":checked");
  node.data.format = $("#variableFormat").val();
  node.data.notes = $("#variableNotes").val();
  node.data.comment = $("#variableComment").val();
  node.data.datatype.namespace = getNamespace($("#variableDatatype").val());
  node.data.datatype.id = getId($("#variableDatatype").val());
  node.data.compliance.namespace = getNamespace($("#variableCompliance").val());
  node.data.compliance.id = getId($("#variableCompliance").val());
  node.data.classification.namespace = getNamespace($("#variableClassification").val());
  node.data.classification.id = getId($("#variableClassification").val());
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
  d3Node = d3eAddNode(currentNode, sourceNode.name, C_USERVARIABLE, true, sourceNode, true);     
  d3eAddData(currentNode, d3Node.data, true)
  return d3Node;
}

function newVariable(label) {
  return {
      type: C_USERVARIABLE,
      id: "",
      namespace: "",
      label: label,
      ordinal: "",
      name: domainPrefix + pad(newCount, 6, '0'),
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
      newCount += 1;
}

function initData () { 
  html = $("#domainJson").html();
  domainDefinition = $.parseJSON(html);
  markdownElement = null;
  markdownType = "";
  var managedItem = domainDefinition.managed_item;
  previousSave = currentSave = JSON.stringify(domainDefinition);
  domainPrefix = managedItem.prefix
  d3eInit(saveNode, displayNode, empty);
  rootNode = d3eRoot(managedItem.label, C_USERDOMAIN, managedItem)
  nextKeyId = rootNode.key + 1;
  for (i=0; i<managedItem.children.length; i++) {
    child = managedItem.children[i];
    setD3(child, rootNode);
  }
  newCount = managedItem.children.length + 1;
}

function empty(node) {
}

function setD3(sourceNode, d3Node) {
  var newNode;
  var i;
  var child;
  if (sourceNode.type === C_USERDOMAIN ) {
    newNode = d3eAddNode(d3Node, sourceNode.label, sourceNode.type, true, sourceNode, true);
    if (sourceNode.hasOwnProperty('children')) {
      for (i=0; i<sourceNode.children.length; i++) {
        child = sourceNode.children[i];
        setD3(child, newNode);
      }
    }
  } else if (sourceNode.type === C_USERVARIABLE) {
    newNode = d3eAddNode(d3Node, sourceNode.name, sourceNode.type, true, sourceNode, true);
  }
}

function saveNode() {
  if ($('#main_form').valid()) {
    var d3Node = d3eGetCurrent();
    if (currentNode.type == C_USERDOMAIN) {
      saveDomain(currentNode)
    } else if (currentNode.type == C_USERVARIABLE) {
      saveVariable(currentNode)
    }
    saveRest();
  } 
}

function displayNode(node) {
  d3eDisplayTree(node.key);
  if (node.type ==  C_USERDOMAIN ) {
    selectDomain();
    displayDomain(node);
  } else if (node.type == C_USERVARIABLE) {
    selectVariable();
    displayVariable(node);
  } 
}