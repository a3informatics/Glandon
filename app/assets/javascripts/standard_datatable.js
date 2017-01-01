var dtMainDataTable; 			// Reference to main table
var dtSecondaryDataTable;	// Reference to secondary table
var dtTertiaryDataTable;	// Reference to tertiary table

/*
* Create tables on document ready
*/
$(document).ready( function() {

  dtMainDataTable = $('#main').DataTable({
    columnDefs: [ ]
  } );

  dtSecondaryDataTable = $('#secondary').DataTable({
    columnDefs: [ ]
  } );		
  
  dtTertiaryDataTable = $('#tertiary').DataTable({
  	columnDefs: [ ]
	});

} );

/**
 * Show all items in the main table. 
 * Really only for testing purposes.
 *
 * @return [Null] 
 */
function dtMainTableAll() {
  dtMainDataTable.page.len(-1).draw();
}
