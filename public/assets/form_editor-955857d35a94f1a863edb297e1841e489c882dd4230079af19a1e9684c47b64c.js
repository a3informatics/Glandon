var formDefinition ;
var rootNode;
var bcCurrent;
var bcCurrentRow;
//var notepadTableReload;
//var norepadTable;
//var notepadData;
//var notepadRow;
//var varClCurrent;
//var varClCurrentRow;
var markdownElement;
var markdownType;
var previousSave;
var bcSelect;
var idKeyMap;
var datatypeMap;
var feInitializeTimeoutCount;

$(document).ready(function() {

  $("#saving").prop("disabled", true);
  
  // Set up the form validation
  validatorDefaults ();
  $('#main_form').validate({
    rules: {
        "Form Identifier": {required: true, identifier: true },
        "Form Label": {required: true, label: true },
        "Form Note": {required: false, markdown: true},
        "Form Completion": {required: false, markdown: true},
        "Group Label": {required: true, label: true },
        "Group Note": {required: false, markdown: true},
        "Group Completion": {required: false, markdown: true},
        "BC Note": {required: false, markdown: true},
        "BC Completion": {required: false, markdown: true},
        "BC Item Note": {required: false, markdown: true},
        "BC Item Completion": {required: false, markdown: true},
        "Question Label": {required: true, label: true },
        "Question Text": {required: true, question: true },
        "Question Note": {required: false, markdown: true},
        "Question Completion": {required: false, markdown: true},
        "Placeholder Text": {required: false, markdown: true},
        "Label Text Label": {required: true, label: true},
        "Label Text Text": {required: false, markdown: true},
        "Code List Label": {required: true, label: true },
        "Common Label": {required: true, label: true },
        "Mapping": {required: true, mapping: true }        
    },
    submitHandler: function(form) {
      saveNode();
      //saveRest();
      return false;
    },
    invalidHandler: function(event, validator) {
      displayWarning("The form is not valid. Please correct the errors.");
    }
  });

  /*questionClTable = $('#questionClTable').DataTable({
    "searching": false,
    "pageLength": 5,
    "lengthChange": false,
    "columns": [
      {"data" : "data.subject_data.identifier", "width" : "50%"},
      {"data" : "data.subject_data.notation", "width" : "50%"},
    ]
  });
  questionClTable.clear();*/

  bcSelect = $('#bcTable').DataTable( {
    "ajax": {
      "url": "/biomedical_concepts/list",
      "dataSrc": "data",
      error: function (xhr, status, error) {
        displayError("An error has occurred loading the Biomedical Concepts table.");
      }
    },
    dataType: 'json',
    "pageLength": 5,
    "lengthMenu": [[5, 10, 15, 20, 25], [5, 10, 15, 20, 25]],
      "pagingType": "full",
    "bProcessing": true,
    "language": {
      "infoFiltered": "",
      "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
    },
    "columns": [
      {"data" : "scoped_identifier.identifier", "width" : "50%"},
      {"data" : "label", "width" : "50%"}
    ]
  });

  /*function initialNotepadLoad () {
    notepadTable = $('#notepad_table').DataTable( {
      "ajax": {
        "url": "/notepads/index_term",
        "dataSrc": "data"  
      },
      "bProcessing": true,
      "pagingType": "full",
      "pageLength": 5,
      "lengthMenu": [[5, 10, 15, 20, 25], [5, 10, 15, 20, 25]],
      "language": {
        "infoFiltered": "",
        "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
      },
      "columns": [
        {"data" : "identifier", "width" : "30%"},
        {"data" : "useful_1", "width" : "70%"}
      ]
    });
    notepadTableReload = true;    
  }*/

  // Initialize everything.
  initData();
  //initialNotepadLoad();
  displayNode(rootNode);
  
  // Set window resize.
  window.addEventListener("resize", d3eReDisplay);

  // Start timeout timer
  ttAddToken("1");

  /* 
   * Notepad functions
   */
  /*$('#notepad_refresh').click(function() {
    if (!notepadTableReload) {
      initialNotepadLoad();
    } else {
      notepadTable.ajax.reload(function ( json ) {
        tsUpdate(notepadTable.data().count());
      });
    }
  });

  $('#notepad_add').click(function() {
    var data;
    var text;
    if (notepadRow !== null) {
      data = notepadTable.row(notepadRow).data();
      var currentD3Node = d3eGetCurrent();
      var tcRefSNode = newQuestionCli(data);
      var tcRefD3Node = d3eAddNode(currentD3Node, tcRefSNode.local_label, tcRefSNode.type, true, tcRefSNode, true);
      d3eAddData(currentD3Node, tcRefD3Node.data, true);
      questionClTable.row.add(tcRefD3Node);
      questionClTable.draw(false);
      displayNode(currentD3Node);
    } else {
      displayWarning("You need to select a notepad item.");
    }
  });

  $('#notepad_table tbody').on('click', 'tr', function () {
    var row = notepadTable.row(this).index();
    var data = notepadTable.row(row).data();
    if (notepadRow !== null) {
      $(notepadRow).toggleClass('success');
    }
    $(this).toggleClass('success')
    notepadData = data;
    notepadRow = this
  });*/

  /*
  * General Panel Actions
  */
  $('#close').click(function() {
    saveNode();
    //saveRest();
    window.location.href = $('#close_path').val();
  });

  /*
  * Button class actions
  */
  $('.node-up-action').click(function() {
    treeNodeUp();
  }); 

  $('.node-down-action').click(function() {
    treeNodeDown();
  });

  $('.node-delete-action').click(function() {
    treeNodeDelete(false);
  });

  $( ".markdown-area" ).focus(function() {
    handleFocus("OTHER", this);
  });

  /*
  * Form Panel Actions
  */
  $('#formAddGroup').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select the form node.");
    } else {
      saveForm(currentNode);
      var node = addGroup(currentNode);
      displayNode(node);
    }
  });

  /*
  * Group Panel Actions
  */
  $('#groupAddGroup').click(function() {
    treeNodeAdd(addGroup);
  });

  $('#groupDelete').click(function() {
    treeNodeDelete(true);
  });

  $('#groupAddCommon').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select a node.");
    } else if (hasCommonGroup(d3eGetCurrent())) {
      displayWarning("Group already has a common node.");
    } else {
      var node = addCommonGroup(d3eGetCurrent());
      displayNode(node);
    }
  }); 

  $('#groupAddBc').click(function() {
    var currentNode = d3eGetCurrent()
    if (currentNode === null) {
      displayWarning("You need to select a node.");
    } else if (bcCurrent === null) {
      displayWarning("You need to select a Biomedical Concept.");
    } else {
      addBc(currentNode);
    }
  }); 

  $('#groupAddQuestion').click(function() {
    treeNodeAdd(addQuestion);
  }); 

  $('#groupAddMapping').click(function() {
    treeNodeAdd(addMapping);
  }); 

  $('#groupAddPlaceholder').click(function() {
    treeNodeAdd(addPlaceholder);
  }); 

  $('#groupAddLabelText').click(function() {
    treeNodeAdd(addLabelText);
  }); 

  /*
  * Common Panel Actions
  */
  $('#commonDelete').click(function() {
    treeNodeDelete(true);
  });

  /*
  * BC Panel Actions
  */
  $('#bcDelete').click(function() {
    var currentD3Node = d3eGetCurrent();
    deleteCommon(currentD3Node);
    treeNodeDelete(false);
  });

  /*
  * Item Panel Actions
  */
  $('#itemCommon').click(function() {
    var currentNode = d3eGetCurrent();
    if (currentNode === null) {
      displayWarning("You need to select an item node.");
    } else {
      var node = makeCommon(currentNode);
      displayNode(node);
    }
  }); 

  $('#itemRestore').click(function() {
    var currentNode = d3eGetCurrent()
    if (currentNode === null) {
      displayWarning("You need to select an item node.");
    } else {
      restoreCommon(currentNode);
      treeNodeDelete(false);
    }
  }); 

  /*
  * Code List Panel Actions
  */
  $('#clDefault').click(function() {
    var d3CurrentNode = d3eGetCurrent();
    if (d3CurrentNode === null) {
      displayWarning("You need to select a code list node.");
    } else {
      $('#clLocalLabel').val(d3CurrentNode.data.subject_data.label);
    }
  });
  
  /*
   * Function to handle click on the BC selection table.
   */
  $('#bcTable tbody').on('click', 'tr', function () {
    if (bcCurrent != null) {
      $(bcCurrent).toggleClass('success');
    }
    $(this).toggleClass('success');
    var row = bcSelect.row(this).index();
    bcCurrent = this;
    bcCurrentRow = row;
  });

  /*
   * Function to handle click on Question CL table
   */
  /*$('#questionClTable tbody').on('click', 'tr', function () {
    if (varClCurrent != null) {
      $(varClCurrent).toggleClass('success');
    }
    $(this).toggleClass('success');
    var row = questionClTable.row(this).index();
    varClCurrent = this;
    varClCurrentRow = row;
  });*/

  /* 
  * Function to handle the terminology button clicks.
  */
  /*$('#deleteTerm').click(function() {
    var data;
    if (varClCurrentRow == null) {
      displayWarning("You need to select a code list item.");
    } else {
      var clData = questionClTable.row(varClCurrentRow).data();
      var node = d3FindData(clData.key);
      if (node !== null) {
        var parent = node.parent; 
        d3eDeleteNode(node);
        questionClTable.row(varClCurrentRow).remove();
        varClCurrentRow = null;
        questionClTable.draw();
        displayNode(parent);
      } else {
        displayError("Cannot delete terminology item, could not find node.");
      }
    }
  });*/

  $('#questionDatatype input:radio').click(function() {
    var value = $(this).val();
    clEnableDisable(value, false);
    clFormat(value, false);
  });

  /*
  * Functions to handle completion instructions
  */
  $('#markdown_preview').click(function() {
    if (markdownElement == null) {
      displayWarning("You need to select a completion instruction field.");
    } else {
      var text = markdownElement.value;
      getMarkdown(document.getElementById("genericCompletion"), text, markdownCallback);  
    }
  });

  $('#markdown_hide').click(function() {
    hideCi();
    if (markdownType == C_NORMAL_GROUP) {
      showBCSelection();
    } else if (markdownType == C_QUESTION) {
      //
    }
    markdownElement = null;
    markdownType = "";
  });

  $( "#groupCompletion" ).focus(function() {
    hideBCSelection();
    handleFocus(C_NORMAL_GROUP, this);
  });

  $( "#groupNote" ).focus(function() {
    hideBCSelection();
    handleFocus(C_NORMAL_GROUP, this);
  });

  $( "#questionCompletion" ).focus(function() {
    //tfeDisable();
    handleFocus(C_QUESTION, this);
  });

  $( "#questionNote" ).focus(function() {
    //tfeDisable();
    handleFocus(C_QUESTION, this);
  });

});

/*
* Utilty Functions
* ================
*/

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

/*
*
*/

function clEnableDisable (value, coded) {
  if (coded) {
    var currentNode = d3eGetCurrent();
    $("#questionFormat").prop('disabled', true);
    //$("#notepad_add").prop('disabled', false);
    //$("#deleteTerm").prop('disabled', false);
    tfeEnable(currentNode.data.label, currentNode);
  } else if (value === datatypeMap['string']['xsd_fragment']) {
    var currentNode = d3eGetCurrent();
    $("#questionFormat").prop('disabled', false);
    //$("#notepad_add").prop('disabled', false);
    //$("#deleteTerm").prop('disabled', false);
    tfeEnable(currentNode.data.label, currentNode);
  } else if (value === datatypeMap['integer']['xsd_fragment'] || value === datatypeMap['float']['xsd_fragment']) {
    $("#questionFormat").prop('disabled', false);
    //$("#notepad_add").prop('disabled', true);
    //$("#deleteTerm").prop('disabled', true);
    tfeDisable();    
  } else {
    $("#questionFormat").prop('disabled', true);
    //$("#notepad_add").prop('disabled', true);
    //$("#deleteTerm").prop('disabled', true);
    tfeDisable();
  }
}

function clFormat (value, coded) {
  if (coded) {
    $('#questionFormat').val("")
  } else if (value === datatypeMap['integer']['xsd_fragment']) {
    $('#questionFormat').val("3")
  } else if (value === datatypeMap['string']['xsd_fragment']) {
    $('#questionFormat').val("20")
  } else if (value === datatypeMap['float']['xsd_fragment']) {
    $('#questionFormat').val("6.2")
  } else {
    $('#questionFormat').val("")
  }
}

function selectForm() {
  clearSelect();
  $("#formInfo").removeClass('hidden');
}

function selectGroup() {
  clearSelect();
  $("#groupInfo").removeClass('hidden');
  $("#bcSelection").removeClass('hidden');
}

function selectBC() {
  clearSelect();
  $("#bcInfo").removeClass('hidden');
}

function showBCSelection() {
  $("#bcSelection").removeClass('hidden');
}

function hideBCSelection() {
  $("#bcSelection").addClass('hidden');
}

function selectCommon() {
  clearSelect();
  $("#commonInfo").removeClass('hidden');
}

function selectBcQuestion() {
  clearSelect();
  $("#bcItemInfo").removeClass('hidden');
}

function selectCommonItem() {
  clearSelect();
  $("#commonItemInfo").removeClass('hidden');
}

function selectQuestion() {
  clearSelect();
  $("#questionInfo").removeClass('hidden');
  //$("#notepad_panel").removeClass('hidden');
}

function selectMapping() {
  clearSelect();
  $("#mappingInfo").removeClass('hidden');
}

function selectPlaceholder() {
  clearSelect();
  $("#placeholderInfo").removeClass('hidden');
  $("#markdown_panel").removeClass('hidden');
}

function selectLabelText() {
  clearSelect();
  $("#labelTextInfo").removeClass('hidden');
  $("#markdown_panel").removeClass('hidden');
}

function selectCl() {
  clearSelect();
  $("#clInfo").removeClass('hidden');
}

//function showNotepad() {
  //$("#notepad_panel").removeClass('hidden');  
//}

//function hideNotepad() {
  //$("#notepad_panel").addClass('hidden');
//}

function showCi() {
  $("#markdown_panel").removeClass('hidden');
}

function hideCi() {
  $("#markdown_panel").addClass('hidden');
}

function clearSelect() {
  $('.panel-form').addClass('hidden');
  tfeDisable();
  $("#general_panel").removeClass('hidden');
}

// Function for page unload. Nothing to do
function pageUnloadAction() {
  saveNode();
  //saveRest();
}

function saveRest() {
  var uri;
  var method;
  var data;
  var action;
  var form;
  var currentSave = JSON.stringify(formDefinition);
  if (currentSave !== previousSave) {
    spAddSpinner("#saving");
    form = formDefinition.managed_item;
    data = { "namespace": form['namespace'], "form": formDefinition };  
    $.ajax({
      url: "/forms/" + form['id'],
      type: 'PUT',
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

/*
* Generic node functions
*/
function treeNodeAdd(addFunction) {
  var currentNode = d3eGetCurrent();
  if (currentNode === null) {
    displayWarning("You need to select a node.");
  } else {
    saveNode();
    var node = addFunction(currentNode);
    displayNode(node);
  }
}

function treeNodeDelete(checkChildren) {
  var currentNode = d3eGetCurrent();
  if (currentNode === null) {
    displayWarning("You need to select a node.");
  } else {
    if (checkChildren && hasChildren(currentNode)) {
      displayWarning("You need to remove the child nodes.");
    } else {
      var node = d3eDeleteNode(currentNode);
      displayNode(node);
    } 
  }
}

function treeNodeUp() {
  var currentNode = d3eGetCurrent();
  if (currentNode === null) {
    displayWarning("You need to select a node.");
  } else {
    var parentNode = currentNode.parent;
    if (currentNode.index != 0) {
      d3eMoveNodeUp(currentNode);
      displayNode(currentNode);
    } else {
      displayWarning("You cannot move the node up.");
    }
  }
}

function treeNodeDown() {
  var currentNode = d3eGetCurrent();
  if (currentNode === null) {
    displayWarning("You need to select a node.");
  } else {
    var parentNode = currentNode.parent;
    if (currentNode.index < (parentNode.save.length - 1)) {
      d3eMoveNodeDown(currentNode);
      displayNode(currentNode);
    } else {
      displayWarning("You cannot move the node down.");
    }
  }
}

/*
 * Functions to display the various panels. 
 */
function displayForm(node) {
  $('#formLabel').val(node.data.label);
  $('#formCompletion').val(node.data.completion);
  $('#formNote').val(node.data.note);
  $('#formIdentifier').val(node.data.scoped_identifier.identifier);
  $("#formIdentifier").prop( "disabled", true );
}

function displayGroup(node) {
  $('#groupLabel').val(node.data.label);
  $('#groupCompletion').val(node.data.completion);
  $('#groupNote').val(node.data.note);
  $("#groupRepeating").prop('checked', node.data.repeating);
  $("#groupOptional").prop('checked', node.data.optional);
}

function displayBC(node) {
  $('#bcIdentifier').html(node.data.bc_ref.subject_data.scoped_identifier.identifier);
  $('#bcLabel').html(node.data.label);
  $('#bcCompletion').val(node.data.completion);
  $('#bcNote').val(node.data.note);
}

function displayCommon(node) {
  $('#commonLabel').val(node.data.label);
}

function displayBcItem(node) {
  $('#bcItemLabel').html(node.data.label);
  $("#bcItemEnable").prop('checked', node.data.enabled);
  $("#bcItemOptional").prop('checked', node.data.optional);
  $('#bcItemCompletion').val(node.data.completion);
  $('#bcItemNote').val(node.data.note);
}

function displayCommonItem(node) {
  $('#commonItemLabel').html(node.data.label);
}

function displayQuestion(node) {
  $('#questionLabel').val(node.data.label);
  $('#questionText').val(node.data.question_text);
  $("#questionOptional").prop('checked', node.data.optional);
  $('#questionMapping').val(node.data.mapping);
  $('#questionFormat').val(node.data.format);
  $('#questionCompletion').val(node.data.completion);
  $('#questionNote').val(node.data.note);
  var $radios = $('input:radio[name=dtRadio]');
  $radios.filter('[value=' + node.data.datatype +']').prop('checked', true);
  //questionClTable.clear();
  var items = [];
  if (hasChildren(node)) {
    for (var j=0; j<node.children.length; j++) {
      items.push(node.children[j].data);
      //questionClTable.row.add(node.children[j]);
    }
    node.data.datatype = datatypeMap['string']['xsd_fragment'];
    clEnableDisable(node.data.datatype, true);
    $radios.prop("disabled", true);
    tfeLoad(items);
  } else {
    clEnableDisable(node.data.datatype, false);
    $radios.prop("disabled", false);
    tfeLoad(items);
  }
}

function displayMapping(node) {
  $('#mappingMapping').val(node.data.mapping);
}

function displayPlaceholder(node) {
  $('#placeholderText').val(node.data.free_text);
}

function displayLabelText(node) {
  $('#labelTextLabel').val(node.data.label);
  $('#labelTextText').val(node.data.label_text);
}

function displayCl(node) {
  $('#clIdentifier').html(node.data.subject_data.identifier);
  $('#clDefaultLabel').html(node.data.subject_data.preferredTerm);
  $('#clNotation').html(node.data.subject_data.notation);
  $('#clLocalLabel').val(node.data.local_label);
  $("#clEnable").prop('checked', node.data.enabled);
  $("#clOptional").prop('checked', node.data.optional);
  parentNode = node.parent;
  if (parentNode.type == C_QUESTION) {
    $("#clDefault").prop('disabled', false);
    $("#clEnable").prop('disabled', true);
  } else {
    $("#clDefault").prop('disabled', true);
    $("#clEnable").prop('disabled', false);
  }
}

/*
 * Functions to save the panels
 */
function saveForm(node) {
  node.data.label = $('#formLabel').val();
  node.data.completion = $('#formCompletion').val();
  node.data.note = $('#formNote').val();
  node.name = node.data.label;
}

function saveGroup(node) {
  node.data.label = $('#groupLabel').val();
  node.data.completion = $('#groupCompletion').val();
  node.data.note = $('#groupNote').val();
  node.name = node.data.label;
  node.data.repeating = $('#groupRepeating').is(":checked");
  node.data.optional = $('#groupOptional').is(":checked");
}

function saveCommon(node) {
  node.data.label = $('#commonLabel').val();
  node.name = node.data.label;
}

function saveBc(node) {
  node.data.completion = $('#bcCompletion').val();
  node.data.note = $('#bcNote').val();
}

function saveBcItem(node) {
  node.data.enabled = $('#bcItemEnable').is(":checked");
  node.data.optional = $('#bcItemOptional').is(":checked");
  node.data.completion = $('#bcItemCompletion').val();
  node.data.note = $('#bcItemNote').val();
  node.enabled = node.data.enabled;
}

function saveCommonItem(node) {
  // Nothing to save
}

function saveQuestion(node) {
  var rowData;
  var i;
  var row;
  var tcRefSNode;
  var tcRefD3Node;
  node.data.label = $('#questionLabel').val();
  node.name = node.data.label;
  node.data.question_text = $('#questionText').val();
  node.data.optional = $('#questionOptional').is(":checked");
  node.data.mapping = $('#questionMapping').val();
  node.data.datatype = $('input:radio[name=dtRadio]:checked').val();
  node.data.format = $('#questionFormat').val();
  node.data.completion = $('#questionCompletion').val();
  node.data.note = $('#questionNote').val();
}

function saveMapping(node) {
  node.data.mapping = $('#mappingMapping').val();
}

function savePlaceholder(node) {
  node.data.free_text = $('#placeholderText').val();
}

function saveLabelText(node) {
  node.data.label = $('#labelTextLabel').val();
  node.data.label_text = $('#labelTextText').val();
  node.name = node.data.label;
}

function saveCl(node) {
  node.data.enabled = $('#clEnable').is(":checked");
  node.data.optional = $('#clOptional').is(":checked");
  node.data.local_label = $('#clLocalLabel').val();
  node.name = node.data.local_label;
  node.enabled = node.data.enabled
}

/*
* Common handling
*/
function makeCommon(node) {
  var returnD3Node = node;
  var commonGroup;
  var commonD3Nodes = [];
  var bcD3Node = node.parent;
  var groupD3Node = bcD3Node.parent;
  if (bcD3Node !== null && groupD3Node !== null) {
    commonD3Nodes.push(node);
    for (var i=0; i<groupD3Node.save.length; i++) {
      var child = groupD3Node.save[i];
      if (child.type === C_COMMON_GROUP) {
        commonGroup = child;
      } else {
        if (bcD3Node.key !== child.key && isBcGroup(child)) {
          for (var j=0; j<child.save.length; j++) {
            var item = child.save[j];
            if (commonMatch(node, item)) {
              commonD3Nodes.push(item);
            }
          }  
        }
      }
    }
    if (commonGroup != null) {
      if (commonD3Nodes.length > 0) {
        var d3CommonItem = addCommonItem(commonGroup, commonD3Nodes[0].name);
        returnD3Node = d3CommonItem;
        for (var k=0; k<commonD3Nodes.length; k++) {
          refFromCommon(d3CommonItem, commonD3Nodes[k]);
        } 
      } else {
        displayWarning("No common items matched.");
      }
    } else {
      displayWarning("A common group was not found.");
    }
  } else {
    if (bcD3Node == null && groupD3Node == null) {
      displayWarning("Cannot find Biomedical Concept and the Group parent nodes.");
    } else if (bcD3Node == null) {
      displayWarning("Cannot find Biomedical Concept parent node.");
    } else if (groupD3Node == null) {
      displayWarning("Cannot find Group parent node.");
    }
  }
  return returnD3Node;
}

// Determine if there is a match
function commonMatch(commonD3Node, d3Node) {
  //if ('bridg_path' in d3Node.data.property_ref.subject_data) {
  if (d3Node.data.property_ref.subject_data.bridg_path === commonD3Node.data.property_ref.subject_data.bridg_path) {
    if (d3Node.save.length === commonD3Node.save.length) {
      for (var i=0; i<commonD3Node.save.length; i++) {
        var commonChild = commonD3Node.save[i].data;
        var otherChild = d3Node.save[i].data;
        if (commonChild.subject_data.id !== commonChild.subject_data.id || 
          commonChild.subject_data.namespace !== commonChild.subject_data.namespace) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }
  return false;
}

// Find the common node if present.
function getCommon(d3Node) {
  if (d3Node !== null) {
    if (hasChildren(d3Node)) {
      var child = d3Node.save[0];
      if (child.type === C_COMMON_GROUP) {
        return child;
      }
    }
  }
  return null;
}

// Detaches the node from its 'natural' position and makes common
function refFromCommon(d3Parent, d3Node) {
  var ref = {};
  ref.id = d3Node.data.property_ref.subject_ref.id;
  ref.namespace = d3Node.data.property_ref.subject_ref.namespace;
  d3Parent.data.item_refs.push(ref);
  idKeyMap[ref.id] = d3Node.key;
  d3Parent.bridg_path = d3Node.data.property_ref.subject_data.bridg_path;
  //d3eSetParent(d3Parent);
  //d3eSetOrdinal(d3Parent.data);
  if (!hasChildren(d3Parent)) {
    for (var i=0; i<d3Node.save.length; i++) {
      var copy = JSON.parse(JSON.stringify(d3Node.save[i].data))
      setD3(copy, d3Parent);
    }
  }
  commonMark(d3Node, true);
  d3eForceHide(d3Node);
}

// Restores from common to the nodes 'natural' position.
function restoreCommon(d3Node) {
  for (var i=0; i<d3Node.data.item_refs.length; i++) {
    var ref = d3Node.data.item_refs[i];
    var key = findKeyFromId(ref.id);
    if (key !== null) {
      var commonD3Node = d3FindData(key);
      if (commonD3Node !== null) {
        commonMark(commonD3Node, false);
        d3eForceExpand(commonD3Node);
      } else {
        displayError("Cannot restore common item back to the owning Biomedical Concept, cannot find node.");
      }
    } else {
      displayError("Cannot restore common item back to the owning Biomedical Concept, cannot find key.");
    }
  }
}

// Deletes from common as BC node is being deleted.
function deleteCommon(bcNode) {
  var d3Node = getCommon(bcNode.parent);
  if (d3Node !== null) {
    for (var i=0; i<d3Node.save.length; i++) {
      var itemD3Node = d3Node.save[i];
      for (var j=0; j<bcNode.save.length; j++) {
        var sNode = bcNode.save[j].data;
        removeItemRef(itemD3Node, sNode.property_ref.subject_ref.id);
      }
    }
    for (var i=0; i<d3Node.save.length; i++) {
      itemD3Node = d3Node.save[i];
      if (itemD3Node.data.item_refs.length === 0) {
        d3eDeleteNode(itemD3Node);
      }
    }
  }
}

function removeItemRef(d3Node, id) {
  for (var k=0; k<d3Node.data.item_refs.length; k++) {
    var item_ref = d3Node.data.item_refs[k];
    if (id === item_ref.id) {
      d3Node.data.item_refs.splice(k, 1);
      removeKeyFromId(id);
      break;
    }
  }
}

function commonMark(d3Node, value) {
  d3Node.is_common = value;
  d3Node.data.is_common = value;
  if (hasChildren(d3Node)) {
    for (var i=0; i<d3Node.save.length; i++) {
      d3Node.save[i].is_common = value;
      d3Node.save[i].data.is_common = value;
    }
  }
}

function findKeyFromId(id) {
  if (idKeyMap.hasOwnProperty(id)) {
    return idKeyMap[id];
  } else {
    return null;
  }
}

function removeKeyFromId(id) {
  if (idKeyMap.hasOwnProperty(id)) {
    delete idKeyMap[id]; 
  }
}

/*
* New blank object functions
*/
function newFormGroup(nullVar) {
  return { 
    type: C_NORMAL_GROUP, label: "", id: "", namespace: "", ordinal: 0, optional: false, repeating: false, 
    note: "", completion: "", bc_ref: {}, children: [] };
}

function newCommonGroup(nullVar) {
  return {
    type: C_COMMON_GROUP, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, repeating: false, completion: "", note: "", children: [] };
}

function newCommonItem(nullVar) {
  return {
    type: C_COMMON_ITEM, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, completion: "", note: "", bridg_path: "", item_refs: [], children: [] };
}

function newQuestion(nullVar) {
  return {
    type: C_QUESTION, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, completion: "", note: "", free_text: "", label_text: "", datatype: "string",
    format: "20", question_text: "", pText: "", mapping: "",
    children: [] 
  };
}

function newMapping(nullVar) {
  return {
    type: C_MAPPING, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, completion: "", note: "", mapping: "",
    children: [] 
  };
}

function newPlaceholder(nullVar) {
  return {
    type: C_PLACEHOLDER, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, completion: "", note: "", free_text: "", label_text: "",datatype: "",
    format: "", question_text: "", pText: "", mapping: "",
    children: [] 
  };
}

function newLabelText(nullVar) {
  return {
    type: C_TEXTLABEL, label: "", id: "", namespace: "", ordinal: 0, 
    optional: false, completion: "", note: "", free_text: "", label_text: "",datatype: "",
    format: "", question_text: "", pText: "", mapping: "",
    children: [] 
  };
}

function newBCGroup(bc) {
  return {
    type: C_NORMAL_GROUP, label: "", id: "", namespace: "", ordinal: 0, 
    repeating: false, optional: false, completion: "", note: "", 
    bc_ref: 
      { 
        enabled: true, 
        optional: false,
        ordinal: 0, 
        local_label: "",
        subject_ref: {id: bc.id, namespace: bc.namespace},
        subject_data: bc
      },
    children: [] };
}

function newBCProperty(property) {
  return {
    type: C_BC_QUESTION, label: "", id: "", namespace: "", ordinal: 0, 
    is_common: false, optional: false, completion: "", note: "",
    property_ref: 
      { 
        enabled: true, 
        optional: false,
        ordinal: 0, 
        local_label: "",
        subject_ref: {id: property.id, namespace: property.namespace},
        subject_data: property
      },
    children: [] 
  };
}

function newBCPropertyCli(cli) {
  return {
    type: C_TC_REF, label: cli.label, id: "", namespace: "", ordinal: 0, 
    local_label: cli.local_label, enabled: true, optional: false,
    subject_ref: {id: cli.subject_ref.id, namespace: cli.subject_ref.namespace}
  };
}

function newQuestionCli(cli) {
  return {
    type: C_TC_REF, label: cli.subject_data.label, id: "", namespace: "", ordinal: 0, 
    local_label: cli.subject_data.label, enabled: true, optional: false, 
    subject_ref: cli.subject_ref,
    subject_data: cli.subject_data
  };
}

/*
* Add functions
*/
function addGroup(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_NORMAL_GROUP, "Group", newFormGroup, null, true, false);
  d3eAddData(d3ParentNode, d3Node.data, true);
  return d3Node;
}

function addCommonGroup(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_COMMON_GROUP, "Common Group", newCommonGroup, null, false, false);
  d3eAddData(d3ParentNode, d3Node.data, false);
  return d3Node;
}

function addCommonItem(d3ParentNode, label) {
  var d3Node = addD3Node(d3ParentNode, C_COMMON_ITEM, label, newCommonItem, null, true, false);
  d3eAddData(d3ParentNode, d3Node.data, true);
  return d3Node;
}

function addQuestion(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_QUESTION, "Question", newQuestion, null, true, true);
  d3eAddData(d3ParentNode, d3Node.data, true);
  return d3Node;
}

function addMapping(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_MAPPING, "Mapping", newMapping, null, true, true);
  d3eAddData(d3ParentNode, d3Node.data, true);
  return d3Node;
}

function addPlaceholder(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_PLACEHOLDER, "Placeholder", newPlaceholder, null, true, true);
  d3eAddData(d3ParentNode, d3Node.data, true);
  return d3Node;
}

function addLabelText(d3ParentNode) {
  var d3Node = addD3Node(d3ParentNode, C_TEXTLABEL, "Label Text", newLabelText, null, true, true);
  d3eAddData(d3ParentNode, d3Node.data, true)
  return d3Node;
}

function addBc(d3ParentNode) {
  var data = bcSelect.row(bcCurrentRow).data();
  $.ajax({
    url: "/biomedical_concepts/" + data.id,
    data: { "biomedical_concept": { "namespace": data.namespace }},
    dataType: 'json',
    error: function (xhr, status, error) {
      displayError("An error has occurred loading the Biomedical Concept.");
    },
    success: function(result){
      var bc = $.parseJSON(JSON.stringify(result));
      var bcD3Node = addD3Node(d3ParentNode, C_NORMAL_GROUP, bc.label, newBCGroup, bc, true, false);
      d3eAddData(d3ParentNode, bcD3Node.data, true)
      for (var i=0; i<bc.children.length; i++) {
        var property = bc.children[i];
        if (property.enabled && property.collect) {
          var propertyD3Node = addD3Node(bcD3Node, C_BC_QUESTION, property.alias, newBCProperty, property, true, false);
          d3eAddData(bcD3Node, propertyD3Node.data, true)
          for (var j=0; j<property.children.length; j++) {
            var tcRef = property.children[j];
            var tcRefD3Node = addD3Node(propertyD3Node, C_TC_REF, tcRef.local_label, newBCPropertyCli, tcRef, true, false);
            tcRefD3Node.enabled = true    
            d3eAddData(propertyD3Node, tcRefD3Node.data, true);
            getReference(tcRefD3Node);
          }
        }
      }
      if (hasCommonGroup(d3ParentNode)) {
        var commonNode = d3ParentNode.save[0];
        if (hasChildren(commonNode)) {
          for (var i=0; i<commonNode.save.length; i++) {
            var d3CommonItem = commonNode.save[i];
            for (var j=0; j<bcD3Node.save.length; j++) {
              var item = bcD3Node.save[j];
              if (d3CommonItem.data.item_refs.length > 0) {
                var ref = d3CommonItem.data.item_refs[0];
                var key = findKeyFromId(ref.id);
                if (key !== null) {
                  var node = d3FindData(key);
                  if (node !== null) {
                    if (commonMatch(node, item)) {
                      refFromCommon(d3CommonItem, item);
                    }
                  } else {
                    displayError("An error has occurred loading the Biomedical Concept, cannot find node.");
                  }
                } else {
                  displayError("An error has occurred loading the Biomedical Concept, cannot find key.");
                }
              }
            }
          }
        }
      }
    }
  });
}

function addD3Node(d3ParentNode, type, label, newFunction, functionData, atEnd, addCount) {
  var count;
  var text;
  if (addCount) {
    if (hasChildren(d3ParentNode)) {
      count = d3ParentNode.save.length + 1;
    } else {
      count = 1;
    }
    text = label + " " + count;
  } else {
    text = label;
  }
  var sNode = newFunction(functionData);
  sNode.label = text
  var d3Node = d3eAddNode(d3ParentNode, text, type, true, sNode, atEnd);   
  return d3Node
}

//function addSNode(parent, node, end) {
//  if (end) {
//    parent.children.push(node);
//  } else {
//    parent.children.unshift(node);
//  }
//  d3eSetOrdinal(parent);
//}

/*
* Other utility functions
*/
function findNodeFromId(id) {
  if (idKeyMap.hasOwnProperty(id)) {
    return idKeyMap[id];
  } else {
    displayError("An error has occurred finding a node from an id.");
    return null;
  }
}

function feTermCallBack(count, node) {
  var currentD3Node = node;
  if (count === 0) {
    d3eDeleteChildren(currentD3Node);
    displayNode(currentD3Node);
  } else {
    d3eDeleteChildren(currentD3Node);
    var items = tfeToData();
    for (var i=0; i<items.length; i++) {
      var tcRefSNode = newQuestionCli(items[i]);
      var tcRefD3Node = d3eAddNode(currentD3Node, tcRefSNode.local_label, tcRefSNode.type, true, tcRefSNode, true);
      d3eAddData(currentD3Node, tcRefD3Node.data, true);
    }
    displayNode(currentD3Node);
  }  
}

function feMoveUp(node) {
  feTermCallBack(1, node) 
}

function feMoveDown(node) {
  feTermCallBack(1, node) 
}

function feEmpty(node) {
}

function initData () {
  var managedItem;
  // Get the JSON objects
  var html1 = $("#formJson").html();
  formDefinition = $.parseJSON(html1);
  var html2 = $("#datatype_map").html();
  datatypeMap = $.parseJSON(html2);
  // Initialize
  managedItem = formDefinition.managed_item;
  previousSave = JSON.stringify(formDefinition);
  markdownElement = null;
  markdownType = "";
  bcCurrent = null;
  bcCurrentRow = null;
  //notepadTableReload = false;
  //notepadData = null;
  //notepadRow = null; 
  //varClCurrent = null;
  //varClCurrentRow = null;
  feInitializeTimeoutCount = 0;
  d3eInit("d3", saveNode, displayNode, feEmpty, validateNode);
  //tsInit(notepadUpdated);
  rootNode = d3eRoot(managedItem.label, C_FORM, managedItem)
  idKeyMap = {};
  for (var i=0; i<managedItem.children.length; i++) {
    setD3(managedItem.children[i], rootNode);
  }
  tfeInit();
  tfeSetCallBacks(feTermCallBack, feMoveUp, feMoveDown);
  feUpdateSave();
}

function feInitializeTimeout() {
  setTimeout(function(){
    feUpdateSave();
  }, 500);
}

function feUpdateSave () {
  //console.log ("Active=" + $.active + ", Counter=" + feInitializeTimeoutCount)
  if ($.active) {
    if (feInitializeTimeoutCount < 10) {
      feInitializeTimeout();
      feInitializeTimeoutCount++;
      return;
    }
  } 
  previousSave = JSON.stringify(formDefinition);
}

// Note pad callback
/*function notepadUpdated() {
  if (notepadTableReload) {
    notepadTable.ajax.reload();
  }
}*/

/*
* Set the D3 Structures
*
* @param sourceNode [Object] The data node
* @param d3ParentNode [Object] The parent D3 node
* @return [Null]
*/
function setD3(sourceNode, d3ParentNode) {
  var newNode = d3eAddNode(d3ParentNode, sourceNode.label, sourceNode.type, true, sourceNode, true);
  getReference(newNode);
  if (sourceNode.hasOwnProperty('children')) {
    for (var i=0; i<sourceNode.children.length; i++) {
      var child = sourceNode.children[i];
      setD3(child, newNode);
    }
  }
  if (newNode.is_common) {
    d3eForceHide(newNode);
  }
}

function validateNode(node) {
  return $('#main_form').valid();
}

function saveNode() {
  var d3Node = d3eGetCurrent();
  if (d3Node.type === C_FORM) {
    saveForm(d3Node)
  } else if (d3Node.type === C_NORMAL_GROUP) {
    if (!isBcGroup(d3Node)) {
      saveGroup(d3Node);
    } else {
      saveBc(d3Node);
    }
  } else if (d3Node.type === C_COMMON_GROUP) {
    saveCommon(d3Node)
  } else if (d3Node.type === C_BC_QUESTION) {
    saveBcItem(d3Node);
  } else if (d3Node.type === C_PLACEHOLDER) {
    savePlaceholder(d3Node)
  } else if (d3Node.type === C_TEXTLABEL) {
    saveLabelText(d3Node)
  } else if (d3Node.type === C_QUESTION) {
    saveQuestion(d3Node)
  } else if (d3Node.type === C_MAPPING) {
    saveMapping(d3Node)
  } else if (d3Node.type === C_COMMON_ITEM) {
    saveCommonItem(d3Node);
  } else if (d3Node.type === C_TC_REF) {
    saveCl(d3Node)
  } 
  saveRest();
}

function displayNode(d3Node) {
  d3eDisplayTree(d3Node.key);
  tfeDisable();
  tfeClear();
  if (d3Node.type === C_FORM ) {
    selectForm();
    displayForm(d3Node);
  } else if (d3Node.type === C_NORMAL_GROUP) {
    if (!isBcGroup(d3Node)) {
      selectGroup();
      displayGroup(d3Node);
    } else {
      selectBC();
      displayBC(d3Node);
    }
  } else if (d3Node.type === C_COMMON_GROUP) {
    selectCommon();
    displayCommon(d3Node);
  } else if (d3Node.type === C_BC_QUESTION) {
    selectBcQuestion();
    displayBcItem(d3Node);
  } else if (d3Node.type === C_QUESTION) {
    //questionClTable.clear();
    selectQuestion();
    displayQuestion(d3Node);
    //questionClTable.draw(false);
  } else if (d3Node.type === C_MAPPING) {
    selectMapping();
    displayMapping(d3Node);
  } else if (d3Node.type === C_COMMON_ITEM) {
    selectCommonItem();
    displayCommonItem(d3Node);
  } else if (d3Node.type === C_PLACEHOLDER) {
    selectPlaceholder();
    displayPlaceholder(d3Node);
  } else if (d3Node.type === C_TEXTLABEL) {
    selectLabelText();
    displayLabelText(d3Node);
  } else if (d3Node.type === C_TC_REF) {
    selectCl();
    displayCl(d3Node);
  } 
}

/*
* Get Reference
*
* @param node [Object] The D3 node
* @return [Null]
*/
function getReference(d3Node) {
  if (isBcGroup(d3Node)) {
    getBc(d3Node, bcResult);
  } else if (d3Node.type === C_TC_REF) {
    getThesaurusConcept(d3Node, tcResult);
  } else if (d3Node.type === C_BC_QUESTION) {
    getBcProperty(d3Node, bcPropertyResult)
  } else if (d3Node.type === C_COMMON_ITEM) {
    if (d3Node.data.item_refs.length > 0) {
      getBcPropertyCommon(d3Node, bcPropertyResultCommon)
    }
  } 
}

/*
* Thesaurus Ref AJAX Result Callback
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function tcResult(d3Node, result) {
  var d3CurrentNode = d3eGetCurrent();
  d3Node.data.subject_data = result;
  if (d3Node.data.hasOwnProperty['local_label']) {
    if (d3Node.data.local_label === "") {
      d3Node.data.local_label = result.preferredTerm;
    }
  } else {
    d3Node.data.local_label = result.preferredTerm;
  }
  d3Node.name = d3Node.data.local_label;
  displayNode(d3CurrentNode);
}

/*
* BC Ref AJAX Result Callback for BC
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function bcResult(d3Node, result) {
  var d3CurrentNode = d3eGetCurrent();
  d3Node.data.bc_ref.subject_data = {};
  d3Node.data.bc_ref.subject_data.scoped_identifier = {};
  d3Node.data.bc_ref.subject_data.scoped_identifier.identifier = result.scoped_identifier.identifier;
  d3Node.name = result.label;
  displayNode(d3CurrentNode);
}

/*
* BC Property Ref AJAX Result Callback for BC Property
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function bcPropertyResult(d3Node, result) {
  var d3CurrentNode = d3eGetCurrent();
  d3Node.data.property_ref.subject_data = result;
  idKeyMap[d3Node.data.property_ref.subject_ref.id] = d3Node.key;
  var parent = d3Node.parent;
  var group = d3Node.parent.parent;
  displayNode(d3CurrentNode);
}

/*
* BC Property Ref AJAX Result Callback for Common Item
*
* @param node [Object] The D3 node
* @param result [Object] Result received from server
* @return [Null]
*/
function bcPropertyResultCommon(d3Node, result) {
  var d3CurrentNode = d3eGetCurrent();
  d3Node.data.bridg_path = result.bridg_path;
  if (!hasChildren(d3Node)) {
    for (var i=0; i<result.children.length; i++) {
      setD3(result.children[i], d3Node);
    }
  }
}
;
