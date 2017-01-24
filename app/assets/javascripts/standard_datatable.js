var dtMainDataTable; 			// Reference to main table
var dtSecondaryDataTable;	// Reference to secondary table
var dtTertiaryDataTable;	// Reference to tertiary table
var dtMainOrder;          // Main table ordering

/*
* Create tables on document ready
*/
$(document).ready( function() {

  // Set the order of the main table and update if overridden by page.
  dtMainOrder = [0, 'asc'];
  if (typeof dtMainOrderUpdate !== 'undefined') {
    dtMainOrder = dtMainOrderUpdate;
  }

  dtMainDataTable = $('#main').DataTable({
    columnDefs: [],
    "pageLength": pageLength,
    "lengthMenu": pageSettings,
    "order": dtMainOrder
  });

  dtSecondaryDataTable = $('#secondary').DataTable({
    columnDefs: [],
    "pageLength": pageLength,
    "lengthMenu": pageSettings
  });		
  
  dtTertiaryDataTable = $('#tertiary').DataTable({
  	columnDefs: [],
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
