$(document).ready(function() {
  
  var subjectId = document.getElementById("subjectId")
  var subjectNs = document.getElementById("subjectNs")
          
  var triplesReload = false;
  var triplesTable;
  
  var historyCount;
  var historyCurrent;
  var historyCurrentRow;
  var mainTable;
  
  // Initialise
  mainTable = $('#main').DataTable();
  mainTable.clear();
  historyCount = 0;
  historyCurrent = null;
  historyCurrentRow = null;
  initialSearch();
  addHistory(subjectId.value, subjectNs.value);

  /*
   * Function for the initial search.
   */
  function initialSearch () {
    triplesTable = $('#triplesTable').DataTable( {
      "ajax": {
        "url": "../dashboard/database",
        "data": function( d ) {
          d.id = subjectId.value,
          d.namespace = subjectNs.value
        },
        "dataSrc": ""  
      },
      "bProcessing": true,
      "columns": [
        {"data" : "subject", "width" : "40%"},
        {"data" : "predicate", "width" : "20%"},
        {"data" : "object", "width" : "40%" },
        {"defaultContent": '<button type="button" class="btn btn-primary btn-xs">Show</button>'}
      ]
    });
    triplesReload = true;
  }

  /*
   * Function to handle button clicks
   */
  $('#viewButton').click(function() {
    // Get the triples
    if (!triplesReload) {
      initialSearch();
    } else {
      triplesTable.ajax.reload();
    }
    // Add the history
    addHistory(subjectId.value, subjectNs.value); 
  });

  $('#graph_button').click(function() {
    linkTo("/iso_concept/graph", subjectNs.value, subjectId.value) 
  });

  /*
   * Function to handle click on the triples table show.
   */
  $('#triplesTable tbody').on( 'click', 'button', function () {
    var data = triplesTable.row( $(this).parents('tr') ).data();
    if (data.link) {
      // Get the triples
      subjectId.value = data.link_id;
      subjectNs.value = data.link_namespace;
      triplesTable.ajax.reload();

      // Add the history
      addHistory(data.link_id, data.link_namespace);      
    }
  });

  /*
   * Function to add history entry.
   */
  function addHistory (id, namespace) {
    historyCount += 1;
    mainTable.row.add([historyCount, namespace, id]).draw(false);
    mainTable.order( [ 0, 'desc' ] );
    mainTable.draw();
  }

  /*
   * Function to handle click on the history table.
   */
  $('#main tbody').on('click', 'tr', function () {
    var row = mainTable.row(this).index();
    var data = mainTable.row(row).data();
    if (historyCurrent !=  null) {
      $(historyCurrent).toggleClass('success');
    }
    $(this).toggleClass('success');

    // Save the selection
    historyCurrent = this;
    historyCurrentRow = row;

    // Get the triples
    subjectNs.value = data[1];
    subjectId.value = data[2];

  });

});