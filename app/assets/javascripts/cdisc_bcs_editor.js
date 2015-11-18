$(document).ready(function() {
  
  var bcObject = {};      // The overall BC JSON structure
  
  var bcItemTypeId = document.getElementById("bcItemType")
  var bcIdentifierId = document.getElementById("bcIdentifier")
  var itemNameId = document.getElementById("itemName")
  var qTextId = document.getElementById("qText")
  var pTextId = document.getElementById("pText")
  var collectId = document.getElementById("collect")
  var enableId = document.getElementById("enable")
  var searchCDISCTextId = document.getElementById("searchCDISCText")
  var searchCDISCRadioName = document.getElementsByName('searchCDISC_radio');
  var searchSponsorTextId = document.getElementById("searchSponsorText")
  var searchSponsorRadioName = document.getElementsByName('searchSponsor_radio');
  var d3Div = document.getElementById("d3");
  var alertsId = document.getElementById("alerts")
          
  var cdiscDataTableReload = false;
  var cdiscDataTable;
  
  var sponsorDataTableReload = false;
  var sponsorDataTable;
  
  var clCurrent = null;
  var clCurrentRow = null;
  var clTable = null;
  var clCdiscCurrent = null;
  var clCdiscCurrentRow = null;
  var clSponsorCurrent = null;
  var clSponsorCurrentRow = null;
  
  var bcClDataTable;
  var bcClCurrent = null;
  var bcClCurrentRow = null;
  
  var currentNode = null;
  var currentThis = null;
  
  bcObject.identifier = "";
  bcObject.itemType = "";
  bcObject.template = "";
  bcObject.children = [];
    
  bcClDataTable = $('#bcTable').DataTable({
    "searching": false,
    "pageLength": 5,
    "lengthChange": false,
    "columns": [
      {"data" : "identifier", "width" : "50%"},
      {"data" : "notation", "width" : "50%"},
    ]
  });
  bcClDataTable.clear();

  function initialCDISCSearch () {

    cdiscDataTable = $('#cdiscTable').DataTable( {
      "ajax": {
        "url": "../cdisc_terms/search",
        "data": function( d ) {
          d.term = searchCDISCTextId.value,
          d.textSearch = cdiscSearchType(0),
          d.cCodeSearch = cdiscSearchType(1)
        },
        "dataSrc": ""  
      },
      "searching": false,
      "bProcessing": true,
      "columns": [
        {"data" : "identifier", "width" : "10%"},
        {"data" : "notation", "width" : "10%"},
        {"data" : "definition", "width" : "40%"},
        {"data" : "synonym", "width" : "15%" },
        {"data" : "preferredTerm", "width" : "15%" },
        {"data" : "topLevel", "width" : "10%" }
      ]
    });
    cdiscDataTableReload = true;
    
  }

  function initialSponsorSearch () {

    sponsorDataTable = $('#sponsorTable').DataTable( {
      "ajax": {
        "url": "../sponsor_terms/search",
        "data": function( d ) {
          //d.term = $('#searchCDISCText').val(),
          d.term = searchSponsorTextId.value,
          d.textSearch = sponsorSearchType(0),
          d.cCodeSearch = sponsorSearchType(1)
        },
        "dataSrc": ""  
      },
      "searching": false,
      "bProcessing": true,
      "columns": [
        {"data" : "identifier", "width" : "10%"},
        {"data" : "notation", "width" : "10%"},
        {"data" : "definition", "width" : "40%"},
        {"data" : "synonym", "width" : "15%" },
        {"data" : "preferredTerm", "width" : "15%" },
        {"data" : "topLevel", "width" : "10%" }
      ]
    });
    sponsorDataTableReload = true;
    
  }

  /*
   * Function to handle click on the CDISC Text Search button.
   */
  $('#searchCDISC_button').click(function() {
    if (!cdiscDataTableReload) {
      //initialCDISCSearch(searchCDISCTextId.value);
      initialCDISCSearch();
    } else {
      cdiscDataTable.ajax.reload();
    }
  });

  /*
   * Function to handle click on the Sponsor Text Search button.
   */
  $('#searchSponsor_button').click(function() {
    if (!sponsorDataTableReload) {
      initialSponsorSearch();
    } else {
      sponsorDataTable.ajax.reload();
    }
  });

  /*
   * Function to handle click on the CDISC CL table.
   */
  $('#cdiscTable tbody').on('click', 'tr', function () {
    handleDataTable(cdiscDataTable, this);
    clCdiscCurrent = clCurrent;
    clCdiscCurrentRow = clCurrentRow;
  });

  /*
   * Function to handle click on the CDISC CL table.
   */
  $('#sponsorTable tbody').on('click', 'tr', function () {
    handleDataTable(sponsorDataTable, this);
    clSponsorCurrent = clCurrent;
    clSponsorCurrentRow = clCurrentRow;
  });

  function handleDataTable(table,ref) {

    var row = table.row(ref).index();
    var data = table.row(row).data();
    if (!data.topLevel) {
    
      // Toggle the highlight for the row
      if (clCurrent !=  null) {
        $(clCurrent).toggleClass('success');
      }
      $(ref).toggleClass('success');

      // Save the selection
      clCurrent = ref;
      clCurrentRow = row;
      clTable = table;

    }
  }

  /* 
  * Function to handle click on the BC CL table.
  */
  $('#bcTable tbody').on('click', 'tr', function () {
    
    // Toggle the highlight for the row
    if (bcClCurrent != null) {
      $(bcClCurrent).toggleClass('success');
    }
    $(this).toggleClass('success');
    
    // Save the selection.
    bcClCurrent = this;
    bcClCurrentRow = bcClDataTable.row(this).index();

  });

  /* 
  * Function to handle the BC add button click.
  */
  $('#add_button').click(function() {
    
    var data;
    
    if (clCurrentRow != null && currentNode != null) {
      data = clTable.row(clCurrentRow).data();
      bcClDataTable.row.add(data);
      bcClDataTable.draw(false);
    }

  });

  /* 
  * Function to handle the BC delete button click.
  */
  $('#delete_button').click(function() {
    
    var data;

    if (bcClCurrentRow != null) {
      bcClDataTable.row(bcClCurrentRow).remove();
      bcClCurrentRow = null;
      bcClDataTable.draw();
    }
  });

  /* 
  * Function to handle the BC delete button click.
  */
  $('#save_button').click(function() {
    
    var saveData = {};
    var index = 0;
    
    // Save current item node if set
    if (currentNode != null) {
      saveItem(currentNode);
    }
    
    // Build the save data structure   
    saveData.itemType = bcItemTypeId.value;
    saveData.identifier = bcIdentifierId.value;
    saveData.template = bcObject.template;
    saveData.children = [];
    for (index=0; index<bcObject.children.length; index++) {
      saveData.children[index] = {};
      saveData.children[index].name = bcObject.children[index].name;
      saveData.children[index].pText = bcObject.children[index].pText;
      saveData.children[index].qText = bcObject.children[index].qText;
      saveData.children[index].collect = bcObject.children[index].collect;
      saveData.children[index].enable = bcObject.children[index].enable;
      saveData.children[index].cli = bcObject.children[index].cli;
    }

    //alert("Data=" + JSON.stringify(saveData));

    // Send to the server
    $.ajax({
      url: "/cdisc_bcs",
      type: 'POST',
      data: { "data": saveData
            },
      success: function(result){
        alert("Saved.");
      },
      error: function(xhr,status,error){
        var errors;
        var html;
        errors = $.parseJSON(xhr.responseText).errors;
        html = "";  
        for (var i=0; i<errors.length; i++) {
          html = html + '<div class="alert alert-danger alert-dismissible" role="alert">' + 
            '<button type="button" class="close" data-dismiss="alert"><span>&times;</span></button>' + 
            errors[i] + 
            '</div>'
          //alert("Error=" + errors[i]);
        }
        alertsId.innerHTML = html;
      }
    }); 

  });

  /*
   * Function to handle the Get BC Template Button. Load the template and draw the D3 tree
   */
  $('#bct_button').click(function() {
  	var element = document.getElementById("bct_status");
  	var value = element.value;
  	//alert("value=" + value);
  	var parts = value.split("|");
    $.ajax({
      url: "bct_select",
      data: {
        id: parts[0],
        namespace: parts[1]
      },
      dataType: "json",
      success: function(data) { 
        
        // New template so clean out the BC structure
        bcObject = {};
        bcObject.name = "BC Name";
        bcObject.identifier = "12345";
        bcObject.template = value;
        bcObject.root = true;
        bcObject.children = [];
        var index = 0;
        //element.innerHTML = JSON.stringify(data)  + "<br/>";
        //element.innerHTML = data.name + data.properties;
        //alert("data=" + data.name);
        for (var prop in data.properties)
        {
          var property = data.properties[prop]
          bcObject.children[index] = {};
          bcObject.children[index].name = property.Alias;
          bcObject.children[index].pText = "";
          bcObject.children[index].qText = "";
          bcObject.children[index].collect = true;
          bcObject.children[index].enable = true;
          bcObject.children[index].root = false;
          bcObject.children[index].cli = [];
          index++;
        }
        treeNormal(d3Div, bcObject, click, null);
      }
    });
  });

  /**
   *  Function to handle click on the Template (D3) tree.
   */
  function click(node) {
    
    // Dont do anything for the root node.
    if (node.root == false) {
    
      // Display the item tab.
      $('#bcTab a[href="#bcItem"]').tab('show')
      
      // If we have a node selected save the current state and toggle
      // the selected node in the tree.
      if (currentNode != null) {
        clearNode(currentNode, currentThis);
        saveItem(currentNode);
      }
      markNode(node, this);
      
      // Clear the item and display the new one.
      clearItem();
      displayItem(node);

      // Preserve the selection.
      currentNode = node;
      currentThis = this;
    
    }
  }
   
  /**
   * Click Tab to show its contents
   */
  $("#clTab a").click(function(e) {
      if (this.hash == "#clCDISC") {
        clCurrent = clCdiscCurrent;
        clCurrentRow = clCdiscCurrentRow;
      } else {
        clCurrent = clSponsorCurrent;
        clCurrentRow = clSponsorCurrentRow;
      }
      e.preventDefault();
      $(this).tab('show');
  });

  /**
   * Function to display an Item. 
   */
  function displayItem(node) {
    itemNameId.value = node.name;
    qTextId.value = node.qText;
    pTextId.value = node.pText;
    collectId.checked = node.collect;
    enableId.checked = node.enable;
    bcClDataTable.rows.add(node.cli);
    bcClDataTable.draw();
  }

  /**
   * Function to save an item.
   */
  function saveItem(node) {
    
    var i;
    var rowData;
    var item;
    var rows;

    node.qText = qTextId.value;
    node.pText = pTextId.value;
    node.collect = collectId.checked;
    node.enable = enableId.checked;
    rowData = bcClDataTable.rows().data();
    node.cli = [];
    for (i=0; i<rowData.length; i++) {
      item = rowData.row(i).data();
      if (typeof item != 'undefined') {
        node.cli.push(item);
      }
    }
  }

  /**
   * Function to clear an item.
   */
  function clearItem() {
    qTextId.value = "";
    pTextId.value = "";
    collectId.checked = false;
    enableId.checked = false;
    bcClDataTable.clear();
    bcClDataTable.draw();
    bcClCurrent = null;
    bcClCurrentRow = null;
  }

  /*
   * Read CDISC text search
   */
  function cdiscSearchType (index) {
    if (searchCDISCRadioName[index].checked == true) {
      return searchCDISCRadioName[index].value;
    } else {
      return "";
    }
  }

  /*
   * Read sponsor text search
   */
  function sponsorSearchType (index) {
    if (searchSponsorRadioName[index].checked == true) {
      return searchSponsorRadioName[index].value;
    } else {
      return "";
    }
  }


});