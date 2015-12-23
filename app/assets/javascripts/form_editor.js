$(document).ready(function() {
  
  var formDefinition ;
  var formSave;
  var d3Div = document.getElementById("d3");
  var html  = $("#jsonData").html();
  var formIdentifierElement = document.getElementById("formIdentifier");
  var formLabelElement = document.getElementById("formLabel");
  var groupIdentifierElement = document.getElementById("groupIdentifier");
  var groupLabelElement = document.getElementById("groupLabel");
  var commonIdentifierElement = document.getElementById("commonIdentifier");
  var commonLabelElement = document.getElementById("commonLabel");
  var bcIdentifierElement = document.getElementById("bcIdentifier");
  var bcLabelElement = document.getElementById("bcLabel");
  var itemIdentifierElement = document.getElementById("itemIdentifier");
  var itemLabelElement = document.getElementById("itemLabel");
  var itemEnableElement = document.getElementById("itemEnable");
  var clIdentifierElement = document.getElementById("clIdentifier");
  var clLabelElement = document.getElementById("clLabel");
  var clEnableElement = document.getElementById("clEnable");
  var alertsId = document.getElementById("alerts")
  
  var nextKeyId;
  var normal;
  var currentNode;
  var currentGRef;
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
    "lengthMenu": [[5, 10, 25, 50], [5, 10, 25, 50]],
    "pagingType": "full",
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
  setRoot();

  /**
   * Function to handle click on the D3 tree.
   * Show the node info. Highlight the node.
   */
  function click(node) {    
    if (currentGRef != null) {
      clearNode(currentNode, currentGRef);
      if (currentNode.type == "Form") {
        saveForm(currentNode)
      } else if (currentNode.type == "Group") {
        saveGroup(currentNode)
      } else if (currentNode.type == "CommonGroup") {
        saveCommon(currentNode)
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
    var index;
    if (node.hasOwnProperty('children')) {
      node.children = [];
      node.expand = true;
      displayTree(node.key);
    } else if (node.hasOwnProperty('save')) {
      node.children = [];
      node.children = node.save;
      node.expand = false;
      displayTree(node.key);
    }
  } 

  /* 
  * Function to handle the form save click.
  */
  $('#formSave').click(function() {
    
    var formSave;

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
   * Functions to handle the form actions.
   */
  $('#formUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select the form node.");
      displayAlerts(html);
    } else {
      saveForm(currentNode);
      displayTree(currentNode.key);
    }
  });

  $('#formAddGroup').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select the form node.");
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
  $('#groupUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveGroup(currentNode)
      displayTree(currentNode.key);
    }
  });
  
  $('#groupAddGroup').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      var node = addGroup();
      displayNode(node);
      displayTree(node.key);  
    }
  });

  $('#groupDelete').click(function() {
    if (currentNode.hasOwnProperty('save')) {
      var html = alertWarning("You need to delete the child nodes.");
      displayAlerts(html);
    } else {
      var node = deleteNode(currentNode);
      displayNode(node);
      displayTree(node.key);
    }     
  });

  $('#groupAddCommon').click(function() {
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

  $('#groupAddBc').click(function() {
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

  /*
  * Functions to handle the common actions
  */
  $('#commonUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a common node.");
      displayAlerts(html);
    } else {
      saveCommon(currentNode)
      displayTree(currentNode.key);
    }
  });
  
  $('#commonDelete').click(function() {
    if (currentNode.hasOwnProperty('save')) {
      var html = alertWarning("You need to remove the child nodes.");
      displayAlerts(html);
    } else {
      var node = deleteNode(currentNode);
      displayNode(node);
      displayTree(node.key);
    }     
  });

  /*
  * Functions to handle the BC actions
  */
  $('#bcDelete').click(function() {
    //var node = deleteNode(currentNode);
    //displayNode(node);
    //displayTree(node.key);
    notImplementedYet();     
  });

  /*
  * Functions to handle the item actions
  */
  $('#itemUpdate').click(function() {
    if (currentGRef == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveItem(currentNode);
      displayTree(currentNode.key);
    }
  });
  
  $('#itemCommon').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select an item node.");
      displayAlerts(html);
    } else {
      makeCommon(currentNode);
    }
  }); 

  $('#itemRestore').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select an item node.");
      displayAlerts(html);
    } else {
      restoreCommon(currentNode);
      //notImplementedYet();
    }
  }); 

  /*
  * Functions to handle the code list items actions
  */
  $('#clUpdate').click(function() {
    if (currentNode == null) {
      var html = alertWarning("You need to select a group node.");
      displayAlerts(html);
    } else {
      saveCl(currentNode)
      displayTree(currentNode.key);
    }
  });
  
  /*
   * Function to handle click on the BC selection table.
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
    $("#bcInfo").addClass('hidden');
    $("#commonInfo").addClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }

  function selectGroup() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").removeClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#commonInfo").addClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }
  
  function selectBC() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").removeClass('hidden');
    $("#commonInfo").addClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }
  
  function selectCommon() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#commonInfo").removeClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").addClass('hidden');
  }
  
  function selectItem() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#commonInfo").addClass('hidden');
    $("#itemInfo").removeClass('hidden');
    $("#clInfo").addClass('hidden');
  }

  function selectCl() {
    $("#formInfo").addClass('hidden');
    $("#groupInfo").addClass('hidden');
    $("#bcInfo").addClass('hidden');
    $("#commonInfo").addClass('hidden');
    $("#itemInfo").addClass('hidden');
    $("#clInfo").removeClass('hidden');
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

  function displayBC(node) {
    bcIdentifierElement.innerHTML = node.identifier;
    bcLabelElement.innerHTML = node.label;
  }

  function displayCommon(node) {
    commonIdentifierElement.value = node.identifier;
    commonLabelElement.value = node.label;
  }

  function displayItem(node) {
    var parentNode;
    itemIdentifierElement.innerHTML = node.identifier;
    itemLabelElement.innerHTML = node.label;
    parentNode = node.parent;
    if (isCommon(parentNode)) {
      $("#itemEnable").prop('disabled', true);
      $("#itemUpdate").prop('disabled', true);
      $("#itemCommon").prop('disabled', true);
      $("#itemRestore").prop('disabled', false);
    } else {
      $("#itemEnable").prop('disabled', false);
      $("#itemUpdate").prop('disabled', false);
      $("#itemCommon").prop('disabled', false);
      $("#itemRestore").prop('disabled', true);
      itemEnableElement.checked = node.enabled;
    }
  }

  function displayCl(node) {
    clIdentifierElement.innerHTML = node.identifier;
    clLabelElement.innerHTML = node.label;
    clEnableElement.checked = node.enabled;
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

  function saveCommon(node) {
    node.identifier = commonIdentifierElement.value;
    node.label = commonLabelElement.value;
    node.name = node.label;
  }

  function saveItem(node) {
    node.enabled = itemEnableElement.checked;
  }

  function saveCl(node) {
    node.enabled = clEnableElement.checked;
  }

  function makeCommon(node) {
    var child;
    var item;
    var commonGroup;
    var otherNodes = [];
    var bcParent = node.parent;
    var groupParent = bcParent.parent;
    if (bcParent != null && groupParent != null) {
      for (var i=0; i<groupParent.save.length; i++) {
        child = groupParent.save[i];
        if (child.type == 'CommonGroup') {
          commonGroup = child;
        } else if (child.type == 'BCGroup') {
          for (var j=0; j<child.save.length; j++) {
            item = child.save[j];
            if ('bridgPath' in item) {
              if (node.key == item.key) {
                // Same node, ignore.
              } else if (node.bridgPath == item.bridgPath) {
                otherNodes.push(item);

                // Delete the item from its current position
                item.realParent = item.parent;
                child.save.splice(item.index, 1);
                setParent(child);
              }
            }
          }
        }
      }
      if (commonGroup != null) {
        node.otherCommon = [];
        node.otherCommon = otherNodes
        if (!commonGroup.hasOwnProperty('save')) {
          commonGroup.children = [];
          commonGroup.save = [];
        }  
        commonGroup.children.push(node);
        commonGroup.save = commonGroup.children;

        // Delete the clicked-on node from current position.
        node.realParent = node.parent;
        //bcParent.children.splice(node.index, 1);
        bcParent.save.splice(node.index, 1);
        setParent(bcParent);

        // Display the tree. Will need to set the parents in the new common group.
        setParent(commonGroup);
        displayNode(commonGroup);
        displayTree(commonGroup.key);  

      } else {
        var html = alertWarning("Common group not found within this group.");
        displayAlerts(html);
      }
    } else {
      if (bcParent == null && groupParent == null) {
        var html = alertWarning("Something has gone wrong! Cannot find Biomedical Concept and the Group parent nodes.");
      } else if (bcParent == null) {
        var html = alertWarning("Something has gone wrong! Cannot find Biomedical Concept parent nodes.");
      } else if (groupParent == null) {
        var html = alertWarning("Something has gone wrong! Cannot find Group parent nodes.");
      }
      displayAlerts(html);
    }
  }

  function restoreCommon(node) {
    var item;
    var parentNode;
    var index;

    // Restore the 'other' nodes. These are the copies.
    for (i=0; i<node.otherCommon.length; i++) {
      item = node.otherCommon[i];
      parentNode = item.realParent
      index = item.index;
      parentNode.save.splice(index, 0, item);
    }

    // Restore the 'main' node.
    parentNode = node.realParent
    index = node.index;
    parentNode.save.splice(index, 0, node);

    // Delete the item from its current position and clean out the other
    // common nodes.
    node.otherCommon = [];
    deleteNode(node);

    // Draw the tree. Set the root as the selected node.
    setRoot();
  }

  function addCommon() {
    if (!currentNode.hasOwnProperty('save')) {
      currentNode.children = [];
      currentNode.save = [];
    }   
    var myHash = {};
    myHash.identifier = "New Common";
    myHash.name = "Common";
    myHash.label = "Common";
    myHash.type = "CommonGroup";
    myHash.parent = currentNode;
    myHash.index = 0;
    myHash.id = 'Not set';
    myHash.key = nextKeyId;
    nextKeyId += 1;
    currentNode.children.unshift(myHash);
    currentNode.save = currentNode.children;
    return currentNode.children[0];
  }

  /*
  * Group generic functions
  */
  function addGroup() {
    var index;
    if (currentNode.hasOwnProperty('save')) {
      index = currentNode.save.length;
    } else {
      currentNode.children = [];
      currentNode.save = [];
      index = 0;
    }     
    currentNode.children[index] = {};
    currentNode.children[index].identifier = "New Group";
    currentNode.children[index].name = "Group";
    currentNode.children[index].label = "Group";
    currentNode.children[index].type = "Group";
    currentNode.children[index].parent = currentNode;
    currentNode.children[index].index = index;
    currentNode.children[index].id = 'Not set';
    currentNode.children[index].key = nextKeyId;
    nextKeyId += 1;
    currentNode.save = currentNode.children;
    return currentNode.children[index];
  }

  function addBc() {
    var parentNode;
    var data = bcSelect.row(bcCurrentRow).data();
    
    bcNode = null;
    $.ajax({
      url: "../cdisc_bcs/" + data.id,
      data: {
        "id": data.id,
        "namespace": data.namespace
      },
      dataType: 'json',
      success: function(result){
        var bc = $.parseJSON(JSON.stringify(result));
        var bcNode;
        var index;
        var pIndex;
        var cIndex;
        var i,j;
        if (currentNode.hasOwnProperty('save')) {
          index = currentNode.save.length;
        } else {
          currentNode.children = [];
          currentNode.save = [];
          index = 0;
        }     
        currentNode.children[index] = {};
        currentNode.children[index].id = bc.id;
        currentNode.children[index].parent = currentNode;
        currentNode.children[index].namespace = bc.namespace;
        currentNode.children[index].name = bc.label;
        currentNode.children[index].identifier = bc.identifier;
        currentNode.children[index].label = bc.label;
        currentNode.children[index].type = "BCGroup";
        currentNode.children[index].key = nextKeyId;
        currentNode.children[index].index = index;
        currentNode.children[index].children = [];
        bcNode = currentNode.children[index];
        nextKeyId += 1;
        pIndex = 0;
        for (i=0; i<bc.properties.length; i++) {
          var property = bc.properties[i];
          if (property[1].Enabled && property[1].Collect) {
            currentNode.children[index].children[pIndex] = {};
            currentNode.children[index].children[pIndex].id = property[1].id;
            currentNode.children[index].children[pIndex].parent = currentNode.children[index];
            currentNode.children[index].children[pIndex].namespace = property[1].namespace;
            currentNode.children[index].children[pIndex].name = property[1].Alias;
            currentNode.children[index].children[pIndex].type = "Item";
            currentNode.children[index].children[pIndex].identifer = property[1].Name;
            currentNode.children[index].children[pIndex].bridgPath = property[1].bridgPath;
            currentNode.children[index].children[pIndex].index = pIndex;
            currentNode.children[index].children[pIndex].label = property[1].Alias;
            currentNode.children[index].children[pIndex].enabled = true;
            currentNode.children[index].children[pIndex].key = nextKeyId;
            nextKeyId += 1;
            var values = property[1].Values
            if (values.length > 0) {
              currentNode.children[index].children[pIndex].children = [];
              for (j=0; j<values.length; j++) {
                currentNode.children[index].children[pIndex].children[j] = {};
                currentNode.children[index].children[pIndex].children[j].id = values[j].id;
                currentNode.children[index].children[pIndex].children[j].parent = currentNode.children[index].children[pIndex];
                currentNode.children[index].children[pIndex].children[j].namespace = values[j].namespace;
                currentNode.children[index].children[pIndex].children[j].name = values[j].cli.notation;
                currentNode.children[index].children[pIndex].children[j].type = "CL";
                currentNode.children[index].children[pIndex].children[j].identifier = values[j].cli.identifier;
                currentNode.children[index].children[pIndex].children[j].index = j;
                currentNode.children[index].children[pIndex].children[j].label = values[j].cli.notation;
                currentNode.children[index].children[pIndex].children[j].enabled = true;
                currentNode.children[index].children[pIndex].children[j].key = nextKeyId;
                nextKeyId += 1;
              }
              currentNode.children[index].children[pIndex].save = currentNode.children[index].children[pIndex].children;
            }
            pIndex++;
          }
        }
        currentNode.children[index].save = currentNode.children[index].children;
        currentNode.save = currentNode.children;
        
        /* Now check for a common group and, if present, see if anything needs
        * moving.
        */
        if (hasCommon(currentNode)) {
          var item;
          var commonItem;
          var commonNode = currentNode.save[0];
          if (commonNode.hasOwnProperty('save')) {
            for (i=0; i<commonNode.save.length; i++) {
              commonItem = commonNode.save[i];
              for (j=0; j<bcNode.save.length; j++) {
                item = bcNode.save[j];
                if (item.bridgPath == commonItem.bridgPath) {
                  // Delete the item from its current position
                  item.realParent = item.parent;
                  bcNode.save.splice(item.index, 1);
                  //bcNode.children.splice(item.index, 1);
                  setParent(bcNode);
                  // And add to the common other nodes  
                  if (!commonNode.hasOwnProperty('otherCommon')) {
                    commonNode.otherCommon = [];
                  }
                  commonNode.otherCommon.push(item);
                }
              }
            }
          }
        }

        // And display everything.
        displayNode(currentNode);
        displayTree(currentNode.key);
      }
    });
  }

  /**
   *  Function to draw the tree
   */
  function displayTree(nodeKey) {
    if (normal) {
      treeNormal(d3Div, formDefinition, click, dblClick);
    } else {
      treeCircular(d3Div, formDefinition, click, dblClick);
    }
    var gRef = findNode(nodeKey);
    currentGRef = gRef;
    currentNode = gRef.__data__;
    markNode1(currentGRef);    
  }
  
  function notImplementedYet() {
    var html = alertWarning("Function not implemented yet.");
    displayAlerts(html);
  }

  /*
  * Other utility functions
  */
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
      if (key == 'parent' || key == 'realParent' || key == 'children' || key == 'otherCommon' || key == 'save') {
      } else {
        targetNode[key] = sourceNode[key]
      }
    }
    if (sourceNode.hasOwnProperty('save')) {
      targetNode.children = [];
      for (i=0; i<sourceNode.save.length; i++) {
        //sourceChild = sourceNode.children[i];
        targetNode.children[i] = {}; 
        copyNode(sourceNode.save[i], targetNode.children[i]);
      }
    } else if (sourceNode.hasOwnProperty('otherCommon')) {
      targetNode.otherCommon = [];
      for (i=0; i<sourceNode.otherCommon.length; i++) {
        //sourceChild = sourceNode.children[i];
        targetNode.otherCommon[i] = {}; 
        copyNode(sourceNode.otherCommon[i], targetNode.otherCommon[i]);
      }
    }
  }

  function initData () {
    normal = true;
    currentNode = null;
    currentGRef = null;
    bcCurrent = null;
    bcCurrentRow = null;
    nextKeyId = parseInt(formDefinition.nextKeyId); // 1 id the root node.
    setParent(formDefinition);
    setSave(formDefinition);
  }

  function setRoot() {
    displayTree(1);
    selectForm();
    displayForm(currentNode);
  }

  function setParent(node) {
    if (node.hasOwnProperty('save')) {
      for (i=0; i<node.save.length; i++) {
        child = node.save[i];
        child.parent = node;
        child.index = i;
        setParent(child);
      }
    }
  }

  function setSave(node) {
    if (node.hasOwnProperty('children')) {
      node.save = node.children;
      for (i=0; i<node.children.length; i++) {
        child = node.children[i];
        setSave(child);
      }
    }
  }

  function deleteNode(node) {
    var parentNode = node.parent
    var parentIndex = node.index
    parentNode.save.splice(parentIndex, 1);
    if (parentNode.save.length == 0) {
      delete parentNode.children;
      delete parentNode.save;
    }
    setParent(parentNode);
    return parentNode;
  }

  function displayNode(node) {
    if (node.type == "Form") {
      selectForm();
      displayForm(node);
    } else if (node.type == "Group") {
      selectGroup();
      displayGroup(node);
    } else if (node.type == "BCGroup") {
      selectBC();
      displayBC(node);
    } else if (node.type == "CommonGroup") {
      selectCommon();
      displayCommon(node);
    } else if (node.type == "Item") {
      selectItem();
      displayItem(node);
    } else if (node.type == "CL") {
      selectCl();
      displayCl(node);
    }
  }

  /*
  * Common node functions
  */
  function hasCommon(node) {
    if (node.hasOwnProperty('save')) {
      child = node.save[0];
      if (child.type == 'CommonGroup') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }  
  }

  function isCommon(node) {
    if (node.type == 'CommonGroup') {
      return true;
    } else {
      return false;
    }
  }
  
});