var tsCallBack = null; // Callback function
var tsCurrentRef;
var tsCurrentRow;
var tsSearchTable;

$(document).ready( function() {

  $("#notepad_adding").prop("disabled", true);
  
  var id = document.getElementById("thesaurus_id");
  var namespace = document.getElementById("thesaurus_namespace");
  var columns;

  tsCurrentRef = null;
  tsCurrentRow = null;
	columns = [
    {"data" : "parentIdentifier", "width" : "10%"},
    {"data" : "identifier", "width" : "10%"},
    {"data" : "notation", "width" : "10%"},
    {"data" : "preferredTerm", "width" : "15%" },
    {"data" : "synonym", "width" : "15%" },
    {"data" : "definition", "width" : "40%"}
  ];

  filterOutAll();  
  tsSearchTable = $('#searchTable').DataTable( {
    "ajax": {
      "url": "/thesauri/search_results",
      "data": function( d ) {
        d.id = id.value,
        d.namespace = namespace.value
      },
    "dataSrc": "data" 
    },
    "processing": true,
    "serverSide": true,
    "language": {
      "infoFiltered": "",
      "processing": "<img src='/assets/processing-9034d5d34015e4b05d2c1d1a8dc9f6ec9d59bd96d305eb9e24e24e65c591a645.gif'>"
    },
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "columns": columns
  });

  // Setup - add a text input to each footer cell
  $('#searchTable tfoot th').each( function () {
    var title = $(this).text();
    var id = "searchTable_csearch_" + title.toLowerCase();
    if (title == "Extensible") {
      // Do nothing
    } else if (title == "Definition") {
      $(this).html( '<input id="' + id + '" type="text" class="form-control" size="20" placeholder="Search ..." />' );
    } else {
      $(this).html( '<input id="' + id + '" type="text" class="form-control" size="10" placeholder="Search ..." />' );
    }
  });

  // Apply the column search. Fires on return or field empty assuming not the
  // current search value (i.e. something has changed).
  tsSearchTable.columns().every( function () {
    var that = this;
    $( 'input', this.footer() ).on( 'keyup', function (e) {
      if (e.which == 13 || this.value == "") {
        if (that.search() !== this.value) {
          that.search(this.value).draw();
        }
      }
    });
  });

  // Apply the overall search. Fires on return or field empty assuming not the
  // current search value (i.e. something has changed).
  $("#searchTable_filter input")
    .unbind() // Unbind previous default bindings
    .bind("keyup", function(e) { // Bind our desired behavior
      if(this.value == "" || e.keyCode == 13) {
        if (tsSearchTable.search() !== this.value) {
          tsSearchTable.search(this.value).draw();
        }
      }
      return;
    });

  // Handle click on terminology table
  $('#searchTable tbody').on('click', 'tr', function () {
    if (tsCurrentRef != null) {
      $(tsCurrentRef).toggleClass('success');
    }
    $(this).toggleClass('success');
    var row = tsSearchTable.row(this).index();
    tsCurrentRef = this;
    tsCurrentRow = row;
  });

  // handle double click on terminology table
  $('#searchTable tbody').on('dblclick', 'tr', function () {
    if (tsCurrentRef != null) {
      $(tsCurrentRef).toggleClass('success');
    }
    $(this).toggleClass('success');
    var row = tsSearchTable.row(this).index();
    tsCurrentRef = this;
    tsCurrentRow = row;
    var data = tsSearchTable.row(row).data();
    // Clear search fields in UI and within datatables.
    $("#searchTable_filter input").val("");
    tsSearchTable.columns().every( function () {
    	$( 'input', this.footer() ).val("");
    });
    tsSearchTable.search('');
 		tsSearchTable.columns().search('');
 		// Set our parent identifier search and trigger.
    $('#searchTable_csearch_cl').val(data.parentIdentifier);
    var e = jQuery.Event("keyup");
    e.which = 13; 
    e.keyCode = 13;
    $('#searchTable_csearch_cl').trigger(e);
  });

});

/*function tsInit(callback) {
  tsCallBack = callback;
}

function tsUpdate(count) {
  $("#notepadAdd").html('Notepad+ <span class="badge">' + count + '</span>');
}*/

function tsGet() {
  if (tsCurrentRef !== null) {
    var row = tsSearchTable.row(tsCurrentRef).index();
    var data = tsSearchTable.row(row).data();
    return toUri(data.namespace, data.id);
  } else {
    return null;
  }
}

// Remove the All option from the datatables table length option if
// present. Also updates the selected page length.
function filterOutAll() {
  var max = pageSettings[0][0];
  for (var i=0; i<pageSettings[0].length; i++) {
    if (pageSettings[0][i] === -1) {
      pageSettings[0].splice(i,1);
      pageSettings[1].splice(i,1);
    } else {
      if (pageSettings[0][i] > max) {
        max = pageSettings[0][i];
      }
    }
  }
  if (pageLength === -1) {
    pageLength = max;
  }
}
;
