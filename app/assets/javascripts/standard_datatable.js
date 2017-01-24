var dtMainDataTable; 			// Reference to main table
var dtSecondaryDataTable;	// Reference to secondary table
var dtTertiaryDataTable;	// Reference to tertiary table

/*
* Create tables on document ready
*/
$(document).ready( function() {

  if (typeof dtMainOrder === 'undefined') {
    dtMainOrder = '[]'
  }

  dtMainDataTable = $('#main').DataTable({
    columnDefs: [ ],
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "order": dtMainOrder
  });

  dtSecondaryDataTable = $('#secondary').DataTable({
    columnDefs: [ ],
    "pageLength": pageLength,
    "lengthMenu": pageSettings
  });		
  
  dtTertiaryDataTable = $('#tertiary').DataTable({
  	columnDefs: [ ],
    "pageLength": pageLength,
    "lengthMenu": pageSettings
	});

});

/**
 * Show all items in the main table. 
 * Really only for testing purposes.
 *
 * @return [Null] 
 */
function dtMainTableAll() {
  dtMainDataTable.page.len(-1).draw();
}
