var domainDefinition;
var domainDefaults;
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
      if (checkLastNode(true)) {
        saveNode();
        //saveRest();
      }
      return false;
    },
    invalidHandler: function(event, validator) {
      displayWarning("The form is not valid. Please correct the errors.");
    }
  });

  // Init any data
  initData();
  displayNode(rootNode);

  // Set window resize.
  window.addEventListener("resize", d3eReDisplay);

  // Start timeout timer
  ttAddToken("1");

  /*
  * General Panel Actions
  */
  $('#close').click(function() {
    if (checkLastNode(false)) {
      saveNode();
      //saveRest();
    }
    window.location.href = $('#close_path').val();
  });

  /*
   * Functions to handle the domain actions.
   */
  $('#domainAddVariable').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select the domain node.");
    } else {
      var node = addVariable();
      displayNode(node);
      displayNode(node);  
    }
  });

  /*
  * Functions to handle the variable actions
  */
  $('#variableUpdate').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select a variable node.");
    } else {
      $('#main_form').valid();
      saveVariable(currentNode)
      displayNode(currentNode);
    }
  });

  $('#variableDelete').click(function() {
    var currentNode = d3eGetCurrent();
    var node = d3eDeleteNode(currentNode);
    displayNode(node);
    displayNode(node);
  });

  $('#variableUp').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select a group node.");
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index != 0) {
        if (parentNode.save[currentNode.index - 1].data.non_standard) {
          d3eMoveNodeUp(currentNode);
          displayNode(currentNode);
        } else {
          displayWarning("You cannot move the node up past a standard variable.");
        }
      } else {
        displayWarning("You cannot move the node up.");
      }
    }
  }); 

  $('#variableDown').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select a group node.");
    } else {
      var parentNode = currentNode.parent;
      if (currentNode.index < (parentNode.save.length - 1)) {
        d3eMoveNodeDown(currentNode);
        displayNode(currentNode);
      } else {
        displayWarning("You cannot move the node down.");
      }
    }
  }); 

  $("#variableClassification").change(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select a group node.");
    } else {
      var namespace = getNamespace($("#variableClassification").val());
      var id = getId($("#variableClassification").val());
      subClassificationRest(id, namespace);
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
      getMarkdown(document.getElementById("genericMarkdown"), text, markdownCallback);      }
  });

  $('#markdown_hide').click(function() {
    hideCi();
    //if (markdownType == C_USERDOMAIN) {
    //} else if (markdownType == C_QUESTION) {
    //}
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
    spAddSpinner("#saving");
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
        spRemoveSpinner("#saving");
        ttSave("1");
      },
      error: function(xhr, status, error){
        handleAjaxError (xhr, status, error);
        spRemoveSpinner("#saving");
      }
    });
    previousSave = currentSave; 
  } else {
    ttExtendLock("1"); // Nothing to save, extend the edit lock timer.
  }
}

function subClassificationRest(id, namespace) {
  var url = '/sdtm_user_domains/sub_classifications?sdtm_user_domain[classification_id]=' + id + 
    '&sdtm_user_domain[classification_namespace]=' + namespace;
  $("#variableSubClassification").empty();
  $.ajax({
    url: url,
    type: "GET",
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred loading a sub-classification.");
    },
    success: function(result){
      $('#variableSubClassification').empty();
      for(var i=0; i<result.length; i++) {
        var entry = result[i];
        var option = new Option(entry.value, entry.key);
        $('#variableSubClassification').append($(option));
      }
    }
  });
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

// Function for page unload.
function pageUnloadAction() {
  if (checkLastNode(false)) {
    saveNode();
    //saveRest();
  }
}

/**
 * Functions to display the various panels. 
 */
function displayDomain(node) {
  $("#domainPrefix").val(node.data.prefix);
  $("#domainLabel").val(node.data.label);
  $("#domainNotes").val(node.data.notes);
  $("#domainPrefix").prop( "disabled", true);
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
  if (jQuery.isEmptyObject(node.data.sub_classification)) {
    // Hide select
  } else {
    $("#variableSubClassification").val(toUri(node.data.sub_classification.namespace, node.data.sub_classification.id));
  }
  subClassificationRest(node.data.classification.id, node.data.classification.namespace);
  if (node.data.non_standard) {
    $("#variableNonStandard").prop('disabled', true);
    $("#variableDelete").prop('disabled', false);
    $("#variableUp").prop('disabled', false);
    $("#variableDown").prop('disabled', false);
    $("#variableName").prop( "disabled", false);
    $("#variableLabel").prop( "disabled", false);
    $("#variableDatatype").prop( "disabled", false);
    $("#variableCompliance").prop( "disabled", false);
    $("#variableClassification").prop( "disabled", false);
    $("#variableSubClassification").prop( "disabled", false);
  } else {
    $("#variableNonStandard").prop('disabled', true);
    $("#variableDelete").prop('disabled', true);
    $("#variableUp").prop('disabled', true);
    $("#variableDown").prop('disabled', true);
    $("#variableName").prop( "disabled", true);
    $("#variableLabel").prop( "disabled", true);
    $("#variableDatatype").prop( "disabled", true);
    $("#variableCompliance").prop( "disabled", true);
    $("#variableClassification").prop( "disabled", true);
    $("#variableSubClassification").prop( "disabled", true);
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
  if (getId($("#variableSubClassification").val()) !== "") {
    node.data.sub_classification.namespace = getNamespace($("#variableSubClassification").val());
    node.data.sub_classification.id = getId($("#variableSubClassification").val());
  } else {
    node.data.sub_classification = {};
  }
  node.name = node.data.name;
  node.enabled = node.data.used;
}

/*
* Variable generic functions
*/
function addVariable() {
  var label = "Non Standard";
  var currentNode = d3eGetCurrent();
  var sourceNode = newVariable(label)
  var d3Node = d3eAddNode(currentNode, sourceNode.name, C_USERVARIABLE, true, sourceNode, true);     
  d3eAddData(currentNode, d3Node.data, true)
  return d3Node;
}

function newVariable(label) {
  result = 
  {
    type: C_USERVARIABLE,
    id: "",
    namespace: "",
    label: label,
    ordinal: "",
    name: domainPrefix + pad(newCount, 6, '0'),
    notes: "",
    ct: "",
    format: "",
    non_standard: true,
    comment: "",
    length: 0,
    used: true,
    key_ordinal: 0,
    datatype: domainDefaults.datatype,
    compliance: domainDefaults.compliance,
    classification: domainDefaults.classification,
    sub_classification: {},
    variable_ref: {} 
  };
  newCount += 1;
  return result;
}

function initData () { 
  var html1 = $("#domainJson").html();
  domainDefinition = $.parseJSON(html1);
  var html2 = $("#defaultsJson").html();
  domainDefaults = $.parseJSON(html2);
  markdownElement = null;
  markdownType = "";
  var managedItem = domainDefinition.managed_item;
  previousSave = currentSave = JSON.stringify(domainDefinition);
  domainPrefix = managedItem.prefix
  d3eInit("d3", saveNode, displayNode, empty, validateNode);
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

function validateNode(node) {
  clearVariableNameError();
  var validForm = $('#main_form').valid();
  var validName = validateNonStandardVariableName(node);
  if (!validName) {
    showVariableNameError();
  }
  return validName && validForm;
}

function checkLastNode(alertUser) {
  var validName = true;
  var node = d3eGetCurrent();
  if (node !== null) {
    validName = validateNonStandardVariableName(node);
    if (alertUser && !validName) {
      clearVariableNameError();
      showVariableNameError();
    }
  }
  return validName;
}

function clearVariableNameError () {
  unhighlight($('#variableName'));
  removeErrorText($('#variableName'));  
}

function showVariableNameError () {
  highlight($('#variableName'))
  var text = "<span class=\"help-block\">The variable name is not valid. Check the prefix, valid characters and length.</span>";
  addErrorText($(text), $('#variableName'));
}

function validateNonStandardVariableName(node) {
  var result = true;
  if (node.type === C_USERVARIABLE) {
    if (node.data.non_standard) {
      var name = $("#variableName").val();
      if (name.length > 2) {
        var prefix = name.substring(0,2);
        if (prefix === domainDefinition.managed_item.prefix) {
          for (var i=0; i<rootNode.save.length; i++) {
            if (node.index === i) {
              // Do nothing, our own node
            } else if (rootNode.save[i].data.name === name) {
              result = false;
              break;
            }
          }
        } else {
          result = false;
        }
      } else {
        result = false;
      }
    }
  }
  return result;
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
    var currentNode = d3eGetCurrent();
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