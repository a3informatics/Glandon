$(document).ready(function() {
  
  var formDefinition ;
  var formSave;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var formIdentifierElement = document.getElementById("formIdentifier");
  var formLabelElement = document.getElementById("formLabel");
  var groupIdentifierElement = document.getElementById("groupIdentifier");
  var groupLabelElement = document.getElementById("groupLabel");
  var itemIdentifierElement = document.getElementById("itemIdentifier");
  var itemLabelElement = document.getElementById("itemLabel");
  var itemEnableElement = document.getElementById("itemEnable");
  var clIdentifierElement = document.getElementById("clIdentifier");
  var clLabelElement = document.getElementById("clLabel");
  var clEnableElement = document.getElementById("clEnable");
  var alertsId = document.getElementById("alerts")
  
  var nodeKey;
  var normal;
  var currentNode;
  var currentThis;
  var bcCurrent;
  var bcCurrentRow;
  var bcSelect = $('#bcTable').DataTable( {
    "ajax": {
      "url": "../cdisc_bcs"
    },
    dataType: 'json',
        success: function(result){
          alert("data!")
        },
    "pageLength": 5,
    "bProcessing": true,
    "columns": [
      {"data" : "identifier", "width" : "50%"},
      {"data" : "label", "width" : "50%"}
    ]
  });

  // Get the JSON structure. Set the namespace of the thesauri.
  formDefinition = $.parseJSON(html);
  initData();

  // Draw the initial tree and select the form.
  redraw();
  selectForm();

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {    
    if (currentNode != null) {
      clearNode(currentNode, currentThis);
      if (currentNode.type == "Form") {
        saveForm(currentNode)
      } else if (currentNode.type == "Group" || currentNode.type == "BCGroup") {
        saveGroup(currentNode)
      }
    }
    if (node.type == "Form") {
      selectForm();
      displayForm(node);
    } else if (node.type == "Group" || node.type == "BCGroup") {
      selectGroup();
      displayGroup(node);
    } else if (node.type == "Item") {
      selectItem();
      displayItem(node);
    } else if (node.type == "CL") {
      selectCl();
      displayCl(node);
    }
    markNode1(this);
    currentNode = node;
    currentThis = this;
  }  

  /**
   * Function to handle double click on the D3 tree.
   * Expand/delete the node clicked.
   */
  function dblClick(node) {
    
    var index;

    if (node.hasOwnProperty('children')) {
      node.children = [];
      node.expand = true;
      redraw();
    } else if (node.hasOwnProperty('save')) {
      node.children = [];
      node.children = node.save;
      node.expand = false;
      redraw();
    }
  } 

  /* 
  * Function to handle the form save click.
  */
  $('#formSave').click(function() {
    
    // Copy the definition. Removes the circulart references and 
    // preserves the structure fo rfurther editing.
    formSave = {};
    copyNode(formDefinition, formSave);
    //alert("Data=" + JSON.stringify(formSave));

    // Send to the server
    $.ajax({
      url: "../forms",
      type: 'POST',
      data: { "form": formSave },
      success: function(result){
        var html = alertSuccess("Form has been saved.");
        displayAlerts(html);
      },
      error: function(xhr,status,error){
        var errors;
        var html;
        errors = $.parseJSON(xhr.responseText).errors;
        var html = ""
        for (var i=0; i<errors.length; i++) {
          html = html + alertError(errors[i]);
        }
        displayAlerts(html);
      }
    }); 

  });

  /*
   * Functions to handle click on the update button.
   */
  $('#formUpdate').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select the form node.");
      displayAlerts(html);
    } else {
      saveForm(currentNode)
      redraw();
    }
    //markNode(currentNode, currentThis);
  });

  $('#groupUpdate').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveGroup(currentNode)
      redraw();
    }
  });
  
  $('#itemUpdate').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveItem(currentNode);
    }
  });
  
  $('#clUpdate').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveCl(currentNode)
    }
  });
  
  /*
   * Functions to handle click on the add group button.
   */
  $('#formAddGroup').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      addGroup();
      redraw();
    }
  });

  $('#groupAddGroup').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      addGroup();
      redraw();
    }
  });

  /*
   * Function to handle click on the Form Group add button.
   */
  $('#groupDeleteGroup').click(function() {
    var parentNode;
    if (currentNode.hasOwnProperty('children')) {
      var html = alertWarning("You need to delete the child nodes.");
      displayAlerts(html);
    } else {
      parentNode = currentNode.parent
      parentIndex = currentNode.index
      parentNode.children.splice(parentIndex, 1);
      if (parentNode.children.length == 0) {
        parentNode.children = [];
        parentNode.save = [];
      }
      setParent(parentNode);
      redraw();
    }     
  });

  /*
   * Functions to handle click on the BC add button.
   */
  $('#formAddBc').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select the form node.");
      displayAlerts(html);
    } else {
      addBc();
    }
  });

  $('#groupAddBc').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      addBc();
    }
  }); 

  /*
   * Function to handle click on the BC table.
   */
  $('#bcTable tbody').on('click', 'tr', function () {
    handleDataTable(bcSelect, this);
  });

  /* ****************
  * Utility Functions
  */

  function selectForm() {
    $("#formInfo").removeClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").removeClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }

  function selectGroup() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").removeClass('hidden');
    $("#bcInfo").removeClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }
  
  function selectItem() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#itemInfo").removeClass('hidden');
    $("#clInfo").addClass('hidden');
  }

  function selectCl() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").removeClass('hidden');
  }

  function initData () {
    normal = true;
    currentNode = null;
    //currentThis = null;
    bcCurrent = null;
    bcCurrentRow = null;
    nodeKey = 2; // 1 id the root node.
  }

  function setParent(node) {
    if (node.hasOwnProperty('children')) {
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        child.parent = node;
        child.index = i;
        setParent(child);
      }
    }
  }

  /**
   * Functions to display the various panels. 
   */
  function displayForm(node) {
    formIdentifierElement.value = node.identifier;
    formLabelElement.value = node.label;
  }

  function displayGroup(node) {
    groupIdentifierElement.value = node.identifier;
    groupLabelElement.value = node.label;
  }

  function displayItem(node) {
    itemIdentifierElement.innerHTML = node.identifier;
    itemLabelElement.innerHTML = node.label;
    itemEnableElement.checked = node.enabled;
    //itemIdentifierElement.value = node.identifer;
    //itemLabelElement.value = node.label;
  }

  function displayQuestion(node) {
    itemIdentifierElement.value = node.identifier;
    itemLabelElement.value = node.label;
  }

  function displayCl(node) {
    clIdentifierElement.innerHTML = node.identifier;
    clLabelElement.innerHTML = node.label;
    clEnableElement.checked = node.enabled;
    //clIdentifierElement.value = node.identifier;
    //clLabelElement.value = node.label;
  }

  /**
   * Functions to save info.
   */
  function saveForm(node) {
    node.identifier = formIdentifierElement.value;
    node.label = formLabelElement.value;
    node.name = node.label;
  }

  function saveGroup(node) {
    node.identifier = groupIdentifierElement.value;
    node.label = groupLabelElement.value;
    node.name = node.label;
  }

  function saveItem(node) {
    node.enabled = itemEnableElement.checked;
  }

  function saveCl(node) {
    node.enabled = clEnableElement.checked;
  }

  function addGroup() {
    var index;
    if (currentNode.hasOwnProperty('children')) {
      index = currentNode.children.length;
    } else {
      currentNode.children = [];
      currentNode.save = [];
      index = 0;
    }     
    currentNode.children[index] = {};
    currentNode.children[index].identifier = "New Group"
    currentNode.children[index].name = "Not set"
    currentNode.children[index].label = "Not set"
    currentNode.children[index].type = "Group"
    currentNode.children[index].parent = currentNode
    currentNode.children[index].index = index
    currentNode.save = currentNode.children
  }

  function addBc() {
    var parentNode;
    var data = bcSelect.row(bcCurrentRow).data();

    //alert ("BC id=" + data.id);
    $.ajax({
      url: "../cdisc_bcs/" + data.id,
      data: {
        "id": data.id,
        "namespace": data.namespace
      },
      dataType: 'json',
      success: function(result){
        var bc = $.parseJSON(JSON.stringify(result));
        var index;
        var pIndex;
        var cIndex;
        var i,j;
        if (currentNode.hasOwnProperty('children')) {
          index = currentNode.children.length;
        } else {
          currentNode.children = [];
          currentNode.save = [];
          index = 0;
        }     
        currentNode.children[index] = {};
        currentNode.children[index].id = bc.id;
        currentNode.children[index].namespace = bc.namespace;
        currentNode.children[index].name = bc.label;
        currentNode.children[index].identifier = bc.identifier;
        currentNode.children[index].label = bc.label;
        currentNode.children[index].type = "BCGroup";
        //currentNode.children[index].label = bc.label;
        currentNode.children[index].children = [];
        nodeKey += 1
        pIndex = 0;
        for (i=0; i<bc.properties.length; i++) {
          var property = bc.properties[i];
          if (property[1].Enabled && property[1].Collect) {
            currentNode.children[index].children[pIndex] = {};
            currentNode.children[index].children[pIndex].id = property[1].id;
            currentNode.children[index].children[pIndex].namespace = property[1].namespace;
            currentNode.children[index].children[pIndex].name = property[1].Alias;
            currentNode.children[index].children[pIndex].type = "Item";
            currentNode.children[index].children[pIndex].identifer = property[1].Name;
            currentNode.children[index].children[pIndex].label = property[1].Alias;
            currentNode.children[index].children[pIndex].enabled = true;
            var values = property[1].Values
            if (values.length > 0) {
              currentNode.children[index].children[pIndex].children = [];
              for (j=0; j<values.length; j++) {
                currentNode.children[index].children[pIndex].children[j] = {};
                //var keys = Object.keys(values[j].clis); 
                currentNode.children[index].children[pIndex].children[j].id = values[j].id;
                currentNode.children[index].children[pIndex].children[j].namespace = values[j].namespace;
                currentNode.children[index].children[pIndex].children[j].name = values[j].cli.notation;
                currentNode.children[index].children[pIndex].children[j].type = "CL";
                currentNode.children[index].children[pIndex].children[j].identifier = values[j].cli.identifier;
                currentNode.children[index].children[pIndex].children[j].label = values[j].cli.notation;
                currentNode.children[index].children[pIndex].children[j].enabled = true;
              }
              currentNode.children[index].children[pIndex].save = currentNode.children[index].children[pIndex].children;
            }
            pIndex++;
          }
        }
        currentNode.children[index].save = currentNode.children[index].children;
        redraw();
      }
    });   
  }

  /**
   *  Function to draw the tree
   */
  function redraw () {
    if (normal) {
      treeNormal(d3Div, formDefinition, click, dblClick);
    } else {
      treeCircular(d3Div, formDefinition, click, dblClick);
    }
    currentNode = null;
    currentThis = null;
  }
  
  function handleDataTable(table,ref) {
    // Toggle the highlight for the row
    if (bcCurrent !=  null) {
      $(bcCurrent).toggleClass('success');
    }
    $(ref).toggleClass('success');

    // Get the row
    var row = table.row(ref).index();
    var data = table.row(row).data();

    // Save the selection
    bcCurrent = ref;
    bcCurrentRow = row;
  }

  function copyNode(sourceNode, targetNode) {
    var key;
    var i;
    for (key in sourceNode) {
      if (key == 'parent' || key == 'children' || key == 'save') {
      } else {
        targetNode[key] = sourceNode[key]
      }
    }
    if (sourceNode.hasOwnProperty('children')) {
      targetNode.children = [];
      for (i=0; i<sourceNode.children.length; i++) {
        //sourceChild = sourceNode.children[i];
        targetNode.children[i] = {}; 
        copyNode(sourceNode.children[i], targetNode.children[i]);
      }
    }
  }
  
});