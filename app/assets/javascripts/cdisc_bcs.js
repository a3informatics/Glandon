$(document).ready(function() {
  
  var bcObject = {};      // The overall BC JSON structure
  var currentIndex = -1;
  
  var bcNameId = document.getElementById("bcName")
  var itemNameId = document.getElementById("itemName")
  var qTextId = document.getElementById("qText")
  var pTextId = document.getElementById("pText")
  var collectId = document.getElementById("collect")
  var searchClTextId = document.getElementById("searchClText")
  
  var clDataTableReload = false;
  var clDataTable;
  
  var clPrevSelect = null;
  var clCurrentRow = null;
  
  var bcDataTable;
  var bcPrevSelect = null;
  var bcCurrentRow = null;
  
  initialClSearch("XXXXXX");
  bcDataTable = $('#bcTable').DataTable({
    "searching": false,
    "pageLength": 5,
    "lengthChange": false,
    "columns": [
      {"data" : "identifier", "width" : "50%"},
      {"data" : "notation", "width" : "50%"},
    ]
  });

  function initialClSearch (term) {

    searchClTextId.value = term;
    clDataTable = $('#clTable').DataTable( {
      "ajax": {
        "url": "../cdisc_terms/search",
        "data": function( d ) {
          d.term = $('#searchClText').val(),
          d.textSearch = searchType(0),
          d.cCodeSearch = searchType(1)
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
    searchClTextId.value = "";
    clDataTableReload = true;
    
  }

  /*
   * Function to handle click on the Text Search button.
   */
  $('#search_button').click(function() {
    if (clDataTableReload) {
      clDataTable.ajax.reload();
    }
  });

  /*
   * Function to handle click on the CL table.
   */
   $('#clTable tbody').on('click', 'tr', function () {
    
    var row = clDataTable.row(this).index();
    var data = clDataTable.row(row).data();
    if (!data.topLevel) {
    
      // Toggle the highlight for the row
      if (clPrevSelect !=  null) {
        $(clPrevSelect).toggleClass('success');
      }
      $(this).toggleClass('success');
      clPrevSelect = this;
    
      clCurrentRow = row;
    }
    
  });

  /* 
  * Function to handle click on the BC CL table.
  */
  $('#bcTable tbody').on('click', 'tr', function () {
    
    // Toggle the highlight for the row
    if (bcPrevSelect != null) {
      $(bcPrevSelect).toggleClass('success');
    }
    $(this).toggleClass('success');
    bcPrevSelect = this;

    // Get the data item from the row, add to the property table and 
    // preserve in the bcObject structure.
    bcCurrentRow = bcDataTable.row(this).index();
  });

  /* 
  * Function to handle the add button click.
  */
  $('#add_button').click(function() {
    if (clCurrentRow != null) {
      var data = clDataTable.row(clCurrentRow).data();
      bcDataTable.row.add(data);
      bcDataTable.draw(false);
      bcObject.children[currentIndex].cli.push(data);
    }
  });

  /* 
  * Function to handle the delete button click.
  */
  $('#delete_button').click(function() {
    if (bcCurrentRow != null) {
      bcDataTable.row(bcCurrentRow).remove();
      bcCurrentRow = null;
      bcDataTable.draw();
    }
  });

  // Function to handle the Get BC Template Button. Load the template and draw the D3 tree
  $('#bct_button').click(function() {
  	element = document.getElementById("bct_status");
  	value = element.value;
  	//alert("value=" + value);
  	parts = value.split("|");
      $.ajax({
        url: "bct_select",
        data: {
          id: parts[0],
          namespace: parts[1]
        },
        dataType: "json",
        success: function(data) { 
          
          d3Div = document.getElementById("d3");
          
          // New template so clean out the BC structure
          bcObject = {};
          bcObject.name = "BC Name";
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
            bcObject.children[index].index = index;
            bcObject.children[index].cli = [];
            index++;
          }

          var width = d3Div.clientWidth - 50; 
          var height = d3Div.clientHeight - 50; 

          var tree = d3.layout.tree()
            .size([height, width - 160]);

          var diagonal = d3.svg.diagonal()
            .projection(function(d) { return [d.y, d.x]; });

          var svg = d3.select(d3Div).append("svg")
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", "translate(40,0)");

          var nodes = tree.nodes(bcObject),
            links = tree.links(nodes);

          var link = svg.selectAll("path.link")
            .data(links)
            .enter().append("path")
            .attr("class", "link")
            .attr("d", diagonal);

          var node = svg.selectAll("g.node")
            .data(nodes)
            .enter().append("g")
            .attr("class", "node")
            .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; })
            .on("click", click);

          node.append("circle")
            .attr("r", 8.0);

          node.append("text")
            .attr("dx", function(d) { return d.children ? -8 : 8; })
            .attr("dy", 3)
            .attr("text-anchor", function(d) { return d.children ? "end" : "start"; })
            .text(function(d) { return d.name; });
        
          d3.select(self.frameElement).style("height", height + "px");

        }
      });
  });

  /**
   *  Function to handle click on the D3 tree.
   */
  function click(d) {
    $('#tab a[href="#bcItem"]').tab('show')
    saveItem();
    clearItem();
    displayItem(d.index)
  }
   
  /**
   * Click Tab to show its contents
   */
  $("#tab a").click(function(e) {
      e.preventDefault();
      $(this).tab('show');
  });

  /**
   * Function to display the Concept details.
   */
  function displayBC() {
    bcNameId.value = bcObject.name;
  }

  /**
   * Function to display an Item. 
   */
  function displayItem(index) {
    currentIndex = index
    itemNameId.value = bcObject.children[currentIndex].name;
    qTextId.value = bcObject.children[currentIndex].qText;
    pTextId.value = bcObject.children[currentIndex].pText;
    collectId.value = bcObject.children[currentIndex].collect;
    bcDataTable.rows.add(bcObject.children[currentIndex].cli);
    bcDataTable.draw();
  }

  /**
   * Function to save an item.
   */
  function saveItem() {
    if (currentIndex != -1) {
      //bcObject.children[currentIndex].name = itemNameId.value;
      bcObject.children[currentIndex].qText = qTextId.value;
      bcObject.children[currentIndex].pText = pTextId.value;
      bcObject.children[currentIndex].collect = collectId.value;
    }
  }

  /**
   * Function to clear an item.
   */
  function clearItem() {
    qTextId.value = "";
    pTextId.value = "";
    collectId.value = false;
    bcDataTable.clear();
    bcDataTable.draw();
    bcPrevSelect = null;
    bcCurrentRow = null;
  }

/*
 * Read text search
 */
function searchType (index) {
  var test = document.getElementsByName('search_radio');
  if (test[index].checked == true) {
    return test[index].value;
  } else {
    return "";
  }
}

});