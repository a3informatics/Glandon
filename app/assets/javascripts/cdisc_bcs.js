$(document).ready(function() {
  
  // The overall BC JSON structure
  var bcObject = {};
  var currentIndex = -1;
  var bcNameId = document.getElementById("bcName")
  var itemNameId = document.getElementById("itemName")
  var qTextId = document.getElementById("qText")
  var pTextId = document.getElementById("pText")
  var collectId = document.getElementById("collect")
  var searchClTextId = document.getElementById("searchClText")
  var debugDiv = document.getElementById("debug"); 
  var clDataTableReload = false;
  var clDataTable;

  initialSearch("...");

  $('.datatable').DataTable({
    // ajax: ...,
    // autoWidth: false,
    // pagingType: 'full_numbers',
    // processing: true,
    // serverSide: true,

    // Optional, if you want full pagination controls.
    // Check dataTables documentation to learn more about available options.
    // http://datatables.net/reference/option/pagingType
  });

  function initialSearch (term) {

    searchClTextId.value = term;
      clDataTable = $('#clTable').DataTable( {
        "ajax": {
          "url": "../cdisc_terms/searchCls",
          "data": function( d ) {
            d.term = $('#searchClText').val();
          },
          "dataSrc": ""  
        },
        "columns": [
          {"data" : "identifier"},
          {"data" : "notation"},
          {"data" : "definition"},
          {"data" : "synonym" },
          {"data" : "preferredTerm" }

        ]
      });
      clDataTableReload = true;
    
  }

  $('#searchCl').click(function() {
    //alert("search");
    //var term = searchClTextId.value;
    if (!clDataTableReload) {
      clDataTable = $('#clTable').DataTable( {
        "ajax": {
          "url": "../cdisc_terms/searchCls",
          "data": function( d ) {
            d.term= $('#searchClText').val();
          },
          "dataSrc": ""  
        },
        "columns": [
          {"data" : "identifier"},
          {"data" : "notation"},
          {"data" : "definition"},
          {"data" : "synonym" },
          {"data" : "preferredTerm" }

        ]
      });
      clDataTableReload = true;
    } else {
      clDataTable.ajax.reload();
    }
    //$.ajax({
    //    url: "../cdisc_terms/searchCls",
    //    data: {
    //      term: term
    //    },
    //    dataType: "json",
    //    success: function(data) { 

    //      debugDiv.innerHTML = JSON.stringify(data)  + "<br/>";

    //    }
    //});    
  });

  // Get BC Template Button. Load the template and draw the D3 tree
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
            bcObject.children[index].index = index
            index++;
          }

          debugDiv.innerHTML = JSON.stringify(bcObject)  + "<br/>";
          
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

  // Toggle children on click.
  function click(d) {
    $('#tab a[href="#item"]').tab('show')
    saveItem();
    clearItem();
    //alert ("Click on D3. Name=" + d.name)
    displayItem(d.index)
  }

  /**
  * Add a Tab
  */
  /*function addTab(index, active) {
      //<li role="presentation" class="active">
      //  <a href="#alias1Tab" aria-controls="group" role="tab" data-toggle="tab">Alias 1</a>
      //</li> 
      var tab = document.getElementById("tab");
      if (active) {
        tab.insertAdjacentHTML('beforeend', '<li role="presentation" class="active"><a href="#page' + index + '" aria-controls="home" role="tab" data-toggle="tab">Page ' + index + '</a></li>');
      } else {
        tab.insertAdjacentHTML('beforeend', '<li role="presentation"><a href="#page' + index + '" aria-controls="home" role="tab" data-toggle="tab">Page ' + index + '</a></li>');
      }
      
      //<div role="tabpanel" class="tab-pane active" id="alias1Tab">
      //  <label>Options:</label>
      //  <button type="button" id="groupUpdateButton" class="btn btn-default">Update</button>
      //</div>
      var tab = document.getElementById("tab-content");
      tab.insertAdjacentHTML('beforeend', '<div role="tabpanel" class="tab-pane" id="page' + index + '">Hello from page ' + index + '<br/><br/><br/><br/><br/><br/><br/><br/></div>');
      $('#page' + index).tab('show');
  }*/
   
  /**
   * Click Tab to show its contents
   */
  $("#tab a").click(function(e) {
      e.preventDefault();
      $(this).tab('show');
  });

  //
  function displayBC() {
    bcNameId.value = bcObject.name;
  }

  //
  function displayItem(index) {
    currentIndex = index
    itemNameId.value = bcObject.children[currentIndex].name;
    qTextId.value = bcObject.children[currentIndex].qText;
    pTextId.value = bcObject.children[currentIndex].pText;
    collectId.value = bcObject.children[currentIndex].collect;
    //alert ("Displaying. Index=" + currentIndex + ", name=" + bcObject.children[currentIndex].name);
  }

  //
  function saveItem() {
    if (currentIndex != -1) {
      //bcObject.children[currentIndex].name = itemNameId.value;
      bcObject.children[currentIndex].qText = qTextId.value;
      bcObject.children[currentIndex].pText = pTextId.value;
      bcObject.children[currentIndex].collect = collectId.value;
      //alert ("Saving. Index=" + currentIndex + ", name=" + bcObject.children[currentIndex].name);
    }
  }

  function clearItem() {
    qTextId.value = "";
    pTextId.value = "";
    collectId.value = false;
    //alert ("Clearing item.");
  }

});