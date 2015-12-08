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
        {"data" : "predicate", "width" : "30%"},
        {"data" : "object", "width" : "30%" },
        {"defaultContent": '<button type="button" class="btn btn-primary btn-xs">Show</button>'}
      ]
    });
    triplesReload = true;
    
  }

  /*
   * Function to handle click on the view button.
   */
  $('#viewButton').click(function() {
    
    // Get the triples
    if (!triplesReload) {
      initialSearch();
    } else {
      triplesTable.ajax.reload();
    }

    // Save the history
    var id = subjectId.value;
    var namespace = subjectNs.value;
    historyCount += 1;
    var idChunked = chunk(id);
    var namespaceChunked = chunk(namespace);
    mainTable.row.add([historyCount, idChunked, namespaceChunked, id, namespace]).draw( false );
  });

  /*
   * Function to handle click on the triples table show.
   */
  $('#triplesTable tbody').on( 'click', 'button', function () {
    var data = triplesTable.row( $(this).parents('tr') ).data();
    if (data.link) {

      // Get the triples
      subjectId.value = data.linkId;
      subjectNs.value = data.linkNamespace;
      triplesTable.ajax.reload();

      // Save history
      historyCount += 1;
      var id = data.linkId;
      var namespace = data.linkNamespace;
      var idChunked = chunk(id);
      var namespaceChunked = chunk(namespace);
      mainTable.row.add([historyCount, idChunked, namespaceChunked, id, namespace]).draw( false );
    }
  });

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
    subjectId.value = data[3];
    subjectNs.value = data[4];
    //triplesTable.ajax.reload();

  });
  
  function chunk(text) {
    var textArray = text.match(/.{1,25}/g);
    var result = ""
    for (var i=0; i<textArray.length; i++) {
      result = result + textArray[i] + " ";
    }
    return result;
  }

});